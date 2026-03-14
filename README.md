# lex-cognitive-friction

Cognitive state transition resistance model for brain-modeled agentic AI in the LegionIO ecosystem.

## What It Does

Transitioning between cognitive operating modes carries resistance. Switching from focused analytical work to social interaction is harder than switching from rest to social. This extension tracks friction per state-transition path, attempts transitions with a given force level, and records outcomes. Transitions that overcome friction complete; those that don't are resisted. Forced transitions always succeed regardless of friction.

Seven state types are defined: `focus_mode`, `rest_mode`, `social_mode`, `analytical_mode`, `creative_mode`, `vigilant_mode`, `reflective_mode`.

## Usage

```ruby
require 'legion/extensions/cognitive_friction'

client = Legion::Extensions::CognitiveFriction::Client.new

# Configure friction for specific paths
client.set_friction(from_state: :focus_mode, to_state: :social_mode, friction: 0.75)
client.set_friction(from_state: :rest_mode,  to_state: :social_mode, friction: 0.1)

# Attempt a transition (force must exceed friction to succeed)
client.attempt_transition(to_state: :social_mode, force: 0.5)
# => { success: true, transition: { outcome: :resisted, ... }, current_state: :rest_mode }

# Force a transition through regardless
client.force_transition(to_state: :social_mode)
# => { success: true, transition: { outcome: :forced, ... }, current_state: :social_mode }

# Full report
client.friction_report
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT
