# Proposal: Community Bundles v2

Status: draft

## Goals

1. Bundles are **versioned** independently of each other and of this repository.
2. Bundles are **browseable**: every published version is discoverable from a registry index and from `bundles.kairos.io`.
3. Upstream bumps from Renovate turn into bundle releases with no manual step.

## Problems today

- The only version is a repo-wide git tag (`v0.1.0`). A bundle has no version of its own.
- Tags are encoded in a single OCI repository (`community-bundles:metallb-v0.1.0`, `metallb-main`, `metallb_latest`), so nothing is enumerable without knowing the naming scheme.
- Upstream versions are pinned inside `run.sh` and `Dockerfile`, and the only metadata is the README.
- The publish and test workflows carry a hand-maintained matrix of bundle names.

## Bundle manifest

Each bundle gets a `bundle.yaml`. It is a typed document, not a Kubernetes CRD: bundles are executed by `kairos-agent` on the host, often before a cluster exists, so there is nothing to reconcile. The `apiVersion`/`kind` shape gives us a Go type and a JSON schema (`schema/bundle.schema.json`) and leaves room for kairos-operator to adopt the same type later.

```yaml
apiVersion: bundles.kairos.io/v1alpha1
kind: Bundle
metadata:
  name: metallb
  description: Deploys MetalLB in the cluster
  home: https://metallb.universe.tf
  sources:
    - https://github.com/metallb/metallb
  maintainers:
    - name: Kairos community
  keywords: [networking, load-balancer]
  icon: icon.svg
spec:
  # Bundle version. Semver. Bumped on any change to this directory.
  version: 1.0.0
  # Default upstream version shipped. Renovate owns this field.
  # renovate: datasource=helm depName=metallb registryUrl=https://metallb.github.io/metallb
  appVersion: 0.16.1
  # Additional pinned upstream components, each with its own Renovate annotation.
  components: {}
  type: run                      # run | container | package (kairos-agent target types)
  platforms: [linux/amd64, linux/arm64]
  requires:
    kairos: ">=3.0.0"
    distributions: [k3s, k0s]    # empty list means a host-only bundle
  config:
    key: metallb                 # cloud-config block the bundle reads
    schema: config.schema.json   # optional
```

`spec.version` and `spec.appVersion` follow the Helm chart model. Most bundles already let users override the upstream version at runtime through their cloud-config block, so `appVersion` is the tested default, not a hard pin. The bundle version only changes when the script, assets, or config contract change.

## Repository layout

```
bundles/<name>/
  bundle.yaml
  Dockerfile
  run.sh
  README.md
  assets/
  config.schema.json   # optional
  tests/               # moved from tests/<name>_test.go, ginkgo label unchanged
schema/bundle.schema.json
docs/proposals/
```

One directory per bundle. The registry is the version store; the tree holds only the next version. Backports use `release/<name>-<major>.x` branches, and the publish job refuses a tag whose major does not match the branch name.

Versioned directories (`bundles/metallb/1.2.0/`) were considered and rejected: Renovate cannot create a new directory and must not touch old ones, which breaks the automation that drives most of this repo's changes.

## Publishing

One OCI repository per bundle:

```
quay.io/kairos/community-bundles/metallb:1.0.0
quay.io/kairos/community-bundles/metallb:1.0
quay.io/kairos/community-bundles/metallb:1
quay.io/kairos/community-bundles/metallb:latest
```

Rules:

- Tags are immutable. Publish only versions not yet present in the registry.
- `bundle.yaml` is copied into the image at `/bundle.yaml` and its fields become OCI annotations (`org.opencontainers.image.*`, `io.kairos.bundle.*`).
- Images are signed with cosign.
- The publish matrix is discovered from `bundles/*/bundle.yaml`, not hand-maintained.
- The old `community-bundles:<name>_latest` tags keep being pushed for one deprecation window.

Usage becomes:

```yaml
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles/metallb:1.0.0
```

## Release flow with Renovate

