resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = "t3.medium"
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  tags = {
    Name = "bastion-host"
  }

  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = var.private_key
    host        = aws_instance.bastion.public_ip
  }

  // Copy the generated SSH key to the instance
  provisioner "file" {
    source      = "./generated_key.pem"
    destination = "/home/ubuntu/.ssh/id_rsa"
  }

  // Copy the Ansible playbook to the instance
  provisioner "file" {
    source      = "./Ansible"
    destination = "/home/ubuntu/Ansible"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo hostnamectl set-hostname bastion",
      "sudo apt install net-tools -y",
      "chown ubuntu /home/ubuntu/.ssh/id_rsa",
      "chgrp ubuntu /home/ubuntu/.ssh/id_rsa",
      "chmod 600 /home/ubuntu/.ssh/id_rsa",
      "sudo apt install software-properties-common -y",
      "sudo apt-add-repository --yes --update ppa:ansible/ansible",
      "sudo apt install ansible -y"
    ]
  }

  provisioner "local-exec" {
    when    = create
    command = "./create-ssh-config.sh 'bastion' '${self.public_ip}' '${var.ssh_user}' './generated_key.pem' './ssh_config' 'true'"
  }
}

resource "null_resource" "install_redelk" {
  depends_on = [
    aws_instance.bastion
  ]

  count = var.install_redelk ? 1 : 0

  connection {
    type        = "ssh"
    host        = aws_instance.bastion.public_ip
    user        = var.ssh_user
    private_key = var.private_key
  }

  provisioner "file" {
    source      = "./modules/aws/redelk/config.cnf"
    destination = "/tmp/redelkconfig.cnf"
  }

  provisioner "remote-exec" {
    inline = [
      "Downloading 'RedELK...'",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook /home/ubuntu/Ansible/redelk/download_redelk.yml",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i /home/ubuntu/Ansible/client/inventory.ini /home/ubuntu/Ansible/client/client.yaml",
    ]
  }
}
