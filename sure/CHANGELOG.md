# Changelog

For the changelog of Sure itself, take a look here:

https://github.com/we-promise/sure/releases

The addon version is `<addon_version>-<sure_version>`: the left half is this addon's own version, the right half is the Sure release it ships.

## 0.7.0-0.7.4

- Added `env_vars`, a list of `name`/`value` pairs passed straight through to Sure as environment variables. It covers everything Sure reads that this addon has no option for — SMTP, alternative AI providers, Rails tuning — without waiting for an addon release. Entries are applied after the mapped options, so one reusing an existing name overrides it.

## 0.6.0-0.7.4

Migrated the addon from the abandoned Maybe Finance project to [Sure](https://github.com/we-promise/sure), the maintained continuation.

**Breaking:** the addon slug changed from `maybe_finance` to `sure`, so Home Assistant shows this as a new addon rather than an update. Back up your database, then reinstall and reuse the same database settings and the same `secret_key_base`. See the migration guide in the repository README.

- The addon now runs the official `ghcr.io/we-promise/sure` image instead of building the app from source, so installs and updates are much faster.
- Removed `good_job_execution_mode`. Sure replaced GoodJob with Sidekiq, and the addon now runs the Sidekiq worker alongside the web server. Redis is required.
- Replaced `require_invite_code` with `onboarding_state` (`open`, `invite_only`, `closed`).
- Uploads are stored under `/data/storage` and now survive addon restarts and updates.
- Dropped the `armhf` architecture. Upstream publishes `linux/amd64` and `linux/arm64` only.
- Replaced the Maybe Finance icon and logo with Sure's own branding.

## 0.5.x

Introduced the requirement for a separate `redis` addon. Please have a look at the readme for setup, and back up before migrating.

Note: the last digit of the version (`0.0.x`) was out of sync with Maybe Finance, because the addon tracked the newest `main` commit rather than a release.
