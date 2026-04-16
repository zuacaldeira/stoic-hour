# Security Policy

Stoic Hour is a Connect IQ watch face. It runs only on Garmin devices, has no permissions declared in `manifest.xml`, makes no network requests, and stores nothing beyond a list of recently-shown quote IDs in `Application.Storage`.

The realistic security surface is therefore narrow:

- **Code injection through user settings** — settings are constrained to typed properties (boolean, number from a small list); we don't accept free-form text
- **Storage corruption** — recent-quote list is read defensively (`raw instanceof Lang.Array` check) and falls back to an empty list

If you believe you've found a vulnerability, please email **zuacaldeira@gmail.com** rather than opening a public issue. I'll acknowledge within 7 days.

## Supported versions

Only the latest tagged release is supported. Patch releases are issued for the latest minor; older minors do not receive security updates.
