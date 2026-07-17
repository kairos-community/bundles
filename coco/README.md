# Confidential Containers Bundle

The Confidential Containers (`coco`) bundle sets up the [enclave-cc](https://github.com/confidential-containers/enclave-cc) runtime on a k3s cluster, allowing you to run confidential containers on Kairos nodes.

The bundle works in two phases:

1. On first install it drops a `Plan` into `/var/lib/rancher/k3s/server/manifests/` so that once k3s is up, the [system-upgrade-controller](../system-upgrade-controller/README.md) applies the bundle again with `COCO_DEPLOY=true`.
2. On the second run (inside the plan) it installs the customized `containerd` binary and configuration, wires up systemd overrides, and switches k3s to use that containerd via socket.

## Requirements

- `k3s` running on the node.
- The [system-upgrade-controller](../system-upgrade-controller/README.md) bundle deployed on the cluster so that the plan (in the `system-upgrade` namespace) can run.
- **amd64 only** — the bundle currently ships an amd64 `containerd` build; other architectures are not yet supported.
- The following paths need to be persisted across reboots. Add them to your Kairos configuration:

```yaml
install:
  bind_mounts:
    - /etc/coco
    - /etc/containerd
```

## Configuration

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:coco_latest
```

After the initial install completes and the plan is applied, a manual reboot is required for the new containerd runtime to take effect.

See the upstream [Confidential Containers quickstart](https://github.com/confidential-containers/documentation/blob/main/quickstart.md) for background on `enclave-cc`.
