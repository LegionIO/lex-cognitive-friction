# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveFriction::Runners::CognitiveFriction do
  let(:client) { Legion::Extensions::CognitiveFriction::Client.new }

  describe '#set_current_state' do
    it 'returns success with new state' do
      result = client.set_current_state(state: :active)
      expect(result[:success]).to be true
      expect(result[:state]).to eq(:active)
    end
  end

  describe '#set_friction' do
    it 'returns success with friction details' do
      result = client.set_friction(from_state: :rest, to_state: :active, friction: 0.7)
      expect(result[:success]).to be true
      expect(result[:friction]).to eq(0.7)
    end
  end

  describe '#get_friction' do
    it 'retrieves stored friction' do
      client.set_friction(from_state: :rest, to_state: :active, friction: 0.6)
      result = client.get_friction(from_state: :rest, to_state: :active)
      expect(result[:success]).to be true
      expect(result[:friction]).to eq(0.6)
    end
  end

  describe '#attempt_transition' do
    it 'returns transition details' do
      result = client.attempt_transition(to_state: :active, force: 0.9)
      expect(result[:success]).to be true
      expect(result[:transition]).to be_a(Hash)
      expect(result[:current_state]).to be_a(Symbol)
    end
  end

  describe '#force_transition' do
    it 'always completes' do
      result = client.force_transition(to_state: :locked)
      expect(result[:success]).to be true
      expect(result[:transition][:completed]).to be true
    end
  end

  describe '#transition_history' do
    it 'returns history array' do
      client.attempt_transition(to_state: :a, force: 0.9)
      result = client.transition_history
      expect(result[:success]).to be true
      expect(result[:count]).to eq(1)
    end
  end

  describe '#success_rate' do
    it 'returns a numeric rate' do
      result = client.success_rate
      expect(result[:success]).to be true
      expect(result[:success_rate]).to be_a(Numeric)
    end
  end

  describe '#average_friction' do
    it 'returns a numeric average' do
      result = client.average_friction
      expect(result[:success]).to be true
      expect(result[:average_friction]).to be_a(Numeric)
    end
  end

  describe '#highest_friction_paths' do
    it 'returns paths array' do
      client.set_friction(from_state: :a, to_state: :b, friction: 0.8)
      result = client.highest_friction_paths
      expect(result[:success]).to be true
      expect(result[:paths]).to be_a(Array)
    end
  end

  describe '#friction_report' do
    it 'returns a full report' do
      result = client.friction_report
      expect(result[:success]).to be true
      expect(result[:report]).to include(:current_state, :total_transitions)
    end
  end
end
