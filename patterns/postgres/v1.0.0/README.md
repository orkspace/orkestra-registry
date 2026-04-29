# Postgres Operator Pattern (v1.0.0)

A lightweight, declarative pattern for managing PostgreSQL instances on Kubernetes using Orkestra.  
This pattern defines a simple `Postgres` CustomResource with version, database name, and user fields, suitable for development, testing, and small production environments.

---

## Field Reference

| Field | Type | Default | Description |
|-------|------|----------|-------------|
| `spec.version` | string | `"14"` | PostgreSQL major version to deploy. Must match an available image tag. |
| `spec.database` | string | _required_ | Name of the primary database to create. |
| `spec.user` | string | _required_ | Name of the default user to provision. |

---

## Quick Start

1. **Install the CRD**

   ```bash
   kubectl apply -f crd.yaml
   ```

2. **Apply the Katalog**

   ```bash
   ork apply katalog.yaml
   ```

3. **Create a Postgres instance**

   ```bash
   kubectl apply -f cr.yaml
   ```

After a few seconds, Orkestra will reconcile the instance and create the required Kubernetes resources (Deployment, Service, ConfigMap, Secret, etc., depending on the pattern implementation).

---

## Recommended Production Overrides

These fields should be explicitly set when running outside development:

| Field | Why |
|-------|------|
| `spec.version` | Pin to a specific major version to avoid unexpected upgrades. |
| `spec.database` | Use a non-default database name to avoid collisions. |
| `spec.user` | Use a dedicated application user rather than a shared account. |

Additional production considerations (depending on your environment):

- Configure persistent storage (PVCs) instead of ephemeral volumes.
- Use a managed Secret store (e.g., external Secrets) for credentials.
- Enable network policies to restrict access to the database.
- Set resource requests/limits appropriate for your workload.

---

## Known Limitations

This pattern intentionally focuses on simplicity. It does **not** provide:

- High availability or automatic failover.
- Backup/restore automation.
- Connection pooling (e.g., PgBouncer).
- Major version upgrade automation.
- Replication or sharding.
- TLS configuration.

These features can be added in future pattern versions or layered on top using additional Orkestra Katalogs.

---

## Version History

### v1.0.0
- Initial release of the Postgres pattern.
- Defines the `Postgres` CRD with `version`, `database`, and `user` fields.
- Provides a minimal, declarative interface for running PostgreSQL on Kubernetes.
