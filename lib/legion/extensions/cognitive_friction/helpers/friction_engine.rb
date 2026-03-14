# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveFriction
      module Helpers
        class FrictionEngine
          include Constants

          def initialize
            @transitions    = {}
            @friction_map   = {}
            @current_state  = :rest_mode
          end

          def set_current_state(state:)
            @current_state = state.to_sym
          end

          def current_state
            @current_state
          end

          def set_friction(from_state:, to_state:, friction:)
            key = :"#{from_state}_to_#{to_state}"
            @friction_map[key] = friction.to_f.clamp(0.0, 1.0)
          end

          def get_friction(from_state:, to_state:)
            key = :"#{from_state}_to_#{to_state}"
            @friction_map.fetch(key, DEFAULT_FRICTION)
          end

          def attempt_transition(to_state:, force: 0.5)
            prune_if_needed
            friction = get_friction(from_state: @current_state, to_state: to_state)
            transition = StateTransition.new(
              from_state: @current_state,
              to_state:   to_state,
              friction:   friction
            )
            transition.attempt!(force: force)
            @current_state = to_state.to_sym if transition.completed?
            @transitions[transition.id] = transition
            transition
          end

          def force_transition(to_state:)
            prune_if_needed
            friction = get_friction(from_state: @current_state, to_state: to_state)
            transition = StateTransition.new(
              from_state: @current_state,
              to_state:   to_state,
              friction:   friction
            )
            transition.force!
            @current_state = to_state.to_sym
            @transitions[transition.id] = transition
            transition
          end

          def transition_history(limit: 10)
            @transitions.values.sort_by(&:created_at).last(limit)
          end

          def successful_transitions
            @transitions.values.select(&:completed?)
          end

          def resisted_transitions
            @transitions.values.select { |t| t.outcome == :resisted }
          end

          def success_rate
            return 0.0 if @transitions.empty?

            (successful_transitions.size.to_f / @transitions.size).round(4)
          end

          def average_friction
            return 0.0 if @transitions.empty?

            frictions = @transitions.values.map(&:friction)
            (frictions.sum / frictions.size).round(10)
          end

          def highest_friction_paths(limit: 5)
            @friction_map.sort_by { |_, v| -v }.first(limit).map do |key, friction|
              parts = key.to_s.split('_to_')
              { from: parts[0]&.to_sym, to: parts[1]&.to_sym, friction: friction }
            end
          end

          def friction_report
            {
              current_state:       @current_state,
              total_transitions:   @transitions.size,
              successful:          successful_transitions.size,
              resisted:            resisted_transitions.size,
              success_rate:        success_rate,
              average_friction:    average_friction,
              friction_paths:      @friction_map.size,
              highest_friction:    highest_friction_paths(limit: 3)
            }
          end

          def to_h
            {
              current_state:     @current_state,
              total_transitions: @transitions.size,
              success_rate:      success_rate,
              average_friction:  average_friction,
              friction_paths:    @friction_map.size
            }
          end

          private

          def prune_if_needed
            return if @transitions.size < MAX_TRANSITIONS

            oldest = @transitions.values.min_by(&:created_at)
            @transitions.delete(oldest.id) if oldest
          end
        end
      end
    end
  end
end
