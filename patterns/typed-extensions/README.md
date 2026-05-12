# Typed Extensions – Go Hooks and Custom Reconcilers

This directory contains optional Go code for operator patterns that cannot yet be expressed declaratively. Extensions are versioned Go modules that users can reference in their Katalogs.

## Structure

```
typed-extensions/
├── hooks/                # Go hooks (OnReconcile, OnDelete)
│   └── <name>/
│       └── <version>/
│           ├── go.mod
│           ├── hooks.go      # Exports a function returning domain.AnyReconcileHooks
│           └── README.md
└── constructors/         # Custom reconciler constructors
    └── <name>/
        └── <version>/
            ├── go.mod
            ├── constructor.go
            └── README.md
```

## Using a Typed Extension

In your Katalog, reference the extension:

```yaml
reconciler:
  hooks:
    location: github.com/orkspace/orkestra-registry/typed-extensions/hooks/postgres-hooks@v1.0.0
    function: PostgresHooks
```

Then run `ork generate runtime` to wire the typed code. After generation, run Orkestra as usual.

## Adding a Typed Extension

1. Choose a name and version.
2. Create the directory `typed-extensions/hooks/<name>/<version>/` (or `constructors/`).
3. Write a Go module with the required export.
4. Add a `README.md` explaining the extension’s purpose and usage.
5. Open a pull request.

## Promotion to Declarative

When a typed extension becomes widely used and can be expressed declaratively, it may be promoted to a core Katalog pattern. The promotion process:

1. Open an issue to discuss the declarative representation.
2. Implement the pattern in `orkestra-core/` with the standard files.
3. Deprecate the typed extension by updating its `README.md` to point to the new declarative pattern.
4. After a suitable deprecation period, the typed extension may be removed.
