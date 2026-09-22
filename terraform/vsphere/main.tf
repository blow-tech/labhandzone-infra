# main.tf — root module
# Provisions 5 VMs for the labhandzone.local lab. All start in WORKGROUP —
# ansible/ handles forest creation, domain join, clustering, SQL FCI setup,
# WSUS, and GPO patching in that order. See the root README for the full
# phased deployment sequence; Terraform's job stops at "VMs exist, networked,
# powered on."

module "dc01" {
  source = "./modules/windows_vm"

  vm_name               = "dc01"
  datacenter_name       = var.datacenter_name
  compute_cluster_name  = var.compute_cluster_name
  datastore_name        = var.datastore_name
  network_name          = var.network_name
  template_name         = var.windows_template_name
  local_admin_password  = var.local_admin_password

  num_cpus  = 2
  memory_mb = 4096

  ip_address           = var.vm_ips.dc01
  gateway_ip           = var.gateway_ip
  netmask_cidr_prefix  = var.netmask_cidr_prefix
  # dc01 IS the DNS server once ansible/ad_domain_controller runs — until
  # then it (and everyone else) points at a placeholder/upstream resolver.
  # Set var.dns_server_ip to dc01's own IP once the forest exists, and
  # re-apply to point every VM's DNS at itself.
  dns_server_list = [var.dns_server_ip]
}

module "sql01" {
  source = "./modules/windows_vm"

  vm_name              = "sql01"
  datacenter_name      = var.datacenter_name
  compute_cluster_name = var.compute_cluster_name
  datastore_name       = var.datastore_name
  network_name         = var.network_name
  template_name        = var.windows_template_name
  local_admin_password = var.local_admin_password

  num_cpus  = 4
  memory_mb = 8192

  ip_address          = var.vm_ips.sql01
  gateway_ip          = var.gateway_ip
  netmask_cidr_prefix = var.netmask_cidr_prefix
  dns_server_list     = [var.dns_server_ip]
}

module "sql02" {
  source = "./modules/windows_vm"

  vm_name              = "sql02"
  datacenter_name      = var.datacenter_name
  compute_cluster_name = var.compute_cluster_name
  datastore_name       = var.datastore_name
  network_name         = var.network_name
  template_name        = var.windows_template_name
  local_admin_password = var.local_admin_password

  num_cpus  = 4
  memory_mb = 8192

  ip_address          = var.vm_ips.sql02
  gateway_ip          = var.gateway_ip
  netmask_cidr_prefix = var.netmask_cidr_prefix
  dns_server_list     = [var.dns_server_ip]
}

module "fs01" {
  source = "./modules/windows_vm"

  vm_name              = "fs01"
  datacenter_name      = var.datacenter_name
  compute_cluster_name = var.compute_cluster_name
  datastore_name       = var.datastore_name
  network_name         = var.network_name
  template_name        = var.windows_template_name
  local_admin_password = var.local_admin_password

  num_cpus  = 2
  memory_mb = 4096

  # Two extra disks: one becomes the WSFC quorum LUN, one becomes the
  # shared data LUN for the SQL FCI — both served over iSCSI from this VM
  # to sql01/sql02. See ansible/roles/iscsi_target.
  extra_disk_sizes_gb = [5, 100]

  ip_address          = var.vm_ips.fs01
  gateway_ip          = var.gateway_ip
  netmask_cidr_prefix = var.netmask_cidr_prefix
  dns_server_list     = [var.dns_server_ip]
}

module "wsus01" {
  source = "./modules/windows_vm"

  vm_name              = "wsus01"
  datacenter_name      = var.datacenter_name
  compute_cluster_name = var.compute_cluster_name
  datastore_name       = var.datastore_name
  network_name         = var.network_name
  template_name        = var.windows_template_name
  local_admin_password = var.local_admin_password

  num_cpus  = 2
  memory_mb = 4096

  # WSUS content store needs real room — patch content adds up fast across
  # even a modest set of products/classifications.
  os_disk_size_gb     = 150

  ip_address          = var.vm_ips.wsus01
  gateway_ip          = var.gateway_ip
  netmask_cidr_prefix = var.netmask_cidr_prefix
  dns_server_list     = [var.dns_server_ip]
}
