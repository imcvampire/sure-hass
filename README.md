# Sure (Finances) Addon for Home Assistant

## Introduction

**Sure** is a personal finance management application that helps you track your expenses, income, and investments. This addon enables you to run Sure within Home Assistant as an addon, providing seamless integration into your smart home ecosystem.

### Features

- Track income and expenses
- Monitor investments
- Seamless integration with Home Assistant
- Self-hosted for privacy and control

See the main repository here: [Sure GitHub Repository](https://github.com/we-promise/sure)

> [!NOTE]
> The addon wraps the official `ghcr.io/we-promise/sure` image. Its version is `<addon_version>-<sure_version>`, so **0.6.0-0.7.4** is this addon at 0.6.0 shipping Sure 0.7.4. The left half changes for addon-only fixes, the right half tracks the Sure release.

> [!IMPORTANT]
> This addon was previously published as **Maybe Finance** with the slug `maybe_finance`. It is now `sure`, which Home Assistant treats as a different addon. If you are coming from the old one, see [Migrating from the Maybe Finance addon](#migrating-from-the-maybe-finance-addon).

---

## Installation Guide

Follow these steps to install and set up the Sure addon in Home Assistant:

### 1. Add the Sure Repository

Add the following repository to Home Assistant:

```
https://github.com/imcvampire/sure-hass/
```

### 2. Install PostgreSQL Addon

You need to install the PostgreSQL addon for database storage. Use the following repository:

```
https://github.com/alexbelgium/hassio-addons
```

Once installed, **set a password** for the PostgreSQL addon and start it.

### 3. Install Redis

You need to install the Redis addon. Use the following repository:

```
https://github.com/fabio-garavini/hassio-addons
```

Once installed, **set a password** for the addon and start it.

If you set a Redis password, put it in the URL itself — Sure only reads `REDIS_PASSWORD` when using Redis Sentinel, so a plain `redis_url` must carry the credentials:

```
redis://:YOUR_REDIS_PASSWORD@3b88f413-redis:6379
```

Redis is **required**: Sure runs its background jobs (account syncs, imports, market data, AI features) on Sidekiq, which stores its queues in Redis. The addon starts a Sidekiq worker next to the web server, so without a reachable Redis the addon will not stay up.

Note: The alexbelgium repository also contains a Postgres addon (16), but i had problems with long starting time, thus i recommend the addon by alexbelgium.

### 4. Install the Sure Addon

- Go to **Add-on Store** in Home Assistant.
- Search for **Sure (Finances)** and install it.

### 5. Configure the Addon

- Set a **secure secret key** (this is required for authentication security). Generate one with `openssl rand -hex 64`.
- Use the **same database password** as set in the PostgreSQL addon.
- Point `redis_url` at your Redis addon.
- Pick an `onboarding_state`:
  - `open` — anyone can create an account from the registration page.
  - `invite_only` — signups require a valid invite code.
  - `closed` — the registration page is disabled.

  This option only seeds the value on first boot. Once the setting has been written inside Sure — which happens as soon as anyone saves **Settings > Self-Hosting > Onboarding** — the stored value wins and changing the addon option has no effect. Leave it `open` for the initial setup, create your account, then restrict signups from that settings page.

### 6. Start the Sure Addon

After configuration, start the addon from the Home Assistant interface.

### 7. Access Sure

Once the addon is running, you can access the application at:

```
http://your-home-assistant-ip:1234
```

or

```
http://homeassistant.local:1234
```

Additionally, there is a **button in the addon interface** to open the web UI directly.

---

## Migrating from the Maybe Finance addon

The addon slug changed from `maybe_finance` to `sure`, so Home Assistant will not upgrade the old addon in place — it appears as a new one.

1. Back up your PostgreSQL database before you start.
2. Stop and uninstall the old **Maybe Finance** addon. Leave the PostgreSQL and Redis addons running.
3. Install **Sure (Finances)** and point it at the **same database** (same `db_host`, `db_port`, `postgres_user`, `postgres_password`, `postgres_db`) and the **same `secret_key_base`**. Reusing the secret key matters: it derives the encryption keys for credentials stored in the database.
4. Start the addon. It runs pending migrations on boot.

Two options no longer exist, because Sure removed the features behind them:

| Removed option | Replacement |
| --- | --- |
| `good_job_execution_mode` | None. Sure replaced GoodJob with Sidekiq, and the addon runs the worker for you. |
| `require_invite_code` | `onboarding_state` (`open`, `invite_only`, `closed`) |

Files you uploaded to the old addon (statements, imports, logos) are not carried over; they lived inside the old container. New uploads are stored under the addon's `/data/storage` and survive restarts and updates.

---

## Architectures

- `amd64`
- `aarch64`

Upstream publishes `linux/amd64` and `linux/arm64` only, so `armv7`, `armhf` and `i386` are not supported.

## Contributing

If you find any issues or want to contribute, please visit the repository:
[Sure (Finances) Addon GitHub Repository](https://github.com/imcvampire/sure-hass/)

We welcome contributions in the form of bug reports, feature requests, and pull requests.

- For addon-specific issues or feature requests, please open an issue in the [Sure (Finances) Addon Repository](https://github.com/imcvampire/sure-hass/).
- If you encounter bugs or have feature requests for the **Sure** application itself, please open an issue in the [Main Sure Repository](https://github.com/we-promise/sure).

---

## License

This project is licensed under the **GNU AFFERO GENERAL PUBLIC LICENSE** **Version 3**
