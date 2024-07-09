variable "region" {
  default = "us-east-1"
}

variable "avl_zone" {
  default = "us-east-1a"
}

variable "ssh_user" {
  default = "ubuntu"
}

variable "domains" {
  type    = list(string)
  default = ["example.com"]
}

variable "evilginx_domain_name" {
  default = "example.com"
}
