# terraform/vsphere/modules/windows_vm/main.tf
# Clones a Windows Server VM from an existing template, sets static
# networking via vSphere guest customization, and leaves it in a WORKGROUP
# (not domain-joined) — domain join happens later via Ansible, once dc01
# has actually promoted the forest. Doing it in this order avoids a
# chicken-and-egg problem: Terraform can't join a domain that doesn't
# exist yet on the very first apply.

terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
    }
  }
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.compute_cluster_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "this" {
  name             = var.vm_name
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id

  num_cpus = var.num_cpus
  memory   = var.memory_mb
  guest_id = data.vsphere_virtual_machine.template.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]
  }

  # Primary OS disk, sized from the template, plus any extra data disks the
  # caller asked for (fs01 uses this for its iSCSI-backed cluster LUNs).
  # unit_number comes from the dynamic block's own index (.key) — no need
  # to reconstruct or search the list for it.
  dynamic "disk" {
    for_each = concat(
      [var.os_disk_size_gb],
      var.extra_disk_sizes_gb
    )
    iterator = d
    content {
      label            = "disk${d.key}"
      size             = d.value
      thin_provisioned = true
      unit_number      = d.key
    }
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      windows_options {
        computer_name  = var.vm_name
        workgroup      = "WORKGROUP"
        admin_password = var.local_admin_password
        # Domain join deliberately NOT set here — see the file header note.
        time_zone      = var.time_zone_id
      }

      network_interface {
        ipv4_address = var.ip_address
        ipv4_netmask = var.netmask_cidr_prefix
      }

      ipv4_gateway    = var.gateway_ip
      dns_server_list = var.dns_server_list
    }
  }
}
