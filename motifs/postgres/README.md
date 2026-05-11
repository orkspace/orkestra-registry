# PostgreSQL Motif

Deploys a production-ready PostgreSQL instance with persistent storage, DNS-stable pod identity, and a pgAdmin management console.

## What Gets Created

| Resource | Name Pattern | Purpose |
|---|---|---|
| StatefulSet | `<name>-postgres` | PostgreSQL pods with stable pod DNS |
| Service (headless) | `<name>-postgres-headless` | Pod DNS via `<name>-postgres-0.<name>-postgres-headless` |
| Service (client) | `<name>-postgres` | Stable ClusterIP for application connections |
| Service (UI) | `<name>-pgadmin-svc` | LoadBalancer for pgAdmin web UI |
| Deployment | `<name>-pgadmin` | pgAdmin 4 management console |
| PVC (per pod) | `data-<name>-postgres-0` | Provisioned by StorageClass |

## Inputs

| Name | Default | Description |
|---|---|---|
| `image` | `postgres:latest` | PostgreSQL container image |
| `replicas` | `1` | Number of replicas |
| `resourceProfile` | `standard` | CPU/memory profile |
| `volumeSize` | `10Gi` | PVC size per pod |
| `storageClass` | `standard` | StorageClass for dynamic provisioning |
| `database` | `app` | Default database name |
| `username` | `postgres` | PostgreSQL superuser name |
| `pgAdminImage` | `dpage/pgadmin4:latest` | pgAdmin image |

## Probes

| Probe | Type | Profile | Notes |
|---|---|---|---|
| startup | TCP :5432 | `slow-start` | 5-minute window for initialization |
| liveness | TCP :5432 | `standard` | Detects frozen/dead process |
| readiness | TCP :5432 | `standard` | Gates traffic until accepting connections |
| pgAdmin liveness | HTTP `/misc/ping` | `standard` | |
| pgAdmin readiness | HTTP `/misc/ping` | `standard` | |

## Status Fields

| Field | Value |
|---|---|
| `postgresReady` | True when all replicas are ready |
| `connectionString` | `postgresql://<user>@<svc>.<ns>.svc.cluster.local:5432/<db>` |
| `pgAdminUrl` | `http://<pgadmin-svc>.<ns>.svc.cluster.local` |

## Usage in a Katalog

```yaml
operatorBox:
  onCreate:
    motifs:
      - ref: ghcr.io/orkspace/orkestra-registry/motifs/postgres@v17
        inputs:
          database: "{{ .spec.dbName | default \"app\" }}"
          volumeSize: "{{ .spec.storageSize | default \"10Gi\" }}"
          storageClass: "{{ .spec.storageClass | default \"standard\" }}"
          resourceProfile: "{{ .spec.resourceProfile | default \"standard\" }}"
```

## Pod DNS

Each pod is reachable at:
```
<name>-postgres-<ordinal>.<name>-postgres-headless.<namespace>.svc.cluster.local
```

For a single-replica instance named `mydb` in namespace `production`:
```
mydb-postgres-0.mydb-postgres-headless.production.svc.cluster.local:5432
```

## Notes

- `POSTGRES_PASSWORD` must be supplied via a secret (not an input) for security. Reference it using `env.POSTGRES_PASSWORD.secretKeyRef` in your katalog.
- pgAdmin default credentials are `admin@orkestra.local` / `admin` — change these for production.
- For multi-replica setups, configure PostgreSQL replication (streaming, logical, or Patroni) separately; this motif provisions the infrastructure layer only.
