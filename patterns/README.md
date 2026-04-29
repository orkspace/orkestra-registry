# Orkestra Core – Reusable Operator Patterns

This directory contains source definitions for versioned, production‑ready operator patterns. Patterns are published as OCI artifacts; the folders here are the canonical source, not the distribution format.

Each pattern is a complete declarative definition of how a CRD should behave.

---

## Structure

```
orkestra-core/
└── <pattern-name>/
    ├── crd.yaml          # CustomResourceDefinition to install
    ├── katalog.yaml      # Operator behavior (templates, dependencies, conversion)
    ├── komposer.yaml     # Example import with overrides
    ├── cr.yaml           # Example Custom Resource
    └── README.md         # Pattern documentation
```

[Note] 
Versions are not tracked by folders. Versioning is handled by the CI pipeline, which packages the contents of the directory and publishes it as an OCI artifact tagged with the version. The folder itself represents the latest state of the pattern; each release creates a new immutable artifact.

---

## Using a Pattern

### 1. Install the CRD

```bash
kubectl apply -f https://raw.githubusercontent.com/orkestra-sh/orkestra-registry/main/orkestra-core/postgres/crd.yaml
```

### 2. Import the Pattern in a Komposer

```yaml
sources:
  oci:
    - ref: oci://ghcr.io/orkestra-sh/orkestra-registry/postgres:v14
```

### 3. Override Fields (Optional)

```yaml
spec:
  crds:
    - name: postgres
      workers: 8
      reconciler:
        onCreate:
          deployments:
            - image: "{{ .spec.image }}"
              replicas: "{{ .spec.replicas }}"
```

### 4. Run Orkestra

```bash
ork run --katalog komposer.yaml
```

---

## Adding a New Pattern

1. Choose a pattern name (lower‑cased, matches the CRD kind).
2. Create the directory `orkestra-core/<name>/`.
3. Add the five required files (see existing patterns for examples).
4. Test your pattern locally with Orkestra.
5. Open a pull request. The CI pipeline will:
   - Validate the pattern.
   - On merge, create a new tag (e.g., `postgres-v1.0.0`).
   - Package the directory contents into an OCI artifact.
   - Push to `ghcr.io/orkestra-sh/orkestra-registry/<name>:<tag>`.
   - Register the artifact with Artifact Hub for discoverability.

---

## Versioning and Conversion

Patterns follow semantic versioning. The CI pipeline creates tags based on the pattern name and a version number (e.g., `postgres-v1.0.0`). When a new version introduces breaking changes, include **declarative conversion rules** in `katalog.yaml` to convert between versions.

Upgrading is as simple as changing the version tag in your Komposer and restarting Orkestra. The runtime handles conversion automatically.

---

## Discoverability

All published patterns are indexed in **Artifact Hub**. Users can discover them via:

- `ork registry search <pattern>` (planned)
- Artifact Hub UI
- Direct OCI references

---

## Contributing

See the main [CONTRIBUTING.md](../CONTRIBUTING.md#adding-a-new-pattern) for guidelines on adding or updating patterns. The process is:

1. Fork the repository.
2. Add or update a pattern directory.
3. Submit a pull request.
4. After review, a maintainer will tag the release and trigger the OCI publish workflow.