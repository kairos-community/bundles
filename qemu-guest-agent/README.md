# QEMU Guest Agent Bundle

The QEMU Guest Agent bundle installs the [QEMU Guest Agent](https://wiki.qemu.org/Features/GuestAgent) (`qemu-ga`) on the Kairos node so the VM host can query and control the guest (freeze/thaw filesystems, exec commands, get network info, graceful shutdown, etc.).

The bundle:

- Copies the `qemu-ga` binary into `/usr/local/bin/`.
- Drops a `qemu-guest-agent.service` unit into `/etc/systemd/system/` and enables it via a `multi-user.target.wants` symlink.
- Starts the service immediately when systemd is running; otherwise it will start on next boot.

Systemd is required. On non-systemd systems the bundle logs a warning and exits without failing.

## Configuration

No configuration is required.

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:qemu-guest-agent_latest
```
