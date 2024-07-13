# Bloodfire-infra: Red Team Infrastructure Development Guide

## Overview

This document provides a development guide for the Bloodfire-infra Red Team infrastructure.

The infrastructure includes the following components:

- `modules/`: Terraform modules for each component of the infrastructure (aws and mailgun).
- `main.tf`: Main Terraform configuration file that defines the infrastructure components.
- `variables.tf`: Terraform variables file that defines the input variables for the infrastructure.
- `Ansible/`: Ansible playbooks for configuring the hosts in the infrastructure.
- `create-ssh-config.sh`: Bash script to create an `ssh_config` file for easy SSH access to the hosts.
- `modules/aws/`: Terraform module for creating the AWS infrastructure and it executes ansible playbooks to configure the hosts.
- `modules/mailgun/`: Terraform module for creating the Mailgun infrastructure by using route53 module from aws and creates a new smtp domain in mailgun.

## Getting Started

1. Editing the `/modules/aws/` files to customize the infrastructure components.

You can customize the infrastructure components by editing the Terraform files in the `/modules/aws/` directory. Each component has its own Terraform file that defines the resources and configurations for that component.

For more information on how to customize the Terraform files, refer to the [Terraform documentation](https://www.terraform.io/docs/index.html).

2. Adding new applications to the infrastructure by editing the `/Ansible/` playbooks.

You can add new applications to the infrastructure by creating Ansible playbooks in the `/Ansible/` directory. Each playbook defines the tasks and configurations required to install and configure the application on the hosts.

An example would be:

```yaml
---
- name: Install RedELK with Ansible
  hosts: localhost
  connection: local
  become: yes
  vars:
    redelk_repo: "https://github.com/outflanknl/RedELK"
    redelk_install_dir: "/home/ubuntu/RedELK"
    config_file_source: "/tmp/redelkconfig.cnf"
    config_file_dest: "{{ redelk_install_dir }}/certs/config.cnf"
```

This playbook installs RedELK on the hosts by cloning the RedELK repository, copying the configuration file, and running the RedELK setup script.

After creating the playbook, you can go to the resource you want to add the playbook to (e.g: /modules/aws/bastion/main.tf) and add the following code:

```hcl
  provisioner "remote-exec" {
    inline = [
      "Downloading 'RedELK...'",
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook /home/ubuntu/Ansible/redelk/download_redelk.yml",
    ]
  }
```

This dowloaded redelk on the bastion host.

For more information on how to create Ansible playbooks, refer to the [Ansible documentation](https://docs.ansible.com/ansible/latest/index.html).

3. Configuring the `/variables.tf` file to define the input variables for the infrastructure.

You can configure the input variables for the infrastructure by editing the `variables.tf` file. This file defines the variables that are used in the Terraform configuration files to customize the infrastructure components.

For example, you can define the following variables in the `variables.tf` file:

```hcl
variable "aws_region" {
  description = "The AWS region to deploy the infrastructure in."
  type        = string
  default     = "us-east-1"
}
```

This variable defines the AWS region where the infrastructure will be deployed and sets the default value to `us-east-1`.

For more information on how to configure variables in Terraform, refer to the [Terraform documentation](https://www.terraform.io/docs/configuration/variables.html).

4. Initializing and validating the Terraform configuration.

After customizing the Terraform files and variables, you can initialize and validate the Terraform configuration by running the following commands in the project root directory:

```bash
terraform validate # To ensure there are no errors in the configuration.
terraform init # To initialize the Terraform configuration.
terraform plan # To review the changes Terraform will apply to your AWS infrastructure.
terraform apply # To apply the changes to create the infrastructure.
```

5. Calling all the modules in the `main.tf` file.

After customizing the modules, you can call all the modules in the `main.tf` file by adding the following code:

```hcl
module "aws" {
  source = "./modules/aws"
}
```

This code calls the `aws` module and executes the Terraform configuration defined in the `modules/aws` directory.

For more information on how to call modules in Terraform, refer to the [Terraform documentation](https://www.terraform.io/docs/configuration/modules.html).
