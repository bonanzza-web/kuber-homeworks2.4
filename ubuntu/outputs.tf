output "vm-external-ip" {
  value = yandex_compute_instance.ubuntu.network_interface.0.nat_ip_address
}
