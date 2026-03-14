# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveFriction
      module Runners
        module CognitiveFriction
          include Helpers::Constants

          if defined?(Legion::Extensions::Helpers::Lex)
            include Legion::Extensions::Helpers::Lex
          end

          def set_current_state(engine: nil, state:, **)
            eng = engine || default_engine
            eng.set_current_state(state: state)
            { success: true, state: eng.current_state }
          end

          def set_friction(engine: nil, from_state:, to_state:, friction:, **)
            eng = engine || default_engine
            eng.set_friction(from_state: from_state, to_state: to_state, friction: friction)
            { success: true, from_state: from_state, to_state: to_state, friction: friction }
          end

          def get_friction(engine: nil, from_state:, to_state:, **)
            eng = engine || default_engine
            friction = eng.get_friction(from_state: from_state, to_state: to_state)
            { success: true, from_state: from_state, to_state: to_state, friction: friction }
          end

          def attempt_transition(engine: nil, to_state:, force: 0.5, **)
            eng = engine || default_engine
            transition = eng.attempt_transition(to_state: to_state, force: force)
            { success: true, transition: transition.to_h, current_state: eng.current_state }
          end

          def force_transition(engine: nil, to_state:, **)
            eng = engine || default_engine
            transition = eng.force_transition(to_state: to_state)
            { success: true, transition: transition.to_h, current_state: eng.current_state }
          end

          def transition_history(engine: nil, limit: 10, **)
            eng = engine || default_engine
            history = eng.transition_history(limit: limit).map(&:to_h)
            { success: true, history: history, count: history.size }
          end

          def success_rate(engine: nil, **)
            eng = engine || default_engine
            { success: true, success_rate: eng.success_rate }
          end

          def average_friction(engine: nil, **)
            eng = engine || default_engine
            { success: true, average_friction: eng.average_friction }
          end

          def highest_friction_paths(engine: nil, limit: 5, **)
            eng = engine || default_engine
            paths = eng.highest_friction_paths(limit: limit)
            { success: true, paths: paths, count: paths.size }
          end

          def friction_report(engine: nil, **)
            eng = engine || default_engine
            { success: true, report: eng.friction_report }
          end

          private

          def default_engine
            @default_engine ||= Helpers::FrictionEngine.new
          end
        end
      end
    end
  end
end
