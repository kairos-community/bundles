# LocalAI Bundle

The LocalAI bundle deploys [LocalAI](https://localai.io/) into a k3s cluster via its Helm chart.

## Configuration

The bundle adds a `localai` block that lets you override the Kubernetes service type exposed for LocalAI:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:LocalAI_latest

# Specify LocalAI settings
localai:
  serviceType: LoadBalancer
```

Available `serviceType` values follow the [Kubernetes Service types](https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types). If not set, `ClusterIP` is used.

The bundle installs the LocalAI Helm chart via a `HelmChart` manifest dropped into k3s' auto-deploy directory. See the [LocalAI Helm chart](https://github.com/go-skynet/helm-charts) for available values.
