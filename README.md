# nixos-lima-config

A NixOS configuration flake that uses the [nixos-lima](https://github.com/nixos-lima/nixos-lima) module to enable running NixOS within a [Lima](https://lima-vm.io)-managed VM on macOS and Linux.

This repository maintains the NixOS Lima VM configuration separately from the upstream `nixos-lima` module, allowing the module to be updated independently.

The Bash scripts `setup-nixos.sh` and `setup-home-manager.sh` check out Git repositories for NixOS system configuration and Home Manager, respectively, and apply those configurations. Both default to [flaw/nixos-lima-config](https://github.com/flaw/nixos-lima-config).

This configuration uses base images released by [nixos-lima](https://github.com/nixos-lima/nixos-lima).

## Prerequisites

* macOS 13.5+ or recent Linux with Lima installed

NOTE: Nix is not needed to run a NixOS Lima VM (e.g. you can install Lima with Homebrew or another mechanism and start a guest VM running NixOS)

## Installation

Check out this repository to your Lima host. The following commands can be used with no customization of this repository. (The main username for the guest VM, "lima" is hardcoded in `homeConfigurations."lima"` in `flake.nix`.)

```
limactl start --yes --set '.user.name = "lima"' nixos.yaml
./setup-nixos.sh nixos nixos-aarch64
./setup-home-manager.sh nixos lima
```

The default NixOS configuration is `nixos-aarch64`. On an x86_64 host, pass `nixos-x86_64` instead.

To use your host username in the guest, first update the Home Manager configuration name, `home.username`, and `home.homeDirectory` in `flake.nix` to match and push those changes to the fork. Then run:

```
limactl start --yes nixos.yaml
./setup-nixos.sh nixos nixos-aarch64
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
configuration is `nixos-aarch64`; for an x86_64 guest, use:

```bash
./update-nixos.sh nixos nixos-x86_64
```

The helper uses the guest checkout's existing remote. If the guest was originally
set up using the upstream repository, point it at this fork first:

```bash
limactl shell nixos -- sudo git -C /etc/nixos remote set-url origin \
  https://github.com/flaw/nixos-lima-config.git
```

Most changes activate immediately. For kernel or boot-related changes, restart:

```bash
limactl restart nixos
```

Use `setup-nixos.sh` only for initial setup, not updates. This helper does not
apply Home Manager changes.

## Help Wanted

Feedback, issues, and pull-requests are all most welcome.
