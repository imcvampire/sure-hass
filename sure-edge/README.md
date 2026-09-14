# Sure (Finances) Edge

Prerelease channel for the [Sure](https://github.com/we-promise/sure) Home
Assistant addon. It runs the same wrapper as the stable **Sure (Finances)**
addon, but pinned to the newest upstream **prerelease** (`v*-alpha.*`) instead of
the newest stable release.

Install this only to test upcoming Sure versions. For day-to-day use, install
**Sure (Finances)**.

> [!WARNING]
> Alpha builds run unreleased database migrations on boot, and those are not
> designed to be reversible. Point this addon at its own database — never at the
> one your stable addon uses — and back up before every update.

## Relationship to the stable addon

| | Sure (Finances) | Sure (Finances) Edge |
| --- | --- | --- |
| Slug | `sure` | `sure-edge` |
| Tracks | Latest Sure release | Latest Sure prerelease |
| Default host port | `1234` | `1235` |
| Default `postgres_db` | `postgres` | `sure_edge` |
| Updated | Weekly | Daily |

Both can be installed at the same time. They are separate addons to Home
Assistant, with separate `/data` volumes, so their uploads and options do not
interact — but they do share whatever PostgreSQL and Redis you point them at, so
give the edge addon its own database.

## Requirements

Identical to the stable addon: a PostgreSQL addon and a Redis addon. Sure runs
background jobs on Sidekiq, and this addon starts a Sidekiq worker next to the
web server, so Redis must be reachable.

## Options

The option set is identical to the stable addon's. See its
[README](../sure/README.md#options) for the full table, and the
[repository README](../README.md) for installation and prerequisites. Only two
defaults differ, both listed in the table above.

## Versioning

`<addon_version>-<sure_version>`, so **0.6.0-0.7.5-alpha.8** is addon 0.6.0
shipping Sure 0.7.5-alpha.8. The left half is shared with the stable addon,
because both ship the same wrapper.

## Storage

Uploads handled by Active Storage (statements, imports, logos) are written to the
addon's persistent `/data/storage`, exposed to the app as `/rails/storage`.

## Architectures

`amd64` and `aarch64`. Upstream publishes `linux/amd64` and `linux/arm64` only.

## License

**GNU AFFERO GENERAL PUBLIC LICENSE Version 3**
