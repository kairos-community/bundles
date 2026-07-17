# OpenAMT Bundle

The OpenAMT bundle provisions [Intel Active Management Technology (AMT)](https://www.intel.com/content/www/us/en/architecture-and-technology/vpro/active-management-technology.html) on the Kairos node using the Kairos AMT agent provider (`agent-provider-amt`).

The bundle only runs the provider if an `amt` block is present in the Kairos configuration.

## Configuration

Pass any settings supported by `agent-provider-amt` under the `amt` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:openamt_latest

# Specify AMT settings; passed to agent-provider-amt over stdin
amt:
  # provider-specific options go here
  ...
```

If the `amt` block is missing or empty, the bundle is a no-op.

Refer to the AMT provider documentation shipped with the underlying `ghcr.io/kairos-io/openamt` image for the full list of supported options.
