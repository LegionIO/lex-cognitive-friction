# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveFriction
      module Helpers
        class StateTransition
          include Constants

          attr_reader :id, :from_state, :to_state, :friction, :outcome, :force_applied,
                      :created_at

          def initialize(from_state:, to_state:, friction: DEFAULT_FRICTION)
            @id            = SecureRandom.uuid
            @from_state    = from_state.to_sym
            @to_state      = to_state.to_sym
            @friction      = friction.to_f.clamp(0.0, 1.0)
            @outcome       = nil
            @force_applied = 0.0
            @created_at    = Time.now.utc
          end

          def attempt!(force: 0.5)
            @force_applied = force.to_f.clamp(0.0, 1.0)
            @outcome = if @force_applied > @friction
                         :completed
                       elsif @force_applied > (@friction * 0.7)
                         :deferred
                       else
                         :resisted
                       end
            self
          end

          def force!(force: 1.0)
            @force_applied = force.to_f.clamp(0.0, 1.0)
            @outcome = :forced
            self
          end

          def completed?
            %i[completed forced].include?(@outcome)
          end

          def friction_label
            match = FRICTION_LABELS.find { |range, _| range.cover?(@friction) }
            match ? match.last : :locked
          end

          def to_h
            {
              id:             @id,
              from_state:     @from_state,
              to_state:       @to_state,
              friction:       @friction,
              friction_label: friction_label,
              outcome:        @outcome,
              force_applied:  @force_applied,
              completed:      completed?,
              created_at:     @created_at
            }
          end
        end
      end
    end
  end
end
