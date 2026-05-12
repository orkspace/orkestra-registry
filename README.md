# Orkestra Registry

[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)
[![OCI](https://img.shields.io/badge/OCI-compatible-blue)](https://opencontainers.org/)

A library of reusable, versioned Orkestra **patterns** — ready to import into any project.

---

## One mental model: everything is a pattern

In Orkestra, all reusable building blocks are patterns. A pattern has a **kind** that describes what it is and how it behaves:

| Kind | What it is |
|------|-----------|
| `Katalog` | A complete CRD operator — defines the CRD, its reconcile behavior, admission rules, and status |
| `Motif` | A reusable resource blueprint imported by Katalogs |
| typed-extension | Go code for behaviors that can't yet be expressed declaratively |

All patterns live under `patterns/` organized by kind:

```
patterns/
├── katalogs/          # ghcr.io/orkspace/orkestra-registry/patterns/katalogs/<name>:<version>
├── motifs/            # ghcr.io/orkspace/orkestra-registry/patterns/motifs/<name>:<version>
└── typed-extensions/
```

---

## Using a Katalog pattern

Import in a Komposer:

```yaml
sources:
  oci:
    - ref: oci://ghcr.io/orkspace/orkestra-registry/patterns/katalogs/postgres:v1.0.0
```

Or via the CLI:

```bash
ork registry pull postgres
```

---

## Using a Motif pattern

Import in a Katalog's CRD entry:

```yaml
spec:
  crds:
    database:
      imports:
        - motif: oci://ghcr.io/orkspace/orkestra-registry/patterns/motifs/postgres:v0.1.0
          with:
            image: "postgres:16"
            volumeSize: "20Gi"
            enableUI: "false"
```

Or use a bare name — Orkestra resolves it against the default motif registry:

```yaml
imports:
  - motif: postgres
    with:
      image: "postgres:16"
```

---

## Available patterns

### Katalogs (`patterns/katalogs/`)

| Pattern | Description |
|---------|-------------|
| `postgres` | PostgreSQL operator with persistent storage and optional pgAdmin |

### Motifs (`patterns/motifs/`)

| Motif | Description |
|-------|-------------|
| `postgres` | PostgreSQL StatefulSet, services, storage, pgAdmin |
| `mysql` | MySQL StatefulSet, services, storage, phpMyAdmin |
| `mongodb` | MongoDB StatefulSet, services, storage, mongo-express |
| `redis` | Redis StatefulSet, services, storage, Redis Commander |
| `kafka` | Kafka (KRaft) StatefulSet, services, storage, Kafka UI |
| `rabbitmq` | RabbitMQ StatefulSet, services, storage, management UI |
| `deployment-stack` | Generic Deployment + Service + Ingress blueprint |

---

## Install Orkestra

```bash
brew install iAlexeze/tap/ork
# or
curl -sSL https://get.orkestra.sh | bash
```

---

## Contributing

- **New Katalog** — add a directory under `patterns/katalogs/<name>/<version>/` with `katalog.yaml`, `crd.yaml`, `cr.yaml`, and a `README.md`.
- **New Motif** — add a directory under `patterns/motifs/<name>/` with a `motif.yaml` and a `README.md`.
- **New typed-extension** — add a versioned Go module under `patterns/typed-extensions/`.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for testing, versioning, and review guidelines.

---

## License

Apache-2.0 — same as the [Orkestra runtime](https://github.com/orkspace/orkestra).
