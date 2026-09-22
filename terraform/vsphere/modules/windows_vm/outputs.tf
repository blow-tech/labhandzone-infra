output "vm_id" {
  value = vsphere_virtual_machine.this.id
}

output "vm_name" {
  value = vsphere_virtual_machine.this.name
}

output "ip_address" {
  value = var.ip_address
}
