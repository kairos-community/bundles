<h1 align="center">
  <br>
     <img width="184" alt="kairos-white-column 5bc2fe34" src="https://user-images.githubusercontent.com/2420543/193010398-72d4ba6e-7efe-4c2e-b7ba-d3a826a55b7d.png">
    <br>
<br>
</h1>

<h3 align="center">Kairos Community Bundles</h3>

<hr>

Welcome to the community-bundles repository! This repository builds and pushes Kairos community bundles that can be consumed by Kairos core or derivative images (such as [provider-kairos](https://github.com/kairos-io/provider-kairos) ) to extend Kairos configurations and settings, and to add cloud-config keywords.

Please note that these community bundles are not officially supported and are provided on a best-effort basis by the community.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Bundles](#bundles)
- [Development](#development)

## Usage

To use a community bundle, you can load it with the bundles block in the Kairos configuration file, like this:

```yaml
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:<bundle-name>
```

Here is an example of how you might use a community bundle in a Kairos core image:

```yaml
#cloud-config
install:
  device: "auto"
  auto: true
  reboot: true
  image: "docker:quay.io/kairos/kairos-opensuse:v1.4.0-k3sv1.26.0-k3s1"

users:
  - name: "kairos"
    passwd: "kairos"
    ssh_authorized_keys:
      - ...

bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:kubevirt

k3s:
  enabled: true
```

## Bundles

The following community bundles are available. Each bundle has its own README with detailed configuration options:

- **[ArgoCD](argocd/README.md)** - Deploys [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- **[Calico](calico/README.md)** - Deploys [Project Calico](https://docs.tigera.io/calico/latest/about/)
- **[Cert-manager](cert-manager/README.md)** - Deploys [cert-manager](https://cert-manager.io/docs/installation/)
- **[Confidential Containers (coco)](coco/README.md)** - Sets up the [enclave-cc](https://github.com/confidential-containers/enclave-cc) runtime for confidential containers on k3s
- **[EdgeVPN](edgevpn/README.md)** - Deploys [EdgeVPN](https://github.com/mudler/edgevpn) for mesh VPN networks
- **[Flux](flux/README.md)** - Installs [FluxCD](https://fluxcd.io/flux/cmd/flux_bootstrap/) with automatic bootstrapping
- **[K9s](k9s/README.md)** - Installs [K9s](https://k9scli.io/), a terminal-based UI for managing Kubernetes clusters
- **[Kairos](kairos/README.md)** - Deploys the [Kairos helm-charts](https://github.com/kairos-io/helm-charts)
- **[Kairos Operator](kairos-operator/README.md)** - Deploys the [Kairos Operator](https://github.com/kairos-io/kairos-operator) to k0s or k3s clusters
- **[Kyverno](kyverno/README.md)** - Deploys [Kyverno](https://kyverno.io/docs/introduction/)
- **[Kubevirt](kubevirt/README.md)** - Deploys [Kubevirt](https://github.com/kubevirt/kubevirt) and optionally [kubevirt-manager](https://kubevirt-manager.io/)
- **[LocalAI](LocalAI/README.md)** - Deploys [LocalAI](https://localai.io/) via its Helm chart
- **[Longhorn](longhorn/README.md)** - Deploys [Longhorn](https://longhorn.io/docs/)
- **[MetalLB](metallb/README.md)** - Deploys [MetalLB](https://metallb.universe.tf/installation/)
- **[Multus](multus/README.md)** - Deploys [Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni) with CNI plugins
- **[Nginx](nginx/README.md)** - Deploys [Ingress-Nginx-Controller](https://kubernetes.github.io/ingress-nginx/)
- **[OpenAMT](openamt/README.md)** - Provisions [Intel AMT](https://www.intel.com/content/www/us/en/architecture-and-technology/vpro/active-management-technology.html) via the Kairos AMT agent provider
- **[QEMU Guest Agent](qemu-guest-agent/README.md)** - Installs the [QEMU Guest Agent](https://wiki.qemu.org/Features/GuestAgent) for VM host integration
- **[SpinKube](spinkube/README.md)** - Deploys [SpinKube](https://spinkube.dev) to k3s clusters
- **[System upgrade controller](system-upgrade-controller/README.md)** - Deploys [System upgrade controller](https://github.com/rancher/system-upgrade-controller)

## Development

If you want to build and test a bundle, you can use earthly by running the following commands:

```
# build
./earthly.sh +build --BUNDLE=<bundle-name>
# test
./earthly.sh +test --BUNDLE=<bundle-name>
```

We also provide a version of the `earthly.sh` script for Windows (`earthly.ps1`).