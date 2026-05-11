# Orkestra Registry

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![OCI](https://img.shields.io/badge/OCI-compatible-blue)](https://opencontainers.org/)

A library of reusable, versioned Orkestra building blocks — ready to import into any project.

---

## What's in here

### `motifs/`

Self-contained infrastructure blueprints. A motif describes how to deploy a service (StatefulSet, Services, optional UI) and exposes typed inputs so the caller controls image, resources, storage, and feature flags.

Available motifs:

| Motif | Description |
|-------|-------------|
| `postgres` | PostgreSQL with optional pgAdmin UI |
| `mysql` | MySQL with optional phpMyAdmin UI |
| `mongodb` | MongoDB with optional mongo-express UI |
| `redis` | Redis with optional Redis Commander UI |
| `kafka` | Kafka (KRaft) with optional Kafka UI |
| `rabbitmq` | RabbitMQ with optional management UI service |

All motifs include an `enableUI` input (default: `true`) that gates the management UI deployment and service. Set `enableUI: "false"` to run the data service without any UI.

### `patterns/`

Higher-level operator patterns that compose motifs and CRDs into production-ready stacks. Patterns are published as OCI artifacts and can be imported directly into a Komposer.

### `typed-extensions/`

Optional Go code for advanced use cases that cannot be expressed declaratively — custom hooks, constructors, and reconcilers. Extensions are versioned Go modules referenced via `hooks.location` or `constructor.location` in a Katalog.

---

## Using a motif

Import a motif directly in your Katalog:

```yaml
imports:
  - motif: postgres
    with:
      image: "postgres:16"
      volumeSize: "20Gi"
      enableUI: "false"   # skip pgAdmin in production
```

Or reference a versioned OCI artifact:

```yaml
imports:
  - motif: oci://ghcr.io/orkspace/ork-registry/motifs/postgres:v17
    with:
      image: "postgres:16"
```

---

## Using a pattern

```yaml
sources:
  oci:
    - ref: oci://ghcr.io/orkspace/ork-registry/patterns/postgres:v1.0.0
```

---

## Install Orkestra

```bash
brew install iAlexeze/tap/ork
# or
curl -sSL https://get.orkestra.sh | bash
```

---

## Contributing

- **New motif** — add a directory under `motifs/<name>/` with a `motif.yaml` and a `README.md`.
- **New pattern** — add a directory under `patterns/<name>/` with `katalog.yaml`, `crd.yaml`, and a `README.md`.
- **New extension** — add a versioned Go module under `typed-extensions/`.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for testing, versioning, and review guidelines.

---

## License

Apache-2.0 — same as the [Orkestra runtime](https://github.com/orkspace/orkestra).
