output "vm_ip_addresses" {
  value = {
    dc01   = module.dc01.ip_address
    sql01  = module.sql01.ip_address
    sql02  = module.sql02.ip_address
    fs01   = module.fs01.ip_address
    wsus01 = module.wsus01.ip_address
  }
  description = "Feed these straight into ansible/inventory/hosts.ini"
}