Renovate is only allowed to touch `bundle.yaml`. The hosted Renovate app cannot bump a second field (`bumpVersion` is not supported by the regex manager and `postUpgradeTasks` needs self-hosted Renovate), so a small workflow does it on Renovate's branch.

1. A single regex manager matches `bundles/*/bundle.yaml`. Updates are grouped per directory so each PR touches exactly one bundle, and the update type is exposed as a label.
2. `bundle-bump.yaml` runs on pull requests labelled `bundle-update`. It compares `spec.version` with `main` and, if unchanged, bumps it: patch for a patch or digest update, minor for a minor or major upstream update. It commits as a bot author listed in Renovate's `gitIgnoredAuthors`, so Renovate keeps rebasing and automerging the branch, and pushes with a GitHub App token so lint and tests rerun. The job is idempotent because Renovate drops the bump commit whenever it rebases.
3. Lint fails if a bundle directory changed but `spec.version` is not higher than on `main`, or if that version already exists in the registry. Humans and the bot follow the same rule.
4. Publish on push to `main` pushes every bundle whose version tag is missing.

Breaking changes remain a human decision: a maintainer bumps the major in the same PR that changes the config contract.

Sketch of the Renovate config:

```json
{
  "customManagers": [{
    "customType": "regex",
    "fileMatch": ["^bundles/[^/]+/bundle\\.yaml$"],
    "matchStrings": ["#\\s*renovate:\\s*datasource=(?<datasource>\\S+)\\s+depName=(?<depName>\\S+)(\\s+registryUrl=(?<registryUrl>\\S+))?(\\s+versioning=(?<versioning>\\S+))?\\s*\\n\\s*(appVersion|version):\\s*\"?(?<currentValue>[^\"\\s]+)"],
    "versioningTemplate": "{{#if versioning}}{{versioning}}{{else}}semver-coerced{{/if}}"
  }],
  "packageRules": [{
    "matchFileNames": ["bundles/**"],
    "groupName": "{{packageFileDir}}",
    "additionalBranchPrefix": "{{packageFileDir}}-",
    "labels": ["bundle-update", "{{updateType}}"],
    "semanticCommitScope": "{{parentDir}}"
  }],
  "gitIgnoredAuthors": ["kairos-bot@users.noreply.github.com"]
}
```

## Index and bundles.kairos.io

An index job lists the tags of every per-bundle repository with `crane`, reads the embedded `bundle.yaml` from each, and writes `index.json`. The index is built from the registry rather than from the tree, so removing a bundle directory marks it deprecated instead of erasing its history.

The site lives in `site/` in this repo, reads `index.json` and each README, and deploys to GitHub Pages under `bundles.kairos.io`. Each bundle page shows the README, the config schema, the version table with copyable `run://` references, the default app version per bundle version, Kairos compatibility, supported distributions, platforms, and last test status.

## Implementation plan

| Phase | Scope | Published output changes |
|---|---|---|
| 1 | Add `bundle.yaml` to all bundles, `schema/bundle.schema.json`, move directories under `bundles/`, move tests, extend `+lint` with schema validation and the version-increment check. | No |
| 2 | Move all `# renovate:` annotations into `bundle.yaml`, Earthfile passes versions as build args, add the regex manager and package rules, create the bot token, add `bundle-bump.yaml`. Validate on one Renovate PR before re-enabling automerge. | No |
| 3 | Rewrite `+build-multi` for per-bundle repositories and floating tags, embed manifest and annotations, cosign, discovery-based publish matrix. Keep old tags. Confirm Quay create-on-push for the robot account. | Yes, additive |
| 4 | `hack/index/` generator, `site/` Hugo project, GitHub Pages and CNAME, scheduled index refresh. | Yes, additive |
| 5 | Document release branches, update READMEs and kairos.io docs to the new references, retire the old tag scheme. | Yes, removal |

## Open questions

- Bot identity: a GitHub App owned by the org, or a PAT on a machine account.
- Whether `kairos-agent` should learn to read `/bundle.yaml` (for example to check `requires.kairos` before running).
- Whether the index should also be published as an OCI artifact for air-gapped mirrors.
