# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `flowd/typo3-firewall:^0.3.0` — PSR-15 middleware that protects the site
  against malicious requests. Pulls in `flowd/phirewall:^0.4.0` as a
  transitive dependency.
- Local sitepackage `packages/firewall-logger` (`dkd/firewall-logger`) that
  registers a PSR-14 listener for `Flowd\Phirewall\Events\BlocklistMatched`
  and writes a structured `warning` entry to the TYPO3 logger (rule, method,
  URI, client_ip from `X-Forwarded-For`, remote_addr, user_agent, referer).
  Lets blocked requests show up in `var/log/typo3_*.log` for later
  forwarding to Loki/ELK. Uses `warning` (not `notice`) because the TYPO3
  default `FileWriter` threshold drops `notice`.

### Changed

- Pin `dkd-dobberkau/fal-photo-browser` to `^1.1` in `Dockerfile` so builds
  are reproducible. Previously the package was required without a constraint,
  letting Composer pick whatever was newest at build time.
- Bump `enhancely/enhancely-for-typo3` constraint floor from `^1.2.0` to
  `^1.4.0` to reflect the actually installed minor (1.4.7). Still allows any
  update up to but not including 2.0.
- Unset the `config.platform.php = 8.2.0` override that
  `typo3/cms-base-distribution` writes into `composer.json`. The container
  PHP is 8.3.x and the override was blocking packages that require
  `php >=8.3` (e.g. `flowd/typo3-firewall`).
- Install the `locales` package and generate `en_US.UTF-8` in the image,
  with `LANG`/`LC_ALL`/`LANGUAGE` set as env vars. Stops the recurring
  `Locale "en_US.UTF-8" not found` errors in `var/log/typo3_*.log` that
  the site config (`languages[0].locale = en_US.UTF-8`) triggers on every
  request.

### Added

- Local TYPO3 sitepackage `packages/og-meta` (`dkd/og-meta`) that emits
  `og:site_name` (from `site:websiteTitle`) and `og:title` (from `page:title`)
  meta tags, so external JSON-LD crawlers such as Enhancely can distinguish
  site brand from per-page title instead of conflating them via the HTML
  `<title>` tag.
- Environment variable `WEBSITE_TITLE` (default: `Camino de Compostela`)
  controls the frontend brand name and is propagated to `og:site_name`.
  Distinct from `PROJECT_NAME`, which remains the backend admin label.

### Changed

- `entrypoint.sh` generates the initial site config with explicit
  `websiteTitle` and includes `dkd/og-meta` in the site dependencies.
- `Dockerfile` copies `packages/` into the image and requires
  `dkd/og-meta:^1.0` via the path repository that
  `typo3/cms-base-distribution` registers as `./packages/*`.
