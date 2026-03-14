# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveFriction
      module Helpers
        module Constants
          MAX_TRANSITIONS = 300

          DEFAULT_FRICTION = 0.3
          FRICTION_BOOST = 0.1
          FRICTION_DECAY = 0.03
          MOMENTUM_THRESHOLD = 0.7
          INERTIA_THRESHOLD = 0.6

          FRICTION_LABELS = {
            (0.8..)     => :locked,
            (0.6...0.8) => :resistant,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :smooth,
            (..0.2)     => :frictionless
          }.freeze

          TRANSITION_OUTCOMES = %i[completed resisted deferred forced].freeze

          STATE_TYPES = %i[
            focus_mode rest_mode social_mode analytical_mode
            creative_mode vigilant_mode reflective_mode
          ].freeze
        end
      end
    end
  end
end
