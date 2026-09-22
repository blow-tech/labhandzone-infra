# terraform/

Provisions the 5 VMs for the `labhandzone.local` lab: `dc01`, `sql01`,
`sql02`, `fs01` (file server + iSCSI shared storage), `wsus01`. Written for
**vSphere** as the primary, fully worked example this matches the
skillset this whole portfolio assumes (ESXi/vCenter) but the design is
deliberately kept simple enough to port to another provider without a
rewrite. See [Adapting to another provider](#adapting-to-another-provider).

## What Terraform does and deliberately doesn't do

Terraform's job stops at **"5 VMs exist, powered on, networked, in
WORKGROUP."** It does not create the AD forest, join anything to a domain,
build the cluster, install SQL Server, or touch WSUS/GPOs that's all
`ansible/`, run afterward. This split is deliberate, not a limitation:

- Terraform can't join a domain that doesn't exist yet on a fresh `apply`
  (`dc01` hasn't promoted the forest at VM-creation time) trying to do
  domain join in the same `apply` that creates the DC is a real
  chicken-and-egg problem, same shape as the WinRM one in the sibling
  `windows-fleet-monitoring` repo.
- Terraform is good at "does this infrastructure exist," Ansible is good at
  "is this software configured correctly" mixing both into one tool's
  responsibility makes both harder to reason about and re-run safely.

## Prerequisites

- **An existing Windows Server VM template** in vSphere (or a Content
  Library template) with VMware Tools installed. This project does not
  build that template create one manually via the vSphere client, or
  with [Packer](https://developer.hashicorp.com/packer) if you want that
  step automated too (a natural next addition see the root README's
  Roadmap).
- A flat lab network/port group already existing in vSphere
- Terraform 1.7+
- A vCenter service account with permission to clone VMs, and enough
  datastore capacity for 5 VMs (`fs01` alone needs ~105GB extra for its
  iSCSI LUN backing disks see `main.tf`)

## Usage

```bash
cd terraform/vsphere
cp terraform.tfvars.example terraform.tfvars
# fill in real vCenter creds, template name, network, IPs

terraform init
terraform plan
terraform apply
```

Then feed `terraform output vm_ip_addresses` into
`ansible/inventory/hosts.ini` and move on to the Ansible phases see the
root [README.md](../README.md) for the full deployment sequence.

## Adapting to another provider

The `modules/windows_vm` module's *interface* (name, CPU, memory, disk
sizes, static IP, gateway, DNS, local admin password) is provider-agnostic
by design only `main.tf` inside that module talks to vSphere directly.
To port to Hyper-V or Azure:

- **Hyper-V**: swap the module's internals for the
  [`hyperv` provider](https://registry.terraform.io/providers/taliesins/hyperv)
  (community-maintained) VHDX-based disks instead of vSphere `disk`
  blocks, `hyperv_machine_instance` instead of `vsphere_virtual_machine`.
  Guest customization (static IP, computer name) isn't as built-in as
  vSphere's `customize` block you'd likely need an Autounattend.xml or a
  first-boot script instead.
- **Azure**: swap for `azurerm_windows_virtual_machine` static IP becomes
  an `azurerm_network_interface` with a static private IP allocation, and
  the iSCSI-on-a-VM pattern `fs01` uses here would more idiomatically
  become an Azure Shared Disk or Azure Files for the cluster witness,
  rather than replicating an on-prem iSCSI target in the cloud.

In both cases, the root `main.tf`'s five `module` blocks and their inputs
stay conceptually the same only what's inside `modules/windows_vm`
changes.

## Known limitation: this hasn't been run against real vSphere

Being upfront: this was written without a live vCenter to `terraform
apply` against, so it's validated for HCL syntax and structural
correctness (`terraform fmt` + `terraform validate`, run in CI on every
push see the root README's Continuous Integration section) but not
proven end-to-end against real infrastructure. Review the customization
block's Windows options against your actual template's OS version before
a first real `apply`, and start with `terraform plan` to sanity-check the
plan output.
