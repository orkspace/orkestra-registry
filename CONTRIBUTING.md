# Contributing to the Orkestra Registry

Thank you for your interest in contributing! The Orkestra Registry is a community‑driven library of declarative operator patterns. Your contributions help make operator development faster and more accessible.

## Ways to Contribute

- **Add a new pattern** – create a versioned directory under `orkestra-core/` with the required files.
- **Improve an existing pattern** – fix bugs, enhance templates, improve documentation.
- **Add a typed extension** – write Go hooks or custom reconcilers in `typed-extensions/`.
- **Promote a typed extension** – help turn a successful typed extension into a declarative pattern.

## Adding a New Pattern

### 1. Choose a name and version

Patterns are stored under `orkestra-core/<pattern-name>/<version>/`. Use semantic versioning (e.g., `v1.0.0`). The pattern name should be lower‑cased and match the CRD’s kind.

### 2. Create the required files

Each version directory must contain:

- `crd.yaml` – the CustomResourceDefinition.
- `katalog.yaml` – the declarative operator definition.
- `komposer.yaml` – an example Komposer showing import and overrides.
- `cr.yaml` – an example Custom Resource.
- `README.md` – documentation.

See the `postgres/v14` example for reference.

### 3. Test locally

- Install the CRD: `kubectl apply -f crd.yaml`.
- Run Orkestra with your pattern: `ork run --katalog komposer.yaml`.
- Apply the example CR: `kubectl apply -f cr.yaml`.
- Verify that the expected resources are created.

### 4. Open a pull request

The CI will validate the pattern and, if merged, automatically publish it as an OCI artifact to `ghcr.io/orkestra-sh/orkestra-registry`.

## Adding a Typed Extension

### 1. Choose a name and version

Extensions live under `typed-extensions/hooks/<name>/<version>/` or `typed-extensions/constructors/<name>/<version>/`. Versioning follows semantic versioning.

### 2. Write the Go code

Create a Go module with a `go.mod` file. The exported function must match the expected signature:

- For hooks: `func() domain.AnyReconcileHooks`
- For constructors: `func(kube *kubeclient.Kubeclient, inf cache.SharedIndexInformer, ev *event.Event) domain.Reconciler`

### 3. Add a `README.md`

Explain what the extension does, how to use it, and any configuration needed.

### 4. Test

Test the extension with a Katalog that references it. Run `ork generate runtime` and then `ork run`.

### 5. Open a pull request

## Promoting a Typed Extension to Declarative

When a typed extension has proven useful and can be expressed declaratively, it can be promoted:

1. **Open an issue** to discuss the declarative representation. Include examples of the extension’s usage and propose a YAML schema.
2. **Implement the pattern** in `orkestra-core/` following the standard format.
3. **Deprecate the typed extension** by adding a note in its `README.md` and pointing to the new declarative pattern.
4. **After a deprecation period**, the typed extension may be removed.

## Versioning

Patterns and typed extensions follow semantic versioning:

- **v1.0.0** – initial stable release.
- **v1.1.0** – new features (backward compatible).
- **v2.0.0** – breaking changes (requires conversion rules in the Katalog).

When updating a pattern, create a new version directory. Do not modify existing version directories.

## Testing

All contributions should be tested. For patterns, include a test Komposer and CR. For typed extensions, include unit tests for the Go code.

## Community and Review

All contributions are reviewed by maintainers. Please be patient; we will respond as soon as possible.

For questions or suggestions, open a [GitHub Discussion](https://github.com/orkestra-sh/orkestra-registry/discussions).

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE), the same license as the [Orkestra runtime](https://github.com/orkestra-sh/orkestra).

**Thank you for helping build the future of declarative operators!** 🎼