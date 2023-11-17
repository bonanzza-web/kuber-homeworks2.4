resource "local_file" "hosts" {
  content = <<-DOC
  [hosts]
  main.server-kube ansible_host=${yandex_compute_instance.ubuntu.network_interface.0.nat_ip_address}
  DOC
filename = "../inventory/hosts.txt"

  depends_on = [
    yandex_compute_instance.ubuntu
  ]
}
