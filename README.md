# TYPO3 v14 Camino Demo

Ready-to-run TYPO3 v14 with the official Camino theme – perfect for demos and evaluation by non-technical users.

## Quick Start (Local)

```bash
# Clone the repository
git clone https://github.com/dkd-dobberkau/typo3-camino-demo.git
cd typo3-camino-demo

# Copy and adjust environment variables
cp .env.example .env

# Start the containers
docker-compose up -d

# Wait ~30 seconds for initial setup
```

Open your browser:
- **Frontend:** http://localhost
- **Backend:** http://localhost/typo3

Default credentials: `admin` / `Admin123!`

## Deploy to Elestio

1. Go to [Elestio](https://elest.io) and create a new service
2. Choose "Deploy my own docker-compose"
3. Paste the content of `docker-compose.yml`
4. Set the environment variables in Elestio's interface
5. Deploy!

## Docker Image

The image is automatically built and published to GitHub Container Registry:

```
ghcr.io/dkd-dobberkau/typo3-camino-demo:latest
```

### Available Tags

| Tag | Description |
|-----|-------------|
| `latest` | Latest stable build |
| `14` | TYPO3 v14 series |
| `YYYYMMDD` | Date-based builds (from scheduled builds) |
| `sha-xxxxxx` | Specific commit builds |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_ROOT_PASSWORD` | `rootsecret` | MariaDB root password |
| `DB_NAME` | `typo3` | Database name |
| `DB_USER` | `typo3` | Database user |
| `DB_PASSWORD` | `typo3secret` | Database password |
| `ADMIN_USER` | `admin` | TYPO3 admin username |
| `ADMIN_PASSWORD` | `Admin123!` | TYPO3 admin password |
| `ADMIN_EMAIL` | `admin@example.com` | TYPO3 admin email |
| `PROJECT_NAME` | `TYPO3 v14 Camino Demo` | Project name shown in backend |
| `BASE_URL` | `/` | Base URL for the site |
| `PORT` | `80` | HTTP port |

## What's Included

- **TYPO3 v14** (latest stable)
- **Camino Theme** – the official TYPO3 v14 default theme
- **MariaDB 11** – production-ready database
- **Apache 2.4** with mod_rewrite enabled
- **PHP 8.3** with all required extensions

## Building Locally

```bash
# Build the image
docker-compose build

# Or build directly
docker build -t typo3-camino-demo .
```

## Automatic Updates

The GitHub Action rebuilds the image:
- On every push to `main`
- Weekly (every Sunday at 3:00 UTC)
- Manually via workflow dispatch

This ensures the demo always runs the latest TYPO3 patch versions.

## License

This project is licensed under the GPL-2.0-or-later license, same as TYPO3 CMS.

## Credits

- [TYPO3 CMS](https://typo3.org)
- [Camino Theme](https://packagist.org/packages/typo3/theme-camino)
- Built by [dkd Internet Service GmbH](https://www.dkd.de)
