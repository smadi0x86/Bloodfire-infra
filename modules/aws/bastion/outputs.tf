output "bastion-ip" {
  value = "Bastion Public IP: ${aws_instance.bastion.public_ip}"
}

output "bastion-private-ip" {
  value = aws_instance.bastion.private_ip
}

output "bastion-public-ip" {
  value = aws_instance.bastion.public_ip
}

output "install_redelk" {
  value = var.install_redelk
}
