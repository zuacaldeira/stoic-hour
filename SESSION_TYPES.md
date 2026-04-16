# Session-Type Analysis of Stoic Hour

This watch face is a small but real example of the kind of object whose API is governed by a typestate protocol that the framework (Connect IQ) imposes and the application (Stoic Hour) must obey. We document that protocol as a **session type** in the notation of the Session Types Research project.

## 1. The CIQ-imposed `WatchFace` lifecycle session type

Connect IQ runs every `WatchFace` subclass through a fixed protocol. Reading the SDK docs, the legal sequence of method calls on a `WatchFace` instance is:

```
init . onLayout . onShow . μX. &{
    onUpdate         : X,
    onEnterSleep     : &{ onUpdate : μY. &{
                              onUpdate     : Y,
                              onExitSleep  : X
                          }},
    onHide           : &{ onShow : X }
}
```

In words:
- After construction (`init`), the framework calls `onLayout` exactly once.
- Then `onShow` is called, putting the face in the **active** state.
- From active, the framework loops calling `onUpdate` (every minute, plus on user gesture).
- The framework can **transition to sleep** by calling `onEnterSleep`. While asleep, `onUpdate` is still called but at a much lower rate, and (on AMOLED) drawing budget is restricted. `onExitSleep` returns to active.
- The framework can **hide** the face (e.g., user opens a menu) by calling `onHide`; later `onShow` brings it back.

This is exactly a session type with one branch (`&`) and two recursion variables (`X` for the active loop, `Y` for the sleep loop). It is **not** a free FSM — `onShow` may not occur before `onLayout`; `onExitSleep` may not occur unless we are in `Y`; etc.

### How Stoic Hour's source maps onto the protocol

| Method in `StoicHourView.mc` | Protocol position |
|---|---|
| `initialize()` | the `init` step |
| `onLayout(dc)` | the `onLayout` step (we leave it empty: no pre-layout state needed) |
| `onShow()` | the `onShow` step |
| `onUpdate(dc)` | the recursive `onUpdate` step (in both `X` and `Y` loops) |
| `onEnterSleep()` | sleep transition; sets `_isAsleep = true` and requests redraw to switch to dimmer rendering |
| `onExitSleep()` | wake transition; clears `_isAsleep` |
| `onHide()` | hide transition |

The `_isAsleep` field is a **typestate marker** in the application: it tracks which recursive loop (`X` or `Y`) the protocol is currently in. Without it, `onUpdate` could not legally vary its rendering by sleep state.

### Why this matters for correctness

If we ever called `onExitSleep`-like cleanup from within the active loop (or drew expensively in the sleep loop on AMOLED), we would violate the CIQ protocol. The framework would not raise a session-type error (Monkey C is dynamically typed), but on the watch the face could be **dropped from the registry** for misbehaviour. The session type is enforced at the platform level, not the language level — exactly the gap that BICA Reborn is designed to close for Java.

## 2. The quote-selection state machine

Independent of the lifecycle, Stoic Hour's quote selection has its own protocol:

```
QuoteSelector = rec X . hourTick . bucketCheck . &{
    sameBucket     : (refresh-or-keep) . X,
    bucketChange   : pickNewQuote . X
}
```

In code (`StoicHourView.onUpdate`), this is:

```monkeyc
if (_currentQuote == null or hour != _currentHour) {
    _currentBucket = bucket;
    _currentHour = hour;
    _currentQuote = QuoteStore.pick(bucket, today.year, today.day, hour);
}
```

The `&` branch (`sameBucket` vs `bucketChange`) is the conditional. The `pickNewQuote` step is the call to `QuoteStore.pick(...)`.

## 3. The `onUpdate` rendering session type

Each invocation of `onUpdate(dc)` follows a strict sequencing on the `Graphics.Dc` object:

```
RenderProtocol = setColor(bg) . clear . drawTime . maybe-drawQuote . maybe-drawAuthor . end
```

The `maybe-` prefix corresponds to a guarded branch (`+{ draw, skip }`). This is a **selection** session type (we choose what to draw based on internal state), not a branch (we are not waiting for an external choice).

In Stoic Hour: when `_isAsleep`, we skip the quote and author and draw only a dim time. When `_isAsleep` is false, we draw all three.

## 4. Lattice structure (reticulate view)

Combining the three session types above by parallel composition:

```
StoicHour-Total = WatchFaceLifecycle ∥ QuoteSelector ∥ RenderProtocol
```

The state space of `StoicHour-Total` is the **product** of the state spaces of the three components. Specifically:

- **WatchFaceLifecycle**: 4 reachable states (init, active-loop, sleep-loop, hidden)
- **QuoteSelector**: 4 reachable states (one per bucket); transitions across boundaries
- **RenderProtocol**: a chain of 5 states per `onUpdate` invocation (collapses to 1 between calls)

The product reticulate has at most `4 × 4 × 5 = 80` reachable configurations per minute. By the product-lattice theorem of the research project, this product **is itself a lattice** with componentwise meet and join, provided each component is a lattice — which they are, since they are each finite, with reachable top, bottom, and pairwise meets/joins.

## 5. What this would look like in BICA Reborn (research handle)

BICA Reborn is the project's Java annotation-based session-type checker. Its annotation grammar is roughly:

```java
@Session("init . &{ onLayout: &{ onShow: rec X . ...protocol... }}")
abstract class WatchFace { ... }
```

If Connect IQ shipped Monkey C with a comparable `@Session` annotation (or if a port of BICA were retargeted at Monkey C), the Stoic Hour view would be statically checked against the lifecycle protocol at build time. Two improvements over the status quo:

1. **No silent platform-level violations**: a draw-in-wrong-state bug becomes a compile error.
2. **No "what state am I in" ambiguity**: the typestate field `_isAsleep` could be replaced by the type-system's built-in tracking of which recursion variable (`X` or `Y`) we are inside.

This is a direct application of session-type theory to a real wearable platform, and is the kind of cross-domain claim the research project documents in its band 800 (engineering / wearables) registry.

## 6. Suggested registry entries (for the research project)

Promotable to `docs/planning/future-steps-registry.md` of the SessionTypesResearch repo:

- **Step 830** — Connect IQ `WatchFace` lifecycle as a session type: encode the four-state lifecycle, prove reticularity at bound 4 in Alloy, then mechanise lattice-isomorphism in Lean. First experiment: this Stoic Hour project.
- **Step 831** — Monkey C as a target language for BICA-style typestate checking: assess feasibility of porting the BICA annotation processor to Monkey C's compile-time hooks, or alternatively shipping a static-analysis CLI that consumes the same `@Session` strings.
- **Step 832** — Connect IQ `DataField`, `Widget`, and `App` lifecycles as a *family* of related session types; check whether they form a subtyping hierarchy under Gay–Hole subtyping (likely yes: `WatchFace` is roughly a sub-protocol of `App`).

## 7. Limits of this analysis

- Connect IQ does not currently provide tooling to enforce the lifecycle session type at compile time. We document the type; we do not check it.
- The framework can call `onSettingsChanged` and other callbacks not modelled here; this analysis is intentionally restricted to the *core* lifecycle.
- The `RenderProtocol` analysis assumes a single drawing pass. Partial-update mode (used on AMOLED for second-by-second rendering) has its own sub-protocol that we have not modelled.

These limits are the natural follow-up work, and would be promoted to step proposals if pursued further.
