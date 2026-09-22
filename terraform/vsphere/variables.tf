# variables.tf — root module
# Fill real values into terraform.tfvars (copy from terraform.tfvars.example
# — never commit the real file, it's in .gitignore).

variable "vsphere_user" {
  type        = string
  description = "vCenter username, e.g. administrator@vsphere.local"
  sensitive   = true
}

variable "vsphere_password" {
  type      = string
  sensitive = true
}

variable "vsphere_server" {
  type        = string
  description = "vCenter FQDN or IP"
}

variable "vsphere_allow_unverified_ssl" {
  type        = bool
  default     = true
  description = "true for a self-signed vCenter cert in a lab; false in any real environment"
}

variable "local_admin_password" {
  type        = string
  sensitive   = true
  description = "Local Administrator password set via vSphere guest customization on every VM. Rotate this after first login — it's a shared bootstrap password, not a per-host secret."
}

variable "datacenter_name" {
  type = string
}

variable "compute_cluster_name" {
  type = string
}

variable "datastore_name" {
  type        = string
  description = "Datastore for all lab VMs. Split per-VM if your lab has multiple datastores."
}

variable "network_name" {
  type        = string
  description = "Port group / VM network for all lab VMs — a single flat lab network by default."
}

variable "windows_template_name" {
  type        = string
  description = <<-EOT
    Name of an existing vSphere VM template (or content library template)
    with Windows Server already installed and VMware Tools present. This
    project does NOT build that template — provision one manually or via
    Packer first. See terraform/README.md.
  EOT
}

variable "domain_name" {
  type        = string
  default     = "labhandzone.local"
  description = "AD domain this lab builds. Only used for VM naming/tags here — actual forest creation happens in ansible/, not Terraform."
}

variable "dns_server_ip" {
  type        = string
  description = "DNS server IP every VM should use. Set this to dc01's planned static IP — DC IS the DNS server once ansible/ad_domain_controller runs."
}

variable "gateway_ip" {
  type = string
}

variable "netmask_cidr_prefix" {
  type    = number
  default = 24
}

# --- Per-VM static IPs — deliberately explicit rather than DHCP, since a
# domain controller and cluster nodes need stable, predictable addressing. ---
variable "vm_ips" {
  type = object({
    dc01   = string
    sql01  = string
    sql02  = string
    fs01   = string
    wsus01 = string
  })
}
