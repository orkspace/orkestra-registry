# Changelog

All notable changes to Orkestra are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Orkestra Registry (initial structure)** — introduced the foundation for distributing operator patterns through Git and OCI registries.
  - Defined registry layout for core patterns and typed extensions.
  - Added documentation describing pattern structure, versioning, and publishing workflow.
  - Added `CHANGELOG.md` and `CONTRIBUTING.md` for registry contributors.
- **Postgres Pattern v1.0.0** — published the first minimal declarative operator pattern.
  - Includes CRD, Katalog, Komposer metadata, README, and example CR.
  - Supports arbitrary PostgreSQL versions via `spec.version` with a default of `14`.
  - Provides a simple Deployment + Service reconciliation model suitable for development and controlled production environments.

### Changed

- Improved documentation around pattern authoring, distribution, and consumption.
- Updated internal references to support registry-based pattern discovery.

### Fixed

- None for this release.

### Security

- No security changes in this release.
