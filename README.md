# On-Premise Configurator Operator (Ansible)

[![Release](https://img.shields.io/github/v/release/edenlabllc/on-premise-configurator.operators.infra.svg?style=for-the-badge)](https://github.com/edenlabllc/on-premise-configurator.operators.infra/releases/latest)
[![Software License](https://img.shields.io/github/license/edenlabllc/on-premise-configurator.operators.infra.svg?style=for-the-badge)](LICENSE)
[![Powered By: Edenlab](https://img.shields.io/badge/powered%20by-edenlab-8A2BE2.svg?style=for-the-badge)](https://edenlab.io)

Kubernetes Operator for declarative configuration of remote **bare-metal** or **virtual** machines over SSH,  
designed to work in both **isolated** ([air-gapped](https://en.wikipedia.org/wiki/Air_gap_(networking)))
and **network-connected** environments.

:white_check_mark: Implements the
[Cluster API provider contract](https://cluster-api.sigs.k8s.io/developer/providers/contracts/overview)  
for Kubernetes infrastructure providers, ensuring full compatibility with
[Cluster API](https://cluster-api.sigs.k8s.io/).

- Based on the [Ansible Operator SDK](https://sdk.operatorframework.io/docs/building-operators/ansible/).
- Supports [K3S](https://docs.k3s.io/) installation and OS configuration.
- Inspired by the [k3s-ansible](https://github.com/k3s-io/k3s-ansible) project.

---

## What it does

This operator connects to **remote** Linux machines via SSH and applies Ansible roles to configure them with K3S
or custom OS tweaks.  
It is intended for managing machines that are **already** provisioned (e.g., via PXE, IPMI, or manually)
and **does not** provision infrastructure.

### Key features

- SSH-based configuration of remote Linux hosts.
- Isolated and network-connected K3S installation.
- Modular roles for firewall, disk, and OS setup.
- Declarative CRDs: `K3SCluster`, `K3SControlPlane`, `K3SRemoteMachine`.
- Built-in status management according to
  [Cluster API](https://github.com/kubernetes-sigs/cluster-api/blob/release-1.8/docs/book/src/images/bootstrap-controller.png).
- Automatic retrieval of
  [providerID](https://cluster-api.sigs.k8s.io/developer/providers/contracts/infra-machine#inframachine-provider-id)
  and node addresses from the machine hostname.
- Finalizer for cleanup (optional).
- Secret generation (`token`, `kubeconfig`) on init server.

---

## Performance tuning

The operator relies on the default **automatic** setting for the number of
[concurrent reconciles](https://sdk.operatorframework.io/docs/building-operators/ansible/reference/advanced_options/#max-concurrent-reconciles)
(`runtime.NumCPU()`).

If you are managing **large** pools of machines or clusters, consider **tuning** this value explicitly for higher
throughput.

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
