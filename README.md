# Resonate Bootstrap Launcher

Public helper scripts for **Resonate**. The main `tdhayer/resonate` application repository is **private** (access required); these scripts are the small public surface used to bootstrap and extend an install. Two are token-aware launchers for the **Proxmox VE** install/update flow; the third is a standalone listening-room installer that needs no token.

All three mirror the canonical copies under `scripts/` in the private main repo, which is the single source of truth — update them there and copy the result here.

> **The Proxmox launchers are Proxmox-only.** `public-bootstrap.sh` / `public-update.sh` fetch scripts (`proxmox-bootstrap.sh` / `proxmox-update.sh`) that create and manage a Proxmox **LXC** and require `pct`. If you are deploying on a plain Debian/Ubuntu host, a VM (VirtualBox / VMware / Hyper-V / KVM), or in the cloud, you do **not** need them — follow the Docker deployment options documented in the main repo. (`install-room.sh` below is general-purpose and works anywhere.)

## What this repository contains

| File | Token? | Purpose |
| --- | --- | --- |
| `public-bootstrap.sh` | yes | Fetches the private `scripts/proxmox-bootstrap.sh` via the GitHub API and runs it (first-time install: creates the LXC, passes through audio, installs Docker, deploys). |
| `public-update.sh` | yes | Fetches the private `scripts/proxmox-update.sh` via the GitHub API and runs it (updates an existing LXC in place, preserving its `.env`). |
| `install-room.sh` | no | Standalone — installs Snapclient on any Debian/Ubuntu/Raspberry Pi OS device and registers it as a Resonate listening room. Hosted here so room devices can `curl` it without access to the private repo. |

## Prerequisites

- A **Proxmox VE host**, run as `root`.
- `bash`, `curl`, and `mktemp` (standard on a Proxmox host).
- A **GitHub token** with read access to the private `tdhayer/resonate` repository.

## Install usage

Interactive token prompt:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tdhayer/resonate-bootstrap-launcher/main/public-bootstrap.sh)"
```

Non-interactive:

```bash
GH_TOKEN=<token> \
RESONATE_OWNER=tdhayer \
RESONATE_REPO=resonate \
RESONATE_REF=main \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tdhayer/resonate-bootstrap-launcher/main/public-bootstrap.sh)"
```

## Update usage

Pass the target LXC container ID (here `101`) as the trailing argument:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tdhayer/resonate-bootstrap-launcher/main/public-update.sh)" 101
```

Non-interactive:

```bash
GH_TOKEN=<token> \
RESONATE_OWNER=tdhayer \
RESONATE_REPO=resonate \
RESONATE_REF=main \
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tdhayer/resonate-bootstrap-launcher/main/public-update.sh)" 101
```

You can also set `RESONATE_CTID=101` instead of passing the container ID as an argument.

## Add a listening room

Run this on any Debian/Ubuntu/Raspberry Pi OS device (no token needed) to install Snapclient and point it at your Resonate host. The new room appears automatically in the **Rooms** panel of the UI.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tdhayer/resonate-bootstrap-launcher/main/install-room.sh)" <resonate-host-ip> [room-name]
```

For example:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/tdhayer/resonate-bootstrap-launcher/main/install-room.sh)" 192.168.1.20 Kitchen
```

The room name defaults to the device hostname if omitted. This is a mirror of `scripts/install-room.sh` in the private main repo — published here so room devices that don't have the repo can fetch it directly.

## Configuration

| Variable | Default | Meaning |
| --- | --- | --- |
| `GH_TOKEN` | (prompted) | GitHub token with private-repo read access. |
| `RESONATE_OWNER` | `tdhayer` | Owner of the private Resonate repo. |
| `RESONATE_REPO` | `resonate` | Private repo name. |
| `RESONATE_REF` | `main` | Branch/ref to fetch the installer/updater from. |
| `RESONATE_PRIVATE_SCRIPT_PATH` | `scripts/proxmox-bootstrap.sh` (install) / `scripts/proxmox-update.sh` (update) | Path of the private script to fetch. |
| `RESONATE_CTID` | (prompt or first arg) | Update only: target LXC container ID. |

## Security notes

- Use a least-privilege token scoped to private-repo read only.
- Prefer a short-lived token; both launchers `unset` the token from the shell on exit (best effort).
- Do not paste tokens into shared shell history.

## License

These launcher scripts are released under the [MIT License](LICENSE). The Resonate application itself (the private `tdhayer/resonate` repository) is separate and not covered by this license.

## Related

- **Resonate** main application repository: `tdhayer/resonate` (private — access required). Full deployment options and the complete install/update script reference live in its README.
