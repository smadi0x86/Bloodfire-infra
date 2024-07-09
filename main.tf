provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "tls_private_key" "terra_sshkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.terra_sshkey.private_key_pem
  filename = "${path.module}/generated_key.pem"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "terraform-key"
  public_key = tls_private_key.terra_sshkey.public_key_openssh
}

data "aws_ami" "latest_ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source   = "./modules/aws/vpc"
  avl_zone = var.avl_zone
}

module "bastion" {
  source         = "./modules/aws/bastion"
  ami_id         = data.aws_ami.latest_ubuntu.id
  install_redelk = true
  vpc_id         = module.vpc.vpc_id
  subnet_id      = module.vpc.subnet1_id
  avl_zone       = var.avl_zone
  key_name       = aws_key_pair.generated_key.key_name
  private_key    = tls_private_key.terra_sshkey.private_key_pem
  ssh_user       = var.ssh_user
}

module "redelk-server" {
  count                 = module.bastion.install_redelk ? 1 : 0
  depends_on            = [module.teamserver]
  source                = "./modules/aws/redelk"
  ami_id                = data.aws_ami.latest_ubuntu.id
  vpc_id                = module.vpc.vpc_id
  subnet_id             = module.vpc.subnet2_id // Private Subnet
  avl_zone              = var.avl_zone
  key_name              = aws_key_pair.generated_key.key_name
  private_key           = tls_private_key.terra_sshkey.private_key_pem
  bastionhostprivateip  = module.bastion.bastion-private-ip // Whitelisting
  bastionhostpublicip   = module.bastion.bastion-public-ip
  teamserver_hostname   = "teamserver"
  teamserver_private_ip = module.teamserver.teamserver_private_ip
  ssh_user              = var.ssh_user
}

module "teamserver" {
  depends_on = [module.bastion]

  source               = "./modules/aws/teamserver"
  ami_id               = data.aws_ami.latest_ubuntu.id
  install_redelk       = module.bastion.install_redelk
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.subnet2_id // Private Subnet
  avl_zone             = var.avl_zone
  key_name             = aws_key_pair.generated_key.key_name
  private_key          = tls_private_key.terra_sshkey.private_key_pem
  bastionhostprivateip = module.bastion.bastion-private-ip // Whitelisting
  bastionhostpublicip  = module.bastion.bastion-public-ip
  ssh_user             = var.ssh_user
}

module "http-redirector" {
  depends_on = [
    module.bastion, module.teamserver
  ]

  source               = "./modules/aws/http-redirector"
  mycount              = 1
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.subnet1_id // Public Subnet
  ami_id               = data.aws_ami.latest_ubuntu.id
  avl_zone             = var.avl_zone
  key_name             = aws_key_pair.generated_key.key_name
  private_key          = tls_private_key.terra_sshkey.private_key_pem
  bastionhostprivateip = module.bastion.bastion-private-ip // Whitelisting
  bastionhostpublicip  = module.bastion.bastion-public-ip
  cs_private_ip        = module.teamserver.teamserver_private_ip
  ssh_user             = var.ssh_user
  install_redelk       = true
  redirect_url         = "www.google.com"
  my_uri               = "hackspacecon"
}

module "gophish" {
  depends_on = [
    module.bastion
  ]

  source               = "./modules/aws/gophish"
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.subnet2_id // Private Subnet
  ami_id               = data.aws_ami.latest_ubuntu.id
  avl_zone             = var.avl_zone
  key_name             = aws_key_pair.generated_key.key_name
  private_key          = tls_private_key.terra_sshkey.private_key_pem
  bastionhostprivateip = module.bastion.bastion-private-ip // Whitelisting
  bastionhostpublicip  = module.bastion.bastion-public-ip
  ssh_user             = var.ssh_user
}

module "evilginx" {
  depends_on = [
    module.bastion
  ]

  source               = "./modules/aws/evilginx"
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.subnet1_id // Public Subnet
  ami_id               = data.aws_ami.latest_ubuntu.id
  avl_zone             = var.avl_zone
  key_name             = aws_key_pair.generated_key.key_name
  private_key          = tls_private_key.terra_sshkey.private_key_pem
  bastionhostprivateip = module.bastion.bastion-private-ip // Whitelisting
  bastionhostpublicip  = module.bastion.bastion-public-ip
  ssh_user             = var.ssh_user
  domain_name          = var.evilginx_domain_name
}

/*
  The part below will be used to create a web server and clone a website to it.
*/

# module "namecheap_to_route53" {
#   source = "./modules/aws/namecheap-to-route53"

#   domains = var.domains
# }

# module "webclone-server" {
#     depends_on = [module.namecheap_to_route53]

#     mycount              = 1
#     source               = "./modules/aws/webserver-clone"
#     instance_type        = "t3.micro"
#     hostname             = "web-server"
#     ami_id               = data.aws_ami.latest_ubuntu.id
#     ssh_user             = "ubuntu"
#     vpc_id               = module.vpc.vpc_id
#     subnet_id            = module.vpc.subnet1_id
#     avl_zone             = var.avl_zone
#     key_name             = aws_key_pair.generated_key.key_name
#     private_key          = tls_private_key.terra_sshkey.private_key_pem
#     bastionhostprivateip = module.bastion.bastion-private-ip
#     bastionhostpublicip  = module.bastion.bastion-public-ip
#     open_ports           = [443, 80]
#     domain_names         = ["example.com"]
#     website_url          = ["www.example.com"]
# }

# module "plain-instance" {
#   depends_on           = [module.namecheap_to_route53]
#   source               = "./modules/aws/plain"
#   mycount              = 1
#   instance_type        = "t3.micro"
#   hostname             = "web-server"
#   ami_id               = data.aws_ami.latest_ubuntu.id
#   ssh_user             = "ubuntu"
#   vpc_id               = module.vpc.vpc_id
#   subnet_id            = module.vpc.subnet1_id
#   avl_zone             = var.avl_zone
#   key_name             = aws_key_pair.generated_key.key_name
#   private_key          = tls_private_key.terra_sshkey.private_key_pem
#   bastionhostprivateip = module.bastion.bastion-private-ip
#   bastionhostpublicip  = module.bastion.bastion-public-ip
#   open_ports           = [443, 80]
#   domain_names         = ["example.com"]
#   ansible_playbook     = "./Ansible/website-cloner/main.yml"
# }

# module "mailgun" {
#   source                 = "./modules/mailgun"
#   mailgun_domain_name    = ["example.com"]
#   mailgun_region         = "us"
#   mailgun_smtp_users     = ["ubuntu"]
#   mailgun_smtp_passwords = ["v3ryS3cur3P@ssw0rd"]
# }

resource "null_resource" "ssh_config_cleanup" {
  # This triggers change on every apply to ensure the destroy provisioner will run even if nothing else changes.
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/ssh_config"
  }
}