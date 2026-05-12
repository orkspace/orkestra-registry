# Katalog Patterns

Katalog patterns are complete CRD operator definitions — they declare the CustomResourceDefinition, reconcile behavior, admission rules, and status fields for a Kubernetes resource kind.

OCI path: `ghcr.io/orkspace/orkestra-registry/patterns/katalogs/<name>:<version>`

## Structure

```
katalogs/
└── <name>/
    └── <version>/
        ├── katalog.yaml   # Operator declaration (required)
        ├── crd.yaml       # CRD schema (required)
        ├── cr.yaml        # Example Custom Resource
        ├── komposer.yaml  # Example Komposer import
        └── README.md
```

## Available Katalogs

| Pattern | Latest | Description |
|---------|--------|-------------|
| `postgres` | v1.0.0 | PostgreSQL operator with persistent storage and optional pgAdmin |

## Using a Katalog pattern

```bash
# Pull and inspect
ork registry pull postgres

# Import in a Komposer
sources:
  oci:
    - ref: oci://ghcr.io/orkspace/orkestra-registry/patterns/katalogs/postgres:v1.0.0
```
