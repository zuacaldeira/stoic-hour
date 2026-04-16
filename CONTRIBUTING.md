# Contributing to Stoic Hour

Thanks for your interest. Stoic Hour is a small, focused watch face — contributions that align with that focus are warmly welcomed.

## Scope

We accept:
- **Quote additions** — public-domain translations of Marcus Aurelius, Epictetus, Seneca (or other recognised Stoics), with citation in the PR description
- **Localizations** — UI string translations (the quote *text* itself stays in English; see the design note below)
- **Device targets** — adding a new `<iq:product>` to `manifest.xml` if you've tested on the device
- **Bug fixes** — anything that fails the test suite or breaks rendering on a supported device
- **Performance improvements** — backed by a profiling note

We probably won't accept:
- New top-level features (sensor integrations, complications, weather) — those belong in a different watch face
- Quotes from outside the Stoic tradition (the face's identity is Stoic specifically)
- Behavioural changes to the lifecycle session type without a corresponding update to `SESSION_TYPES.md`

## Design note: why quotes aren't translated

The 120 quotes are public-domain English translations of Greek and Latin originals. Adding "the German version" of a quote requires choosing one of several existing translations, each with its own register and emphasis — a question of editorial judgement, not pure translation. Until we have a per-language editor, the UI is localized but quotes stay in their established English translations.

If you'd like to maintain a per-language quote pool, open a discussion before sending a PR.

## Workflow

1. Fork, branch, edit
2. Run `make test` — must show `PASSED (passed=N, failed=0, errors=0)`
3. Run `make all` — must build for all 9 declared devices
4. Submit PR; the CI workflow runs static checks automatically
5. Each PR should be one logical change (one feature, one fix, one batch of related quotes)

## Code style

- Monkey C: 4-space indent, `as` type annotations on every function signature and class field
- XML resource files: 4-space indent, lowercase tag names, double-quoted attributes
- One module per file; tests in `source/test/`

## Quote format

```monkey
new Quote(<id>, "<exact text, no smart quotes>", "<Author>")
```

ID conventions:
- 100s = morning bucket
- 200s = midday
- 300s = evening
- 400s = night

Pick the next free ID in your bucket. Don't reuse retired IDs.

## Reporting bugs

Open a GitHub issue with: target device, SDK version, what you saw vs. what you expected, and steps to reproduce in the simulator.

## Licensing

By contributing, you agree your work is released under the project's MIT licence (see `LICENSE`).
