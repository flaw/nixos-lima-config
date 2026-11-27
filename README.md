# nixos-lima-config

A NixOS configuration flake that uses the [nixos-lima](https://github.com/nixos-lima/nixos-lima) module to enable running NixOS within a [Lima](https://lima-vm.io)-managed VM on macOS and Linux.

This repository maintains the NixOS Lima VM configuration separately from the upstream `nixos-lima` module, allowing the module to be updated independently.

The Bash scripts `setup-nixos.sh` and `setup-home-manager.sh` check out Git repositories for NixOS system configuration and Home Manager, respectively, and apply those configurations. Both default to [flaw/nixos-lima-config](https://github.com/flaw/nixos-lima-config).

This configuration uses base images released by [nixos-lima](https://github.com/nixos-lima/nixos-lima).

## Prerequisites

* Apple Silicon macOS 13.5+ or ARM64 Linux with Lima installed

NOTE: Nix is not needed to run a NixOS Lima VM (e.g. you can install Lima with Homebrew or another mechanism and start a guest VM running NixOS)

## Installation

Check out this repository to your Lima host. The following commands can be used with no customization of this repository. (The main username for the guest VM, "lima" is hardcoded in `homeConfigurations."lima"` in `flake.nix`.)

```
limactl start --yes --set '.user.name = "lima"' nixos.yaml
./setup-nixos.sh nixos
./setup-home-manager.sh nixos lima
```

The NixOS configuration is named `nixos`. This repository supports ARM64 guests only.

To use your host username in the guest, first update the Home Manager configuration name, `home.username`, and `home.homeDirectory` in `flake.nix` to match and push those changes to the fork. Then run:

```
limactl start --yes nixos.yaml
./setup-nixos.sh nixos
./setup-home-manager.sh nixos $USER
```
You can then log in to your NixOS guest VM using:

```
limactl shell nixos
```

**NOTE**: Both setup scripts use `git clone` to fetch configurations from the default branch of `https://github.com/flaw/nixos-lima-config.git`. Local changes to the `*.nix` files will not be seen by the guest until you push them to that branch. To use a different configuration repository, pass its URL as the third argument (`config-repo`) to either script.

## Updating an existing VM

Commit and push your configuration changes, then run on the host:

```bash
./update-nixos.sh nixos
```

This pulls the existing `/etc/nixos` checkout with `git pull --ff-only` and runs
`nixos-rebuild switch`. If the pull fails, the rebuild is not run. The default
configuration is `nixos`.

When updating a guest installed before the configuration was renamed, use the
updated host helper once (or run `sync-config nixos` if the guest already has the
older command installed).

The helper uses the guest checkout's existing remote. If the guest was originally
set up using the upstream repository, point it at this fork first:

```bash
limactl shell nixos -- sudo git -C /etc/nixos remote set-url origin \
  https://github.com/flaw/nixos-lima-config.git
```

After switching, both update commands compare `/run/booted-system` with
`/run/current-system` for changes to the kernel, kernel modules, initrd, and
kernel parameters. If any differ, they print a reboot recommendation and the
command to use. This also detects a reboot still pending from an earlier update.
Most other changes activate immediately.

This is a conservative check, not an exhaustive detector: bootloader settings,
firmware, and other boot-time changes outside those artifacts may still require
a reboot. Missing kernel artifacts produce an "unknown" status rather than a
false all-clear. Neither command reboots automatically.

To restart from the host:

```bash
limactl restart nixos
```

### Updating from inside the guest

The system configuration also installs `sync-config`. To make it available in an
existing guest, push this configuration and run `./update-nixos.sh nixos` once.
Then, inside the guest, run:

```bash
sync-config
```

It uses the `nixos` configuration. You can optionally pass a different
configuration name: `sync-config <config-name>`.

Like the host helper, it pulls `/etc/nixos` with `--ff-only` and then runs
`nixos-rebuild switch`, using `sudo`. Push your changes first; it uses the guest
checkout's existing remote and stops if the pull fails. It does not reboot
automatically.

You can also check reboot status inside the guest at any time:

```bash
check-config-reboot
```

Use `setup-nixos.sh` only for initial setup, not updates. Neither update command
applies Home Manager changes.

## Help Wanted

Feedback, issues, and pull-requests are all most welcome.
