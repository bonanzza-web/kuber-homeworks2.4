resource "yandex_vpc_network" "bonanzza-net" {
    name = var.vpc_network_name
}

resource "yandex_vpc_subnet" "bonanzza-subnet" {
    name = var.vpc_network_name
    zone = var.zone
    network_id = yandex_vpc_network.bonanzza-net.id
    v4_cidr_blocks = var.cidr
}

data "yandex_compute_image" "ubuntu" {
  family = var.os_family
}

resource "yandex_compute_instance" "ubuntu" {
    name = "ubuntu"
    hostname = "server-kube"
    resources {
        cores = 2
        memory = 2
        core_fraction = 5
    }

    boot_disk {
     initialize_params {
       size = 20
       image_id = data.yandex_compute_image.ubuntu.id
       type = "network-hdd"
     } 
    }

    network_interface {
      subnet_id = yandex_vpc_subnet.bonanzza-subnet.id
      nat = true
    }

    metadata = {
      serial-port-enable = true
      ssh-keys = "ubuntu:${local.ssh_key}"
    }
}
