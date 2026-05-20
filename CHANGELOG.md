# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Pin `dkd-dobberkau/fal-photo-browser` to `^1.1` in `Dockerfile` so builds
  are reproducible. Previously the package was required without a constraint,
  letting Composer pick whatever was newest at build time.
- Bump `enhancely/enhancely-for-typo3` constraint floor from `^1.2.0` to
  `^1.4.0` to reflect the actually installed minor (1.4.7). Still allows any
  update up to but not including 2.0.

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
