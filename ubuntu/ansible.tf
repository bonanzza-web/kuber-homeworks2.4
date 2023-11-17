resource "null_resource" "wait" {
  provisioner "local-exec" {
    command = "sleep 100"
  }

  depends_on = [
    local_file.hosts
  ]
}

resource "null_resource" "cluster" {
  provisioner "local-exec" {
    command = "ansible-playbook -i ../inventory/hosts.txt ../kube-ubuntu.yml"
}

  depends_on = [
    null_resource.wait
  ]
}
