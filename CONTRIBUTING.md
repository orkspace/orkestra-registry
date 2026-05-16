# Contributing to the Orkestra Registry

The Orkestra Registry is a community-driven library of declarative operator patterns. Contributions that help operators deploy faster and more reliably are always welcome.

## Ways to contribute

- **Add a Katalog** — a complete CRD operator (declarative or typed)
- **Add a Motif** — a reusable resource blueprint imported by Katalogs
- **Improve an existing pattern** — fix bugs, improve templates, improve documentation
- **Add a typed extension** — Go hooks or constructors for behavior that can't yet be expressed declaratively

---

## Pattern file structure

Every pattern lives in its own directory. The directory name becomes the registry artifact name.

### Katalog

```
patterns/katalogs/<name>/
  katalog.yaml     # required — the operator definition
  crd.yaml         # optional — the CustomResourceDefinition
  cr.yaml          # optional — an example Custom Resource
  e2e.yaml         # optional — declarative end-to-end tests
  README.md        # optional — shown in the registry UI
```

| File | Description |
|------|-------------|
| `katalog.yaml` | Required. The Orkestra Katalog spec (`kind: Katalog`). |
| `crd.yaml` | The CRD YAML. Included in pushed artifacts so consumers can install it independently. |
| `cr.yaml` | An example CR showing the minimal fields needed to instantiate the operator. |
| `e2e.yaml` | Declarative E2E tests. When present, `ork registry push` runs these as a gate before publishing. |
| `README.md` | Shown in `ork registry info` and the registry web UI. Explain what the pattern does and how to configure it. |

### Motif

```
patterns/motifs/<name>/
  motif.yaml       # required — the Motif spec
  README.md        # optional — shown in the registry UI
  example/
    katalog.yaml   # optional — example Katalog importing this Motif
```

### Typed extension

```
patterns/typed-extensions/hooks/<name>/
  <name>.go        # required — exported hook function
  go.mod           # required — Go module
  README.md        # required — usage instructions

patterns/typed-extensions/constructors/<name>/
  <name>.go        # required — exported constructor function
  go.mod           # required
  README.md        # required
```

---

## Adding a Katalog

### 1. Create the directory

```
patterns/katalogs/<your-name>/
```

Use lowercase, hyphen-separated names (e.g. `postgres`, `nginx-ingress`, `cert-manager`).

### 2. Write `katalog.yaml`

