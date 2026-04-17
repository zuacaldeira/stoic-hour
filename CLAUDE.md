# Stoic Hour — Claude Code instructions

A minimalist Garmin Connect IQ **watch face** (Monkey C). Time + a time-of-day Stoic quote. 120 quotes, 9 devices, 6 UI languages. MIT licensed.

Upstream: <https://github.com/zuacaldeira/stoic-hour>.

## 1. What this project is — and isn't

**Is:** a small, intentionally narrow watch face. Public artefact. Shipped to users.

**Is also:** an **empirical artefact** for the Session Types Research programme. It provides a real device running three layered typestate protocols, which the programme studies in bands 800 (Engineering/wearables) and 900 (Programming-language tooling).

**Isn't:** a research monorepo. Do NOT import programme infrastructure here (no Alloy models, no Lean proofs, no Python `reticulate` code, no multi-step registries). Theory work belongs in `~/Development/SessionTypesResearch/`.

## 2. Split-by-concern rule (this is a sibling repo)

Two directories, one collaboration:

| Concern | Location |
|---|---|
| Monkey C source, CIQ SDK builds, watch-face UI, device testing, translations, quotes, CI | **here** |
| Session-type theory, Alloy/Lean mechanisation, registry entries, step papers, cross-domain surveys | `~/Development/SessionTypesResearch/` |
| Bridge document linking the two | [`SESSION_TYPES.md`](SESSION_TYPES.md) (lives here; cited from there) |

**Rule of thumb for cross-repo work: read across, write within.** If editing Monkey C, work here. If editing a step paper or Alloy model, switch to a SessionTypesResearch-rooted session so that project's `CLAUDE.md` and memory apply.

## 3. Commands

```bash
make build              # default device = fr265
make all                # build for all 9 devices
make test               # build + run unit tests in simulator (must show PASSED passed=N, failed=0, errors=0)
make sim                # launch simulator (must be running before `make run`)
make run                # sideload current build to simulator
make clean
```

SDK path, key path, and device are controlled by `SDK=`, `KEY=`, `DEVICE=` env vars (see Makefile defaults).

Ubuntu-24.04 webkit-4.0 backport is required for the simulator. `Makefile` already exports `LD_LIBRARY_PATH`; see `README.md §SDK setup` if the simulator won't start.

## 4. Code style

- **Monkey C**: 4-space indent; `as` type annotations on every function signature and class field
- XML resource files: 4-space indent, lowercase tags, double-quoted attributes
- One module per file; tests in `source/test/`
- Quote format: `new Quote(<id>, "<exact text, no smart quotes>", "<Author>")`. IDs: 100s=morning, 200s=midday, 300s=evening, 400s=night. Never reuse retired IDs.

## 5. Scope discipline

From `CONTRIBUTING.md` — the face is intentionally narrow. Accept: quote additions, localizations, device targets, bug fixes, profile-backed performance work. Decline: new top-level features (sensors, complications, weather), non-Stoic quotes, and behavioural changes to the lifecycle session type that do NOT update `SESSION_TYPES.md` in the same PR.

Feature creep is the failure mode here. Before adding any new behaviour, ask: does this belong in a *different* watch face? Usually yes.

## 6. Session-type bridge — what this means here

`StoicHourView.mc` implements three protocols that Connect IQ enforces at runtime but Monkey C does not check at compile time:

1. **WatchFace lifecycle** — `init . onLayout . onShow . μX. &{ onUpdate: X, onEnterSleep: ..., onHide: ... }`
2. **Quote selection** — hourly bucket transitions
3. **Render protocol** — per-`onUpdate` drawing sequencing

Their parallel composition has ≤ 4×4×5 = 80 reachable configurations per minute, and is a product reticulate (a lattice). See [`SESSION_TYPES.md`](SESSION_TYPES.md) for the full analysis.

**Standing invariant:** every non-trivial change to `StoicHourView.mc`'s lifecycle handling (`onShow`, `onHide`, `onEnterSleep`, `onExitSleep`, `onUpdate`, `onPartialUpdate`) must be checked against the lifecycle session type in `SESSION_TYPES.md`. If the change invalidates the protocol statement, update the protocol in the same commit — don't leave the bridge document stale.

## 7. Registered research steps

Three step proposals derived from this watch face are promoted in the programme registry (SessionTypesResearch commit `fb1f217f`, 2026-04-17). They are `Planned`, not `Complete`:

| Step | Title | Status |
|------|-------|--------|
| 830 | Connect IQ `WatchFace` lifecycle as a session type (Alloy + Lean) | Planned |
| 831 | Monkey C as a BICA-style typestate target | Planned |
| 832 | Connect IQ lifecycle family as Gay–Hole subtyping hierarchy | Planned |

If changes to this repo materially affect any of them (e.g., discovering a new callback beyond the seven already modelled, or finding that the protocol differs on a specific device), **note it in `SESSION_TYPES.md` §7 "Limits"** and raise a registry update over in SessionTypesResearch.

## 8. Working principles carried over from the research programme

These are adapted from SessionTypesResearch feedback memory. They apply here too:

- **Full transparency.** Public repo, public decisions, public trade-offs. Credit AI collaboration where used.
- **Tests must pass before push.** `make test` passes; CI green. Never push breaking code.
- **Fix at source.** If `SESSION_TYPES.md` has a wrong statement, correct the statement; don't leave it and add a correction note below. Downstream material (step papers, talks) copies uncritically.
- **No unproved claims.** If `SESSION_TYPES.md` asserts a lattice property, the research repo should have (or be getting) an Alloy/Lean witness. Speculative assertions are labelled as such.
- **Explicit paths when staging.** `git add <path>` — never `git add -A` or `git add .` (the working tree can carry build output, SDK caches, `.prg` files).
- **Supervisor-only push.** Interactive agents commit locally; only the human (or an explicit supervisor session) pushes.

## 9. What NOT to do

- Don't import programme Python (`reticulate`) or Java (BICA Reborn) code here. If you want to run a lattice check against the real state space, do it in SessionTypesResearch and cite the result here.
- Don't add emojis to source files or commit messages (programme convention).
- Don't commit built `.prg` files, developer keys, or anything from `build/`.
- Don't localize the quotes themselves — only UI strings. Editorial-judgement problem, not a translation one (`CONTRIBUTING.md §Design note`).
- Don't modify `manifest.xml` device list without having tested on that device family in the simulator.
- Don't rewrite the protocol in `SESSION_TYPES.md` to match a convenient implementation — if code and protocol disagree, the code is wrong unless CIQ docs say otherwise.

## 10. When in doubt

For research-shaped questions (is this a lattice? is this a subtyping witness? does Step 830 cover this?): switch to a SessionTypesResearch-rooted Claude session.

For device/SDK/Monkey C questions: stay here.
