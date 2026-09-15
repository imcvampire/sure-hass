# Sure (Finances)

Home Assistant addon that runs [Sure](https://github.com/we-promise/sure), a self-hosted personal finance application, from the official `ghcr.io/we-promise/sure` image.

Installation, prerequisites and migration notes live in the [repository README](../README.md).

## Requirements

- A PostgreSQL addon (Sure stores all of its data there).
- A Redis addon. Sure runs background jobs on Sidekiq, and this addon starts a Sidekiq worker next to the web server, so Redis must be reachable.

## Options

| Option | Required | Default | Maps to | Notes |
| --- | --- | --- | --- | --- |
| `postgres_user` | no | `postgres` | `POSTGRES_USER` | |
| `postgres_password` | **yes** | `homeassistant` | `POSTGRES_PASSWORD` | Must match your PostgreSQL addon. |
| `postgres_db` | no | `postgres` | `POSTGRES_DB` | |
| `secret_key_base` | **yes** | `generate_a_secure_key_here` (placeholder — change it) | `SECRET_KEY_BASE` | Generate with `openssl rand -hex 64`. Also derives the encryption keys for credentials stored in the database, so keep it stable. |
| `db_host` | no | `172.30.32.1` | `DB_HOST` | |
| `db_port` | no | `5432` | `DB_PORT` | |
| `redis_url` | no | `redis://3b88f413-redis:6379` | `REDIS_URL` | A Redis password must be embedded in the URL (`redis://:password@host:6379`); `REDIS_PASSWORD` is only read for Sentinel setups. |
| `self_hosted` | **yes** | `true` | `SELF_HOSTED` | |
| `rails_force_ssl` | **yes** | `false` | `RAILS_FORCE_SSL` | |
| `rails_assume_ssl` | **yes** | `false` | `RAILS_ASSUME_SSL` | Set to `true` when a reverse proxy terminates TLS in front of the addon. |
| `onboarding_state` | **yes** | `open` | `ONBOARDING_STATE` | `open`, `invite_only` or `closed`. Seeds the value on first boot only — once saved in **Settings > Self-Hosting > Onboarding**, the stored value wins and this option is ignored. |
| `plaid_client_id` | no | — | `PLAID_CLIENT_ID` | See the [Plaid setup guide](https://github.com/we-promise/sure/blob/main/docs/hosting/plaid.md). |
| `plaid_secret` | no | — | `PLAID_SECRET` | |
| `plaid_env` | no | — | `PLAID_ENV` | `production` or `sandbox`. |
| `openai_access_token` | no | — | `OPENAI_ACCESS_TOKEN` | Enabling AI features incurs costs on your OpenAI account. |
| `env_vars` | no | _(empty)_ | _(any)_ | List of `name`/`value` pairs passed straight through as environment variables. See [Custom environment variables](#custom-environment-variables). |

## Custom environment variables

Sure reads more environment variables than this addon exposes as options — SMTP
settings, alternative AI providers, Rails tuning. `env_vars` passes any of them
through without waiting for an addon release:

```yaml
env_vars:
  - name: SMTP_ADDRESS
    value: smtp.example.com
  - name: SMTP_PORT
    value: "587"
```

Notes:

- Names must be letters, digits and underscores, and must not start with a digit.
  The addon refuses to start on anything else rather than silently dropping it.
- They are applied **after** the options above, so an entry reusing one of their
  names (`REDIS_URL`, say) wins. That is the point — it is the escape hatch when
  an option's shape does not fit — but it also means a typo can override
  something that was working.
- Values are not echoed to the addon log, only names, because any of them may be
  a credential.
- Which variables actually do anything is up to Sure, not this addon. See the
  upstream [hosting docs](https://github.com/we-promise/sure/tree/main/docs/hosting).

## Storage

Uploads handled by Active Storage (statements, imports, logos) are written to the addon's persistent `/data/storage`, exposed to the app as `/rails/storage`.

## Architectures

`amd64` and `aarch64`. Upstream publishes `linux/amd64` and `linux/arm64` only.

## License

**GNU AFFERO GENERAL PUBLIC LICENSE Version 3**
