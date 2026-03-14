# lex-cognitive-friction

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-friction`

## Purpose

Models the resistance to cognitive state transitions. Moving between cognitive operating modes (focus, creative, social, analytical, etc.) has a cost. Some transitions are smooth; others are highly resistant. Friction can be configured per transition path. Attempted transitions may fail (resisted) or be forced through regardless of friction level.

## Gem Info

| Field | Value |
|---|---|
| Gem name | `lex-cognitive-friction` |
| Version | `0.1.0` |
| Namespace | `Legion::Extensions::CognitiveFriction` |
| Ruby | `>= 3.4` |
| License | MIT |
| GitHub | https://github.com/LegionIO/lex-cognitive-friction |

## File Structure

```
lib/legion/extensions/cognitive_friction/
  cognitive_friction.rb             # Top-level require
  version.rb                        # VERSION = '0.1.0'
  client.rb                         # Client class
  helpers/
    constants.rb                    # Friction rates, thresholds, state types
    state_transition.rb             # StateTransition value object
    friction_engine.rb              # Engine: states, transitions, friction map
  runners/
    cognitive_friction.rb           # Runner module
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_TRANSITIONS` | 300 | Transition history cap; LRU eviction |
| `DEFAULT_FRICTION` | 0.3 | Friction for unconfigured paths |
| `FRICTION_BOOST` | 0.1 | Rate constant (defined, not used directly in engine) |
| `FRICTION_DECAY` | 0.03 | Rate constant (defined, not used directly in engine) |
| `MOMENTUM_THRESHOLD` | 0.7 | Defined; documents intent |
| `INERTIA_THRESHOLD` | 0.6 | Defined; documents intent |
| `FRICTION_LABELS` | hash | `locked` (0.8+), `resistant`, `moderate`, `smooth`, `frictionless` |
| `TRANSITION_OUTCOMES` | array | `[:completed, :resisted, :deferred, :forced]` |
| `STATE_TYPES` | array | `focus_mode`, `rest_mode`, `social_mode`, `analytical_mode`, `creative_mode`, `vigilant_mode`, `reflective_mode` |

## Helpers

### `StateTransition`

Records a single attempted or forced state change.

- `initialize(from_state:, to_state:, friction:)` — generates UUID + timestamp
- `attempt!(force: 0.5)` — transition completes if `force > friction`; else outcome is `:resisted`
- `force!` — sets outcome to `:forced` unconditionally
- `completed?`, outcome accessors
- `to_h`

### `FrictionEngine`

Manages current state, friction map, and transition history.

- `initialize` — starts in `:rest_mode`
- `set_current_state(state:)` — direct assignment
- `set_friction(from_state:, to_state:, friction:)` — configures a specific path
- `get_friction(from_state:, to_state:)` — returns configured or `DEFAULT_FRICTION`
- `attempt_transition(to_state:, force: 0.5)` — creates transition, attempts it, updates current_state on success
- `force_transition(to_state:)` — always succeeds, marks as forced
- `transition_history(limit: 10)` — recent transitions sorted by created_at
- `successful_transitions`, `resisted_transitions`
- `success_rate`, `average_friction`
- `highest_friction_paths(limit: 5)` — sorted friction map entries
- `friction_report` — full stats

## Runners

**Module**: `Legion::Extensions::CognitiveFriction::Runners::CognitiveFriction`

| Method | Key Args | Returns |
|---|---|---|
| `set_current_state` | `state:` | `{ success:, state: }` |
| `set_friction` | `from_state:`, `to_state:`, `friction:` | `{ success:, from_state:, to_state:, friction: }` |
| `get_friction` | `from_state:`, `to_state:` | `{ success:, friction: }` |
| `attempt_transition` | `to_state:`, `force: 0.5` | `{ success:, transition:, current_state: }` |
| `force_transition` | `to_state:` | `{ success:, transition:, current_state: }` |
| `transition_history` | `limit: 10` | `{ history:, count: }` |
| `success_rate` | — | `{ success_rate: }` |
| `average_friction` | — | `{ average_friction: }` |
| `highest_friction_paths` | `limit: 5` | `{ paths:, count: }` |
| `friction_report` | — | Full report |

Private: `default_engine` — memoized `FrictionEngine`. Optional `engine:` param.

## Integration Points

- **`lex-tick`**: Friction between cognitive modes can gate mode transitions. High friction from `focus_mode` to `social_mode` during a task could model why agents resist context switching.
- **`lex-cognitive-flexibility`**: Flexibility tracks how well the agent switches task sets; friction tracks the resistance of state transitions. Complementary models.

## Development Notes

- `FRICTION_BOOST` and `FRICTION_DECAY` are defined but not applied automatically by the engine. They document the intent for a future auto-modulation pass.
- The transition history is LRU-pruned: oldest `created_at` is evicted when at `MAX_TRANSITIONS`.
- The friction map key format is `:"#{from_state}_to_#{to_state}"` — simple string interpolation, no struct.
- In-memory only.

---

**Maintained By**: Matthew Iverson (@Esity)
