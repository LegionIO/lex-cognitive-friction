# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveFriction::Helpers::Constants do
  let(:klass) { Class.new { include Legion::Extensions::CognitiveFriction::Helpers::Constants } }

  describe 'DEFAULT_FRICTION' do
    it 'is a float between 0 and 1' do
      expect(klass::DEFAULT_FRICTION).to be_a(Float)
      expect(klass::DEFAULT_FRICTION).to be_between(0.0, 1.0)
    end
  end

  describe 'FRICTION_LABELS' do
    it 'is a frozen hash' do
      expect(klass::FRICTION_LABELS).to be_a(Hash).and be_frozen
    end

    it 'covers the full 0..1 range' do
      labels = klass::FRICTION_LABELS
      [0.0, 0.1, 0.3, 0.5, 0.7, 0.9, 1.0].each do |val|
        match = labels.find { |range, _| range.cover?(val) }
        expect(match).not_to be_nil, "no label for #{val}"
      end
    end
  end

  describe 'STATE_TYPES' do
    it 'is a frozen array of symbols' do
      expect(klass::STATE_TYPES).to be_a(Array).and be_frozen
      expect(klass::STATE_TYPES).to all(be_a(Symbol))
    end
  end

  describe 'TRANSITION_OUTCOMES' do
    it 'includes completed and resisted' do
      expect(klass::TRANSITION_OUTCOMES).to include(:completed, :resisted)
    end
  end

  describe 'MAX_TRANSITIONS' do
    it 'is a positive integer' do
      expect(klass::MAX_TRANSITIONS).to be_a(Integer)
      expect(klass::MAX_TRANSITIONS).to be > 0
    end
  end
end
