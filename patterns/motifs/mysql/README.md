# MySQL Motif

Deploys a production-ready MySQL instance with persistent storage, stable pod DNS, and a phpMyAdmin management console.

## What Gets Created

| Resource | Name Pattern | Purpose |
|---|---|---|
| StatefulSet | `<name>-mysql` | MySQL pods with stable identity |
| Service (headless) | `<name>-mysql-headless` | Pod DNS for replication/cluster |
| Service (client) | `<name>-mysql` | ClusterIP for application connections |
| Service (UI) | `<name>-phpmyadmin-svc` | LoadBalancer for phpMyAdmin |
| Deployment | `<name>-phpmyadmin` | phpMyAdmin management console |
| PVC (per pod) | `data-<name>-mysql-0` | Provisioned by StorageClass |

## Inputs

| Name | Default | Description |
|---|---|---|
| `image` | `mysql:latest` | MySQL container image |
| `replicas` | `1` | Number of replicas |
| `resourceProfile` | `standard` | CPU/memory profile |
| `volumeSize` | `10Gi` | PVC size per pod |
| `storageClass` | `standard` | StorageClass for dynamic provisioning |
| `database` | `app` | Default database name |
| `username` | `mysql` | MySQL user name |
| `phpMyAdminImage` | `phpmyadmin:latest` | phpMyAdmin image |

## Probes

| Probe | Type | Profile |
|---|---|---|
| startup | TCP :3306 | `slow-start` |
| liveness | TCP :3306 | `standard` |
| readiness | TCP :3306 | `standard` |
| phpMyAdmin liveness | HTTP `/` | `standard` |
| phpMyAdmin readiness | HTTP `/` | `standard` |

## Status Fields

| Field | Value |
|---|---|
| `mysqlReady` | True when all replicas are ready |
| `connectionString` | `mysql://<user>@<svc>.<ns>.svc.cluster.local:3306/<db>` |
| `phpMyAdminUrl` | `http://<phpmyadmin-svc>.<ns>.svc.cluster.local` |

## Usage in a Katalog

```yaml
operatorBox:
  onCreate:
    motifs:
      - ref: ghcr.io/orkspace/orkestra-registry/motifs/mysql@v8
        inputs:
          database: "{{ .spec.dbName | default \"app\" }}"
          volumeSize: "{{ .spec.storageSize | default \"10Gi\" }}"
          storageClass: "{{ .spec.storageClass | default \"standard\" }}"
          resourceProfile: "{{ .spec.resourceProfile | default \"standard\" }}"
```

## Notes

- `MYSQL_PASSWORD` and `MYSQL_ROOT_PASSWORD` should be supplied via secrets referenced in your katalog.
- `MYSQL_RANDOM_ROOT_PASSWORD: "yes"` is set by default — override via env in your katalog if you need a fixed root password.