Follow the [Katalog schema](https://docs.orkestra.sh/reference/schema/katalog). At minimum:

```yaml
apiVersion: orkestra.orkspace.io/v1
kind: Katalog
metadata:
  name: <your-name>
spec:
  crds:
    <name>:
      apiTypes:
        group: example.io
        version: v1alpha1
        kind: MyResource
        plural: myresources
      operatorBox:
        ...
```

### 3. Add `e2e.yaml` (strongly recommended)

E2E tests gate registry publication. Without `e2e.yaml`, anyone can push with `--no-e2e`. With it, tests run automatically on every `ork registry push` — and in CI via the Orkestra GitHub Action.

```yaml
apiVersion: orkestra.orkspace.io/v1
kind: E2E
metadata:
  name: <your-name>-e2e

spec:
  katalog: ./katalog.yaml
  crd: ./crd.yaml
  cr: ./cr.yaml

  cluster:
    provider: kind
    name: ork-e2e
    reuse: false

  expect:
    - name: Resource created
      after: cr-applied
      timeout: 60s
      resources:
        - kind: Deployment
          namespace: default
          ready: true

    - name: Resource removed
      after: cr-deleted
      timeout: 30s
      resources:
        - kind: Deployment
          namespace: default
          count: 0
```

### 4. Test locally

```sh
# Validate the katalog
ork validate -f patterns/katalogs/<name>/katalog.yaml

# Run e2e
ork e2e -f patterns/katalogs/<name>/e2e.yaml

# Push to the registry (runs e2e gate automatically)
ork registry push <name>:v1.0.0 patterns/katalogs/<name>/
```

### 5. Open a pull request

CI validates the pattern. On merge, the pattern is automatically published to `ghcr.io/orkspace/orkestra-registry`.

---

## Adding a Motif

### 1. Create the directory

```
patterns/motifs/<your-name>/
```

### 2. Write `motif.yaml`

Follow the [Motif schema](https://docs.orkestra.sh/reference/schema/motif). Declare your inputs clearly — they are the public interface of the Motif.

```yaml
apiVersion: orkestra.orkspace.io/v1
kind: Motif
metadata:
  name: <your-name>
  version: v1
  description: One-line description.
  author: your-github-handle

inputs:
  - name: image
    required: true
    description: Container image (e.g. postgres:16)

  - name: volumeSize
    default: "10Gi"
    description: PVC storage size

resources:
  statefulsets:
    - name: "{{ .metadata.name }}"
      image: "{{ inputs.image }}"
      ...
```

### 3. Write a `README.md`

Include:
- What the Motif provisions
- All `inputs` — name, type, default, description
- An example `imports:` block showing how to use it in a Katalog

### 4. Open a pull request

---

## Adding a Typed Extension

Typed extensions are Go functions (hooks or constructors) for behaviors that can't yet be expressed declaratively.

### Hook signature

```go
func() domain.AnyReconcileHooks
```

### Constructor signature

```go
func(kube *kubeclient.Kubeclient, inf cache.SharedIndexInformer, ev *event.Event) domain.Reconciler
```

Include a `README.md` explaining what the extension does, how to wire it into a Katalog via `ork generate registry`, and any configuration needed.

---

## The e2e gate

`ork registry push` automatically detects `e2e.yaml` in the pattern directory and runs it before publishing. If the tests fail, the push is blocked.

```sh
# Normal push — runs e2e.yaml if present
ork registry push postgres:v1.0.0 patterns/katalogs/postgres/

# Skip the gate (CI already ran it)
ork registry push postgres:v1.0.0 patterns/katalogs/postgres/ --no-e2e

# Override failures (not recommended for community patterns)
ork registry push postgres:v1.0.0 patterns/katalogs/postgres/ --force
```

All community patterns submitted via PR must pass e2e in CI before merging.

---

## CI with the Orkestra GitHub Action

The Orkestra Action handles install, validate, e2e, and publish in one step. No scripts needed.

```yaml
name: Publish pattern

on:
  push:
    tags: ["v*"]

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      packages: write
    steps:
      - uses: actions/checkout@v4

      - uses: orkspace/orkestra-action@v1
        with:
          validate: ./katalog.yaml
          e2e: ./e2e.yaml
          registry-push: "postgres:${{ github.ref_name }} ."
          registry-url: ghcr.io/${{ github.repository_owner }}/patterns
          registry-username: ${{ github.actor }}
          registry-password: ${{ secrets.GITHUB_TOKEN }}
```

---

## Versioning

Patterns follow semantic versioning.

| Version bump | When |
|-------------|------|
| `v1.0.0` | Initial stable release |
| `v1.1.0` | New inputs or resources (backward compatible) |
| `v2.0.0` | Breaking input changes or resource restructuring |

Each version is a separate OCI tag. Do not overwrite an existing version — create a new tag.

If a new version changes required inputs, document the migration in `README.md`.

---

## Promoting a typed extension to declarative

When a typed extension can be expressed declaratively:

1. Open an issue with the proposed YAML schema and examples.
2. Implement the pattern under `patterns/katalogs/` or `patterns/motifs/`.
3. Add a deprecation note in the extension's `README.md` pointing to the new pattern.
4. After a deprecation window, the typed extension may be removed.

---

## Questions

Open a [GitHub Discussion](https://github.com/orkspace/orkestra-registry/discussions).

## License

By contributing you agree that your contributions will be licensed under the [Apache-2.0 License](LICENSE).
