# Stoic Hour

[![CI](https://github.com/zuacaldeira/stoic-hour/actions/workflows/ci.yml/badge.svg)](https://github.com/zuacaldeira/stoic-hour/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Connect IQ](https://img.shields.io/badge/Connect%20IQ-9.1-blue)](https://developer.garmin.com/connect-iq/)
[![Devices](https://img.shields.io/badge/devices-9-green)](manifest.xml)
[![Languages](https://img.shields.io/badge/languages-6-green)](resources-deu)
[![Quotes](https://img.shields.io/badge/quotes-120-green)](source/Quotes.mc)
[![Tests](https://img.shields.io/badge/tests-7%20passing-brightgreen)](source/test/QuoteStoreTest.mc)

A Garmin Connect IQ watch face that displays the time alongside a Stoic quote chosen by time-of-day. The face supports nine devices, six languages, AMOLED always-on display, configurable author whitelist, and a no-repeat-recent quote rotation.

## Screenshot

> Coming soon — capture from simulator via *File → Capture Device* and drop into `docs/screenshots/`.

## Features

- **112 hand-curated public-domain quotes** from Marcus Aurelius, Epictetus, and Seneca, distributed across four time-of-day buckets:
  - 05:00–11:59 — *morning* (action)
  - 12:00–16:59 — *midday* (discipline)
  - 17:00–20:59 — *evening* (reflection)
  - 21:00–04:59 — *night* (acceptance)
- **AMOLED-friendly always-on display** via `onPartialUpdate` — per-second time refresh in sleep mode without burning battery
- **Recent-quote suppression** — last 8 selected quotes are excluded so you rarely see the same quote twice in one day
- **Author whitelist** — independently toggle Marcus Aurelius / Epictetus / Seneca via Connect IQ Mobile settings
- **12h / 24h time** with `a`/`p` suffix in 12h mode
- **Three font sizes** — auto-shrinks to fit any quote in the available space; hard-breaks single words that exceed the line width
- **6 languages** — English, German, French, Spanish, Portuguese, Italian (UI strings; quotes themselves remain in English translation)
- **9 device targets** — Forerunner 265 / 265s / 955 / 965, Venu 3 / 3s, Epix 2 / 2 Pro 47mm, Vivoactive 5

## Project layout

```
StoicHour/
├── manifest.xml                       # CIQ manifest: UUID, 9 devices, 6 languages
├── monkey.jungle                      # build configuration
├── LICENSE                            # MIT + quotation-attribution notice
├── CHANGELOG.md
├── README.md                          # this file
├── SESSION_TYPES.md                   # formal session-type analysis (research bridge)
├── source/
│   ├── StoicHourApp.mc                # Application entry; routes onSettingsChanged
│   ├── StoicHourView.mc               # WatchFace: lifecycle, drawing, AOD, line cache
│   ├── Settings.mc                    # Properties → Settings adapter
│   ├── Quotes.mc                      # Quote class + module: 112 quotes, pickFresh
│   └── test/
│       └── QuoteStoreTest.mc          # 7 barrel tests
├── resources/
│   ├── drawables/{drawables.xml,launcher_icon.png}
│   ├── strings/AppStrings.xml         # English (default)
│   └── settings/{properties.xml,settings.xml}
├── resources-deu/strings/AppStrings.xml
├── resources-fra/strings/AppStrings.xml
├── resources-spa/strings/AppStrings.xml
├── resources-por/strings/AppStrings.xml
├── resources-ita/strings/AppStrings.xml
├── resources-venu3s/drawables/...
└── resources-vivoactive5/drawables/...
```

## Build

Requires Connect IQ SDK 9.0+ and a developer key.

```bash
SDK=$HOME/.Garmin/ConnectIQ/Sdks/connectiq-sdk-lin-9.1.0-2026-03-09-6a872a80b
KEY=$HOME/.Garmin/ConnectIQ/keys/developer_key.der
$SDK/bin/monkeyc -d fr265 -f monkey.jungle -o /tmp/StoicHour.prg -y $KEY -w
```

Substitute `-d fr265` with any of: `fr265s`, `fr955`, `fr965`, `venu3`, `venu3s`, `epix2`, `epix2pro47mm`, `vivoactive5`.

## Run in simulator

```bash
$SDK/bin/connectiq &                      # start simulator
$SDK/bin/monkeydo /tmp/StoicHour.prg fr265
```

On Ubuntu 24.04 you also need `LD_LIBRARY_PATH` pointing at backported `libwebkit2gtk-4.0-37` (Ubuntu dropped the package in 24.04). See repo issue tracker for the workaround.

## Sideload to a watch

`Connect IQ: Build for Device Test` from VS Code copies a `.prg` to `GARMIN/APPS` over USB. Or manually copy `StoicHour.prg` to that directory.

## Run unit tests

```bash
$SDK/bin/monkeyc -d fr265 -f monkey.jungle -o /tmp/StoicHour-test.prg -y $KEY --unit-test
$SDK/bin/monkeydo /tmp/StoicHour-test.prg fr265 -t
```

Expected: `PASSED (passed=7, failed=0, errors=0)`.

## Configuring the watch face

Open the Garmin Connect mobile app → device → Connect IQ → Stoic Hour → Settings:

| Setting | Default | Effect |
|---|---|---|
| Use 24-hour time | on | toggles `13:42` vs `1:42p` |
| Quote font size | Medium | Small / Medium / Large; auto-shrinks if text doesn't fit |
| Marcus Aurelius | on | include Marcus quotes in rotation |
| Epictetus | on | include Epictetus quotes in rotation |
| Seneca | on | include Seneca quotes in rotation |

If all three philosophers are disabled, the filter falls back to all-on (the face always has something to show).

## Adding more quotes

Edit `_morning()` / `_midday()` / `_evening()` / `_night()` in `source/Quotes.mc`. Each entry has the form `new Quote(<id>, "<text>", "<author>")`. IDs must be unique within the file (current convention: 100s = morning, 200s = midday, 300s = evening, 400s = night).

## Session-type analysis

See `SESSION_TYPES.md` for the formal typestate analysis of the CIQ `WatchFace` lifecycle, the quote-selection state machine, and the rendering protocol — written in the notation of the [Session Types Research](https://github.com/zuacaldeira/SessionTypesResearch) project. The analysis is the bridge between this watch face and the academic project, and proposes three follow-up steps for the research registry (Steps 830/831/832).
