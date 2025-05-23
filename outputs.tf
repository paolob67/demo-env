// outputs.tf
output "floating_ip_address" {
  value = ibm_is_floating_ip.fip.address
}
