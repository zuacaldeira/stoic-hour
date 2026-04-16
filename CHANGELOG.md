# Changelog

All notable changes to Stoic Hour are documented here.

## [1.0.0] — 2026-04-17

First A+ release.

### Added
- 112 Stoic quotes across four time-of-day buckets (morning / midday / evening / night), each tagged with a stable numeric ID
- Author whitelist setting: independently enable/disable Marcus Aurelius, Epictetus, Seneca
- 12h / 24h time format setting with `a` / `p` suffix in 12h mode
- Three quote font sizes: Small / Medium / Large
- `onPartialUpdate` for AMOLED always-on per-second time refresh in sleep mode
- Persistent recent-quote tracking via `Application.Storage` (last 8 quotes excluded from selection)
- Wrapped-line cache: `_wrapText` runs at most once per (quote, font, zone) combination
- Hard-break fallback for words that exceed the line width
- Subtle accent line under the time
- Localization: English, German, French, Spanish, Portuguese, Italian
- Multi-device target: Forerunner 265 / 265s / 955 / 965, Venu 3 / 3s, Epix 2 / 2 Pro 47mm, Vivoactive 5
- Polished launcher icon (Greek Λ on dark gradient circle)
- Unit tests for `bucketForHour`, deterministic `pick`, `pickFresh` recent-avoidance, author filtering
- LICENSE (MIT) with quotation-attribution notice

### Fixed
- Time and quote text overlapped when the quote wrapped to many lines (introduced explicit zones with bottom-up font shrinking)
- O(n²) string concatenation in `_splitWords` (now scans the full string once and slices via `substring`)
- Single-word overflow ran off the display (now hard-breaks the word into pieces that fit)
- `getInitialView` return-type override mismatch (corrected to tuple form)
- Launcher icon was 40×40, but the FR265 expects 60×60 (also generated per-device variants)

### Documented
- `SESSION_TYPES.md` — formal session-type analysis of the WatchFace lifecycle, quote-selection state machine, and rendering protocol; lattice-product analysis; three suggested registry-promotion candidates for the Session Types Research project

## [0.1.0] — 2026-04-17

Initial scaffold. Time + quote rendering, single device target, 20 quotes.
