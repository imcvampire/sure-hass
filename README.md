# Sure (Finances) Addon for Home Assistant

## Introduction

**Sure** is a personal finance management application that helps you track your expenses, income, and investments. This addon enables you to run Sure Finances within Home Assistant as an addon, providing seamless integration into your smart home ecosystem.

### Features

- Track income and expenses
- Monitor investments
- Seamless integration with Home Assistant
- Self-hosted for privacy and control

See the main repository here: [Sure GitHub Repository](https://github.com/we-promise/sure)

> [!NOTE]
> The add-on is currently not following the same version numbers as Sure itself but coming from a newer main branch.

---

## Installation Guide

Follow these steps to install and set up the Sure addon in Home Assistant:

### 1. Add the Sure Repository

Add the following repository to Home Assistant:

```
https://github.com/we-promise/sure_finance_hass/
```

### 2. Install PostgreSQL Addon

You need to install the PostgreSQL addon for database storage. Use the following repository:

```
https://github.com/alexbelgium/hassio-addons
```

Once installed, **set a password** for the PostgreSQL addon and start it.

### 3. Install Redis

You need to install the Redis addon for database storage. Use the following repository:

```
https://github.com/fabio-garavini/hassio-addons
```

Once installed, **set a password** for the addon and start it.

Note: This repository also contains a Postgres addon (16), but i had problems with long starting time, thus i recommend the addon by alexbelgium.


### 4. Install the Sure Addon

- Go to **Add-on Store** in Home Assistant.
- Search for **Sure (Finances)** and install it.

### 5. Configure the Addon

- Set a **secure secret key** (this is required for authentication security).
- Use the **same database password** as set in the PostgreSQL addon.

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

Architectures
- amd64
- aarch64
- Currently the build for armv7 is broken, if someone is interested in fixing hit me up.
- i386 seems to be harder since there is no ruby:slim for this architecture.
- The Tailwindcss library used by maybe does not support armhf


## Contributing

If you find any issues or want to contribute, please visit the repository:
[Sure (Finances) Addon GitHub Repository](https://github.com/we-promise/sure_finance_hass/)

We welcome contributions in the form of bug reports, feature requests, and pull requests.

- For addon-specific issues or feature requests, please open an issue in the [Sure (Finances) Addon Repository](https://github.com/we-promise/sure_finance_hass/).
- If you encounter bugs or have feature requests for the **Sure** application itself, please open an issue in the [Main Sure Repository](https://github.com/we-promise/sure).

---

## License

This project is licensed under the **GNU AFFERO GENERAL PUBLIC LICENSE** **Version 3**

