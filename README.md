# On-Premise Configurator Operator (Ansible)

[![Release](https://img.shields.io/github/v/release/edenlabllc/on-premise-configurator.operators.infra.svg?style=for-the-badge)](https://github.com/edenlabllc/on-premise-configurator.operators.infra/releases/latest)
[![Software License](https://img.shields.io/github/license/edenlabllc/on-premise-configurator.operators.infra.svg?style=for-the-badge)](LICENSE)
[![Powered By: Edenlab](https://img.shields.io/badge/powered%20by-edenlab-8A2BE2.svg?style=for-the-badge)](https://edenlab.io)

Kubernetes Operator for declarative configuration of remote bare-metal or virtual machines via SSH using Ansible.  
Designed for airgapped and connected environments.

---

## What it does

This operator connects to remote Linux machines via SSH and applies Ansible roles to configure them with K3S or custom
OS tweaks.  
It is intended for managing machines that are already provisioned (e.g., via PXE, IPMI, or manually) and does **not**
provision infrastructure.

### Key features

- SSH-based configuration of remote Linux hosts
- Airgapped and online K3S installation
- Modular roles for firewall, disk, and OS setup
- Declarative CRDs: `K3SRemoteMachine`
- Built-in status management (`Installing`, `Ready`, `Failed`)
- Finalizer for cleanup (optional)
- Secret generation (`token`, `kubeconfig`) on init server

---

## Project structure

| Path               | Purpose                                           |
|--------------------|---------------------------------------------------|
| `roles/`           | Core Ansible logic (`airgap`, `k3s_server`, etc.) |
| `playbooks/`       | Entrypoint playbooks                              |
| `config/crd/`      | CRD definitions                                   |
| `watches.yaml`     | Mapping of CR to playbook and var binding         |
| `Dockerfile`       | Operator image with Ansible runtime               |
| `requirements.yml` | Ansible collections required                      |

---

## Lifecycle phases

| Phase        | Description                     |
|--------------|---------------------------------|
| `Installing` | Configuration is in progress    |
| `Ready`      | Host successfully configured    |
| `Failed`     | Setup failed with error message |

---

## Finalizer

The finalizer role `k3s_reset` is triggered on deletion of a `K3SRemoteMachine` and performs:

- K3S uninstall (`server` or `agent`)
- Removal of configs, systemd units, symlinks
- Optional: unmount and clean disk if specified

Defined in `watches.yaml`:

```yaml
finalizer:
  name: config.onprem.edenlab.io/finalizer
  role: k3s_reset
```

---

## Secret generation

If `.spec.k3sInitServer: true` is set, the following Kubernetes secrets are created:

- `${k3sPrefixSecretRef}-token-secret`
- `${k3sPrefixSecretRef}-kubeconfig-secret`

These secrets are intended for use by other machines joining the K3S cluster.

---

## Required Ansible collections

See [`requirements.yml`](./requirements.yml) for more details.
