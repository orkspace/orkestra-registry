# Orkestra Registry

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![OCI](https://img.shields.io/badge/OCI-compatible-blue)](https://opencontainers.org/)

The Orkestra Registry is a library of **declarative operator patterns** – reusable, versioned, and ready to import into your Orkestra runtime. Patterns are distributed as OCI artifacts, making them as easy to share and consume as container images.

---

## Repository Structure

```
orkestra-registry/
├── orkestra-core/               # Production‑ready operator patterns
│   ├── postgres/
│   │   └── v14/
│   │       ├── crd.yaml         # CustomResourceDefinition
│   │       ├── katalog.yaml     # Operator behavior
│   │       ├── komposer.yaml    # Example import + overrides
│   │       ├── cr.yaml          # Example Custom Resource
│   │       └── README.md        # Pattern documentation
│   └── ...
├── typed-extensions/            # Go hooks and custom reconcilers (optional)
│   ├── hooks/
│   │   └── postgres-hooks/
│   │       └── v1.0.0/
│   │           ├── go.mod
│   │           ├── hooks.go
│   │           └── README.md
│   └── constructors/
│       └── ...
├── CONTRIBUTING.md
└── LICENSE
```

### `orkestra-core/`

Complete operator patterns. Each pattern is a self‑contained directory with five required files:

- `crd.yaml` – the CustomResourceDefinition to install.
- `katalog.yaml` – the declarative operator definition (templates, dependencies, conversion rules).
- `komposer.yaml` – an example Komposer showing how to import and override the pattern.
- `cr.yaml` – an example Custom Resource to test the pattern.
- `README.md` – documentation of the pattern’s behaviour and configurable options.

Patterns are automatically published to an OCI registry (e.g., `ghcr.io/orkestra-sh/orkestra-registry`) on every release. Users can import them directly in a Komposer:

```yaml
sources:
  oci:
    - ref: oci://ghcr.io/orkestra-sh/orkestra-registry/postgres:v14
```

See the [orkestra-core README](./orkestra-core/README.md) for detailed usage.

### `typed-extensions/`

Optional Go code for advanced use cases that cannot yet be expressed declaratively. Extensions are versioned Go modules that can be referenced in a Katalog via `hooks.location` or `constructor.location`.

When a typed extension becomes widely used, it may be promoted to a declarative pattern in `orkestra-core/`. See the [typed‑extensions README](./typed-extensions/README.md) for guidelines.

---

## How to Use a Pattern

### 1. Install Orkestra

```bash
brew install iAlexeze/tap/ork
# or curl -sSL https://raw.githubusercontent.com/orkestra-sh/orkestra/main/install.sh | bash
```

### 2. Reference a Pattern in a Komposer

```yaml
apiVersion: orkestra.konductor.io/v1Alpha
kind: Komposer
sources:
  oci:
    - ref: oci://ghcr.io/orkestra-sh/orkestra-registry/postgres:v14
spec:
  crds:
    - name: postgres
      workers: 8          # override
```

### 3. Run Orkestra

```bash
ork run --katalog komposer.yaml
```

Orkestra fetches the pattern, merges your overrides, and starts the operator.

---

## Contributing

We welcome contributions of new patterns, improvements to existing ones, and typed extensions.

- **Add a new pattern**: Create a directory under `orkestra-core/<name>/<version>/` with the required files.
- **Add a typed extension**: Create a directory under `typed-extensions/hooks/<name>/<version>/` (or `constructors/`).
- **Promote a typed extension**: Open an issue to discuss promotion to a declarative pattern.

See **[CONTRIBUTING.md](./CONTRIBUTING.md)** for full guidelines, including testing, versioning, and the promotion process.

---

## License

All patterns in this repository are licensed under the [MIT License](LICENSE), the same license as the [Orkestra runtime](https://github.com/orkspace/orkestra).

---

**Built with ❤️ for the Kubernetes ecosystem.** 🎼