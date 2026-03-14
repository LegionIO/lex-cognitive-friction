# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveFriction::Helpers::FrictionEngine do
  subject(:engine) { described_class.new }

  describe '#initialize' do
    it 'starts in rest_mode' do
      expect(engine.current_state).to eq(:rest_mode)
    end
  end

  describe '#set_current_state' do
    it 'changes the current state' do
      engine.set_current_state(state: :active)
      expect(engine.current_state).to eq(:active)
    end

    it 'converts to symbol' do
      engine.set_current_state(state: 'thinking')
      expect(engine.current_state).to eq(:thinking)
    end
  end

  describe '#set_friction / #get_friction' do
    it 'stores and retrieves friction for a path' do
      engine.set_friction(from_state: :rest, to_state: :active, friction: 0.7)
      expect(engine.get_friction(from_state: :rest, to_state: :active)).to eq(0.7)
    end

    it 'clamps friction to 0..1' do
      engine.set_friction(from_state: :a, to_state: :b, friction: 5.0)
      expect(engine.get_friction(from_state: :a, to_state: :b)).to eq(1.0)
    end

    it 'returns default friction for unknown paths' do
      default = Legion::Extensions::CognitiveFriction::Helpers::Constants::DEFAULT_FRICTION
      expect(engine.get_friction(from_state: :x, to_state: :y)).to eq(default)
    end
  end

  describe '#attempt_transition' do
    it 'moves to new state on success' do
      engine.set_friction(from_state: :rest_mode, to_state: :active, friction: 0.3)
      transition = engine.attempt_transition(to_state: :active, force: 0.8)
      expect(transition.completed?).to be true
      expect(engine.current_state).to eq(:active)
    end

    it 'stays in current state on resistance' do
      engine.set_friction(from_state: :rest_mode, to_state: :active, friction: 0.9)
      transition = engine.attempt_transition(to_state: :active, force: 0.1)
      expect(transition.completed?).to be false
      expect(engine.current_state).to eq(:rest_mode)
    end

    it 'records the transition in history' do
      engine.attempt_transition(to_state: :active, force: 0.8)
      expect(engine.transition_history.size).to eq(1)
    end
  end

  describe '#force_transition' do
    it 'always moves to new state regardless of friction' do
      engine.set_friction(from_state: :rest_mode, to_state: :locked, friction: 1.0)
      transition = engine.force_transition(to_state: :locked)
      expect(transition.completed?).to be true
      expect(engine.current_state).to eq(:locked)
    end
  end

  describe '#transition_history' do
    it 'returns transitions in chronological order' do
      engine.attempt_transition(to_state: :a, force: 0.9)
      engine.attempt_transition(to_state: :b, force: 0.9)
      history = engine.transition_history
      expect(history.first.created_at).to be <= history.last.created_at
    end

    it 'respects the limit' do
      5.times { |i| engine.attempt_transition(to_state: :"s#{i}", force: 0.9) }
      expect(engine.transition_history(limit: 3).size).to eq(3)
    end
  end

  describe '#successful_transitions' do
    it 'returns only completed transitions' do
      engine.set_friction(from_state: :rest_mode, to_state: :a, friction: 0.3)
      engine.attempt_transition(to_state: :a, force: 0.8)
      engine.set_friction(from_state: :a, to_state: :b, friction: 0.9)
      engine.attempt_transition(to_state: :b, force: 0.1)
      expect(engine.successful_transitions.size).to eq(1)
    end
  end

  describe '#resisted_transitions' do
    it 'returns only resisted transitions' do
      engine.set_friction(from_state: :rest_mode, to_state: :hard, friction: 0.9)
      engine.attempt_transition(to_state: :hard, force: 0.1)
      expect(engine.resisted_transitions.size).to eq(1)
    end
  end

  describe '#success_rate' do
    it 'returns 0.0 with no transitions' do
      expect(engine.success_rate).to eq(0.0)
    end

    it 'calculates ratio of successful to total' do
      engine.set_friction(from_state: :rest_mode, to_state: :a, friction: 0.3)
      engine.attempt_transition(to_state: :a, force: 0.8)
      engine.set_friction(from_state: :a, to_state: :b, friction: 0.9)
      engine.attempt_transition(to_state: :b, force: 0.1)
      expect(engine.success_rate).to eq(0.5)
    end
  end

  describe '#average_friction' do
    it 'returns 0.0 with no transitions' do
      expect(engine.average_friction).to eq(0.0)
    end

    it 'calculates average friction across transitions' do
      engine.set_friction(from_state: :rest_mode, to_state: :a, friction: 0.2)
      engine.attempt_transition(to_state: :a, force: 0.9)
      engine.set_friction(from_state: :a, to_state: :b, friction: 0.8)
      engine.attempt_transition(to_state: :b, force: 0.9)
      expect(engine.average_friction).to eq(0.5)
    end
  end

  describe '#highest_friction_paths' do
    it 'returns paths sorted by friction descending' do
      engine.set_friction(from_state: :a, to_state: :b, friction: 0.3)
      engine.set_friction(from_state: :c, to_state: :d, friction: 0.9)
      engine.set_friction(from_state: :e, to_state: :f, friction: 0.6)
      paths = engine.highest_friction_paths(limit: 3)
      expect(paths.first[:friction]).to eq(0.9)
      expect(paths.last[:friction]).to eq(0.3)
    end

    it 'respects the limit' do
      5.times { |i| engine.set_friction(from_state: :"a#{i}", to_state: :"b#{i}", friction: i * 0.2) }
      expect(engine.highest_friction_paths(limit: 2).size).to eq(2)
    end
  end

  describe '#friction_report' do
    it 'includes all report fields' do
      report = engine.friction_report
      expect(report).to include(
        :current_state, :total_transitions, :successful, :resisted,
        :success_rate, :average_friction, :friction_paths, :highest_friction
      )
    end
  end

  describe '#to_h' do
    it 'includes summary fields' do
      hash = engine.to_h
      expect(hash).to include(
        :current_state, :total_transitions, :success_rate,
        :average_friction, :friction_paths
      )
    end
  end

  describe 'pruning' do
    it 'prunes oldest transition when limit reached' do
      stub_const('Legion::Extensions::CognitiveFriction::Helpers::Constants::MAX_TRANSITIONS', 3)
      eng = described_class.new
      4.times { |i| eng.attempt_transition(to_state: :"s#{i}", force: 0.9) }
      expect(eng.transition_history.size).to eq(3)
    end
  end
end
