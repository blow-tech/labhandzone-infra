variable "vm_name" {
  type = string
}

variable "datacenter_name" {
  type = string
}

variable "compute_cluster_name" {
  type = string
}

variable "datastore_name" {
  type = string
}

variable "network_name" {
  type = string
}

variable "template_name" {
  type = string
}

variable "num_cpus" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 4096
}

variable "os_disk_size_gb" {
  type    = number
  default = 80
}

variable "extra_disk_sizes_gb" {
  type        = list(number)
  default     = []
  description = "Additional data disks beyond the OS disk, e.g. for fs01's iSCSI LUN backing store."
}

variable "local_admin_password" {
  type      = string
  sensitive = true
}

variable "time_zone_id" {
  type        = number
  default     = 85 # UTC — see https://ss64.com/vmware/timezone.html for the full list
  description = "vSphere guest customization time zone ID (numeric, not IANA name)."
}

variable "ip_address" {
  type = string
}

variable "netmask_cidr_prefix" {
  type    = number
  default = 24
}

variable "gateway_ip" {
  type = string
}

variable "dns_server_list" {
  type = list(string)
}
