# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ready-to-run TYPO3 v14 demonstration with the official Camino theme. This is a **deployment/distribution repository** - not a development environment. The actual TYPO3 application code is generated at Docker build time via Composer.

**Stack:** TYPO3 v14, PHP 8.3, Apache 2.4, MariaDB 11, Docker

## Common Commands

```bash
# Start services (uses pre-built image from GitHub Container Registry)
docker-compose up -d

# Build and start locally (for testing Dockerfile changes)
docker-compose up -d --build

# Build image directly
docker build -t typo3-camino-demo .

# View logs
docker-compose logs -f typo3
docker-compose logs -f db

# Stop and remove containers
docker-compose down

# Full cleanup including volumes
docker-compose down -v
```

## Architecture

```
Repository Files (what you edit):
├── Dockerfile           # Multi-stage PHP 8.3 + Apache build
├── entrypoint.sh        # First-start TYPO3 setup logic
├── docker-compose.yml   # Local development orchestration
├── elestio/             # Elestio deployment variant
└── .github/workflows/   # CI/CD for ghcr.io publishing

Generated at build time (inside container):
/var/www/html/
├── public/              # Web root (Apache DocumentRoot)
├── vendor/              # Composer dependencies
├── config/              # TYPO3 site configuration
└── var/                 # Cache, logs, session data
```

## Key Implementation Details

**First-start initialization** (`entrypoint.sh`):
- Waits for MariaDB to be ready
- Runs `./vendor/bin/typo3 setup` with environment variables
- Creates site config at `config/sites/main/config.yaml` with Camino theme dependency
- Creates `.installed` marker to prevent re-running on subsequent starts

**Persistent volumes** (defined in docker-compose.yml):
- `typo3_fileadmin` - uploaded files
- `typo3_var` - cache and session data
- `typo3_config` - site configuration
- `db_data` - database files

**CI/CD** (`.github/workflows/build.yml`):
- Triggers on push to main, weekly schedule, or manual dispatch
- Builds multi-platform images (amd64, arm64)
- Publishes to `ghcr.io/dkd-internet-service/typo3-camino-demo`

## Environment Variables

Configure via `.env` file (copy from `.env.example`):

| Variable | Default | Purpose |
|----------|---------|---------|
| `DB_ROOT_PASSWORD` | `rootsecret` | MariaDB root password |
| `DB_PASSWORD` | `typo3secret` | Application database password |
| `ADMIN_PASSWORD` | `Admin123!` | TYPO3 backend admin password |
| `BASE_URL` | `/` | Site base URL (use full URL for HTTPS) |
| `PORT` | `80` | Host port mapping |

## Access Points

After `docker-compose up -d` (wait ~30 seconds for initial setup):
- **Frontend:** http://localhost
- **Backend:** http://localhost/typo3 (default: `admin` / `Admin123!`)
