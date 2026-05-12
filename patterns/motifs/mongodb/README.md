# MongoDB Motif

Deploys a production-ready MongoDB instance with persistent storage, stable pod DNS, and a mongo-express management console.

## What Gets Created

| Resource | Name Pattern | Purpose |
|---|---|---|
| StatefulSet | `<name>-mongodb` | MongoDB pods with stable identity |
| Service (headless) | `<name>-mongodb-headless` | Pod DNS for replica set members |
| Service (client) | `<name>-mongodb` | ClusterIP for application connections |
| Service (UI) | `<name>-mongoexpress-svc` | LoadBalancer for mongo-express |
| Deployment | `<name>-mongoexpress` | mongo-express management console |
| PVC (per pod) | `data-<name>-mongodb-0` | Provisioned by StorageClass |

## Inputs

| Name | Default | Description |
|---|---|---|
| `image` | `mongo:latest` | MongoDB container image |
| `replicas` | `1` | Number of replicas |
| `resourceProfile` | `standard` | CPU/memory profile |
| `volumeSize` | `10Gi` | PVC size per pod |
| `storageClass` | `standard` | StorageClass for dynamic provisioning |
| `database` | `app` | Default database name |
| `username` | `admin` | MongoDB root username |
| `mongoExpressImage` | `mongo-express:latest` | mongo-express image |

## Probes

| Probe | Type | Profile |
|---|---|---|
| startup | TCP :27017 | `slow-start` |
| liveness | TCP :27017 | `standard` |
| readiness | TCP :27017 | `standard` |
| mongo-express liveness | HTTP `/` | `standard` |
| mongo-express readiness | HTTP `/` | `standard` |

## Status Fields

| Field | Value |
|---|---|
| `mongodbReady` | True when all replicas are ready |
| `connectionString` | `mongodb://<user>@<svc>.<ns>.svc.cluster.local:27017/<db>` |
| `mongoExpressUrl` | `http://<mongoexpress-svc>.<ns>.svc.cluster.local:8081` |

## Usage in a Katalog

```yaml
operatorBox:
  onCreate:
    motifs:
      - ref: ghcr.io/orkspace/orkestra-registry/motifs/mongodb@v7
        inputs:
          database: "{{ .spec.dbName | default \"app\" }}"
          volumeSize: "{{ .spec.storageSize | default \"10Gi\" }}"
          storageClass: "{{ .spec.storageClass | default \"standard\" }}"
          resourceProfile: "{{ .spec.resourceProfile | default \"standard\" }}"
```

## Notes

- `MONGO_INITDB_ROOT_PASSWORD` must be supplied via a secret in your katalog.
- mongo-express runs with `ME_CONFIG_BASICAUTH: false` by default for local development. Enable auth for production.
- For multi-replica replica sets, configure `rs.initiate()` via an init container or startup script.
