# Patterns

Everything in the Orkestra registry is a **pattern** — a versioned, reusable building block with a specific kind. Patterns are organized by kind in subdirectories here.

```
patterns/
├── katalogs/          # Katalog patterns — full CRD operator definitions
├── motifs/            # Motif patterns — reusable resource blueprints
└── typed-extensions/  # Go hooks and custom reconcilers (advanced)
```

All patterns share the same OCI registry host:

```
ghcr.io/orkspace/orkestra-registry/patterns/<kind>/<name>:<version>
```

Examples:
- `ghcr.io/orkspace/orkestra-registry/patterns/katalogs/postgres:v1.0.0`
- `ghcr.io/orkspace/orkestra-registry/patterns/motifs/postgres:v0.1.0`

---

## Kinds

| Kind | Directory | Description |
|------|-----------|-------------|
| `Katalog` | `katalogs/` | Declares a CRD and its full operator behavior (templates, admission, status) |
| `Motif` | `motifs/` | Reusable resource blueprint imported by Katalogs |
| typed-extension | `typed-extensions/` | Go code for behaviors that can't yet be expressed declaratively |

Future kinds (e.g. `Komposer`) will follow the same structure — a new subdirectory under `patterns/`.
