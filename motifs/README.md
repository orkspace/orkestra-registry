# Orkestra Motifs — Stateful Services

Motifs are pre-built, opinionated Orkestra resource bundles for common stateful services. A single motif declaration in your Katalog replaces dozens of lines of repetitive YAML: it gives you a StatefulSet, headless service, client service, management UI, persistent storage, health probes, and resource profiles — all tuned for production use.

## Available Motifs

| Motif | Image Default | Port | Storage | Management UI |
|---|---|---|---|---|
| [postgres](postgres/) | `postgres:latest` | 5432 | yes | pgAdmin (port 80) |
| [mysql](mysql/) | `mysql:latest` | 3306 | yes | phpMyAdmin (port 80) |
| [mongodb](mongodb/) | `mongo:latest` | 27017 | yes | mongo-express (port 8081) |
| [redis](redis/) | `redis:latest` | 6379 | yes | Redis Commander (port 8081) |
| [kafka](kafka/) | `apache/kafka:latest` | 9092 | yes | Kafka UI (port 8080) |
| [rabbitmq](rabbitmq/) | `rabbitmq:management` | 5672 | yes | Built-in management (port 15672) |

## Using a Motif in a Katalog

```yaml
spec:
  crds:
    database:
      apiTypes:
        group: myapp.io
        version: v1alpha1
        kind: Database

      operatorBox:
        onCreate:
          motifs:
            - ref: ghcr.io/orkspace/orkestra-registry/motifs/postgres@v17
              inputs:
                image: "{{ .spec.postgresImage | default \"postgres:latest\" }}"
                database: "{{ .spec.dbName }}"
                volumeSize: "{{ .spec.storageSize | default \"20Gi\" }}"
                storageClass: "{{ .spec.storageClass | default \"standard\" }}"
                resourceProfile: "{{ .spec.resourceProfile | default \"standard\" }}"
```

## Probe Profiles

All motifs come with health probes pre-configured using probe profiles:

| Profile | initialDelay | period | failureThreshold | Use Case |
|---|---|---|---|---|
| `fast` | 5s | 10s | 2 | HTTP APIs with instant startup |
| `standard` | 15s | 20s | 3 | Most services (default) |
| `patient` | 30s | 30s | 5 | Workers or moderate startup |
| `slow-start` | 0s | 10s | 30 | Databases, JVMs — 5 min window |

Databases (postgres, mysql, mongodb, kafka) use **TCP** probes with `slow-start` for startup and `standard` for liveness/readiness. Redis and RabbitMQ use `patient` for startup given their quick init. Management UIs use **HTTP** probes.

## Resource Profiles

Each motif accepts a `resourceProfile` input:

| Profile | CPU Request | Memory Request | Use Case |
|---|---|---|---|
| `small` | 100m | 128Mi | Dev, lightweight |
| `standard` | 250m | 512Mi | General purpose |
| `burst` | 500m | 512Mi | Variable-load (Redis) |
| `compute-heavy` | 1000m | 2Gi | High throughput (Kafka) |
| `steady` | 250m | 1Gi | Stable memory-bound workloads |

## Storage

All motifs use `volumeClaimTemplates` for persistent storage. Each pod gets its own PVC provisioned by the cluster's StorageClass. Set `storageClass: ""` to use the cluster default.

## Development vs Production

For local development, override the image to a lighter tag:
```yaml
inputs:
  image: "postgres:16-alpine"
  volumeSize: "1Gi"
  resourceProfile: "small"
```

For production, pin the image tag and set appropriate storage:
```yaml
inputs:
  image: "postgres:16.2"
  volumeSize: "100Gi"
  storageClass: "fast-ssd"
  resourceProfile: "standard"
```
