variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "zone" {
  type = string
  default = "ru-central1-a"
}

variable "os_family" {
  type = string
  default = "ubuntu-2204-lts"
  description = "OS family name"
}

variable "vpc_network_name" {
  type = string
  default = "bonanzza-net"
}

variable "cidr" {
  type = list(string)
  default = [ "10.0.3.0/24" ]
}


