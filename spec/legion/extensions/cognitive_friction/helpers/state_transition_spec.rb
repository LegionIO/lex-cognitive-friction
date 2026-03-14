# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveFriction::Helpers::StateTransition do
  subject(:transition) { described_class.new(from_state: :rest, to_state: :active, friction: 0.5) }

  describe '#initialize' do
    it 'sets from_state and to_state as symbols' do
      expect(transition.from_state).to eq(:rest)
      expect(transition.to_state).to eq(:active)
    end

    it 'assigns a UUID id' do
      expect(transition.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'clamps friction to 0..1' do
      high = described_class.new(from_state: :a, to_state: :b, friction: 5.0)
      expect(high.friction).to eq(1.0)

      low = described_class.new(from_state: :a, to_state: :b, friction: -1.0)
      expect(low.friction).to eq(0.0)
    end

    it 'starts with nil outcome' do
      expect(transition.outcome).to be_nil
    end

    it 'records created_at' do
      expect(transition.created_at).to be_a(Time)
    end
  end

  describe '#attempt!' do
    it 'returns :completed when force exceeds friction' do
      transition.attempt!(force: 0.8)
      expect(transition.outcome).to eq(:completed)
    end

    it 'returns :resisted when force is too low' do
      transition.attempt!(force: 0.1)
      expect(transition.outcome).to eq(:resisted)
    end

    it 'returns :deferred when force is in the middle zone' do
      transition.attempt!(force: 0.4)
      expect(transition.outcome).to eq(:deferred)
    end

    it 'clamps force_applied to 0..1' do
      transition.attempt!(force: 5.0)
      expect(transition.force_applied).to eq(1.0)
    end

    it 'returns self for chaining' do
      expect(transition.attempt!(force: 0.8)).to eq(transition)
    end
  end

  describe '#force!' do
    it 'sets outcome to :forced' do
      transition.force!
      expect(transition.outcome).to eq(:forced)
    end

    it 'sets force_applied to 1.0 by default' do
      transition.force!
      expect(transition.force_applied).to eq(1.0)
    end
  end

  describe '#completed?' do
    it 'is true for :completed outcome' do
      transition.attempt!(force: 0.8)
      expect(transition.completed?).to be true
    end

    it 'is true for :forced outcome' do
      transition.force!
      expect(transition.completed?).to be true
    end

    it 'is false for :resisted outcome' do
      transition.attempt!(force: 0.1)
      expect(transition.completed?).to be false
    end

    it 'is false for :deferred outcome' do
      transition.attempt!(force: 0.4)
      expect(transition.completed?).to be false
    end
  end

  describe '#friction_label' do
    it 'returns a symbol' do
      expect(transition.friction_label).to be_a(Symbol)
    end

    it 'returns :frictionless for 0.0 friction' do
      t = described_class.new(from_state: :a, to_state: :b, friction: 0.0)
      expect(t.friction_label).to eq(:frictionless)
    end

    it 'returns :locked for 1.0 friction' do
      t = described_class.new(from_state: :a, to_state: :b, friction: 1.0)
      expect(t.friction_label).to eq(:locked)
    end
  end

  describe '#to_h' do
    before { transition.attempt!(force: 0.8) }

    it 'includes all fields' do
      hash = transition.to_h
      expect(hash).to include(
        :id, :from_state, :to_state, :friction, :friction_label,
        :outcome, :force_applied, :completed, :created_at
      )
    end

    it 'reflects the outcome' do
      expect(transition.to_h[:completed]).to be true
    end
  end
end
