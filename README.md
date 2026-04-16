# Stoic Hour

[![CI](https://github.com/zuacaldeira/stoic-hour/actions/workflows/ci.yml/badge.svg)](https://github.com/zuacaldeira/stoic-hour/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/zuacaldeira/stoic-hour)](https://github.com/zuacaldeira/stoic-hour/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Connect IQ](https://img.shields.io/badge/Connect%20IQ-9.1-blue)](https://developer.garmin.com/connect-iq/)
[![Devices](https://img.shields.io/badge/devices-9-green)](manifest.xml)
[![Languages](https://img.shields.io/badge/languages-6-green)](resources-deu)
[![Quotes](https://img.shields.io/badge/quotes-120-green)](source/Quotes.mc)
[![Tests](https://img.shields.io/badge/tests-7%20passing-brightgreen)](source/test/QuoteStoreTest.mc)

A minimalist Garmin Connect IQ watch face. Time, plus a Stoic quote chosen by time-of-day. The accent color under the time signals which bucket you're in — warm gold for action, neutral white for discipline, cool blue for reflection, deep purple for acceptance.

## Preview

| Morning (action) | Midday (discipline) | Evening (reflection) | Night (acceptance) |
|:---:|:---:|:---:|:---:|
| ![morning](docs/screenshots/fr265-morning.png) | ![midday](docs/screenshots/fr265-midday.png) | ![evening](docs/screenshots/fr265-evening.png) | ![night](docs/screenshots/fr265-night.png) |
| Marcus Aurelius | Marcus Aurelius | Seneca | Seneca |

> Mockups rendered at the FR265 native resolution (416×416). Live screenshots from the simulator land here once the on-device tooling supports programmatic capture on Wayland.

## Features

| | |
|---|---|
| **120 quotes** | 30 per bucket — Marcus Aurelius, Epictetus, Seneca; public-domain translations |
| **Time-of-day buckets** | 05–11 morning · 12–16 midday · 17–20 evening · 21–04 night |
| **Bucket accent color** | warm gold / neutral white / cool blue / deep purple |
| **No-repeat-recent** | last 8 quotes excluded from the next pick (persisted via `Application.Storage`) |
| **Author whitelist** | independently toggle Marcus / Epictetus / Seneca via Connect IQ Mobile |
| **12h / 24h time** | with `a`/`p` suffix in 12h mode |
| **3 font sizes** | Small / Medium / Large; auto-shrinks to fit; hard-breaks over-long words |
| **AMOLED always-on** | per-second time refresh in sleep via `onPartialUpdate`, no quote redraw |
| **6 languages** | EN, DE, FR, ES, PT, IT (UI labels) |
| **9 devices** | FR265 / 265s / 955 / 965, Venu 3 / 3s, Epix 2 / 2 Pro 47mm, Vivoactive 5 |

## Install

### From source

Requires Connect IQ SDK 9.0+ and a developer key.

```bash
make build              # default device = fr265
make all                # build for all 9 devices
make test               # build + run unit tests in simulator
make sim                # launch simulator (must be running before `make run`)
make run                # sideload current build to simulator
```

The `Makefile` exports `LD_LIBRARY_PATH` for the Ubuntu-24.04 webkit-4.0 backport — see [SDK setup notes](#sdk-setup-on-ubuntu-2404) below.

### From the Connect IQ Store

*Coming soon — submission is one of the next milestones.*

### Sideload to a watch

Either `make run` from a paired watch, or copy a built `.prg` to `GARMIN/APPS` over USB.

## Configure

Open Garmin Connect Mobile → device → Connect IQ → Stoic Hour → Settings:

| Setting | Default | Effect |
|---|---|---|
| Use 24-hour time | on | `13:42` vs `1:42p` |
| Quote font size | Medium | Small / Medium / Large; auto-shrinks if quote doesn't fit |
| Marcus Aurelius | on | include in rotation |
| Epictetus | on | include in rotation |
| Seneca | on | include in rotation |

If all three philosophers are disabled, the filter falls back to all-on.

## Project layout

```
StoicHour/
├── manifest.xml                       # 9 devices, 6 languages, UUID
├── monkey.jungle
├── Makefile                           # build / test / sim / run / clean
├── LICENSE                            # MIT + quotation-attribution notice
├── CHANGELOG.md
├── CONTRIBUTING.md  SECURITY.md  CONTRIBUTORS.md
├── README.md                          # this file
├── SESSION_TYPES.md                   # formal session-type analysis (research bridge)
├── source/
│   ├── StoicHourApp.mc                # Application entry; routes onSettingsChanged
│   ├── StoicHourView.mc               # WatchFace: lifecycle, drawing, AOD, line cache
│   ├── Settings.mc                    # Properties → Settings adapter
│   ├── Quotes.mc                      # Quote class + module: 120 quotes, pickFresh
│   └── test/QuoteStoreTest.mc         # 7 barrel tests
├── resources/
│   ├── drawables/                     # launcher icon
│   ├── strings/AppStrings.xml         # English (default)
│   └── settings/{properties.xml,settings.xml}
├── resources-{deu,fra,spa,por,ita}/strings/AppStrings.xml
├── resources-{venu3s,vivoactive5}/drawables/   # per-device icon overrides
├── docs/screenshots/                  # README preview tiles
└── .github/{workflows/ci.yml, ISSUE_TEMPLATE/...}
```

## Adding quotes

Edit `source/Quotes.mc` — the `_morning()` / `_midday()` / `_evening()` / `_night()` arrays. Each entry:

```monkey
new Quote(<id>, "<text>", "<Author>")
```

ID convention: 100s = morning, 200s = midday, 300s = evening, 400s = night. Pick the next free ID; don't reuse retired IDs.

The `testAllPoolsHaveQuotes` test enforces ≥25 per bucket. The CI workflow enforces ≥100 total.

## Tests

```bash
make test
# expected: PASSED (passed=7, failed=0, errors=0)
```

Tests cover bucket boundaries, deterministic `pick`, hour-to-hour rotation, recent-avoidance, author filter, all-disabled fallback, and pool size invariants.

## Session-type analysis

See **[`SESSION_TYPES.md`](SESSION_TYPES.md)** for a formal typestate analysis of the CIQ `WatchFace` lifecycle:

```
init . onLayout . onShow . μX. &{
    onUpdate     : X,
    onEnterSleep : &{ onUpdate : μY. &{ onUpdate: Y, onExitSleep: X }},
    onHide       : &{ onShow   : X }
}
```

The document maps every method in `StoicHourView.mc` to a position in this protocol, decomposes the rendering and quote-selection sub-protocols, computes the product-lattice state space, and proposes three follow-up steps for the [Session Types Research](https://github.com/zuacaldeira/SessionTypesResearch) registry (Steps 830 / 831 / 832).

This is the bridge between an everyday wearable artifact and an active formal-methods research programme.

## SDK setup on Ubuntu 24.04

Garmin's SDK Manager and simulator dynamically link `libwebkit2gtk-4.0-37`, which Ubuntu dropped in 24.04. The workaround is a local backport (no system install):

```bash
cd ~/garmin/lib-compat/debs
wget http://security.ubuntu.com/ubuntu/pool/main/w/webkit2gtk/libwebkit2gtk-4.0-37_2.50.4-0ubuntu0.22.04.1_amd64.deb
wget http://security.ubuntu.com/ubuntu/pool/main/w/webkit2gtk/libjavascriptcoregtk-4.0-18_2.50.4-0ubuntu0.22.04.1_amd64.deb
wget http://mirrors.kernel.org/ubuntu/pool/main/i/icu/libicu70_70.1-2_amd64.deb
for f in *.deb; do dpkg-deb -x "$f" ~/garmin/lib-compat/; done
sudo ln -s /home/$USER/garmin/lib-compat/usr/lib/x86_64-linux-gnu/webkit2gtk-4.0 \
           /usr/lib/x86_64-linux-gnu/webkit2gtk-4.0
```

`export LD_LIBRARY_PATH=~/garmin/lib-compat/usr/lib/x86_64-linux-gnu` before running `sdkmanager` or `connectiq` — the `Makefile` already does this.

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Quote additions, localizations, device targets, and bug fixes are welcome. New top-level features generally aren't a fit — Stoic Hour is intentionally narrow.

## License

[MIT](LICENSE) for the code. All quotes are public-domain translations; attributions are tracked in [`CONTRIBUTORS.md`](CONTRIBUTORS.md).
