# Bloodfire-infra: Red Team Infrastructure

<div align="center">
  <img src="https://github.com/smadi0x86/Bloodfire-infra/assets/75253629/0a2afe55-f957-4882-abb0-9e80d2041517" alt="Fire-Blood">
</div>

## Overview

Bloodfire-infra is a Red Team infrastructure.

The infrastructure includes the following components:

- **Bastion Host:** A host that acts as a gateway to access the other hosts in the infrastructure.
- **Evilginx:** A phishing attack tool that can be used to clone login pages and steal credentials.
- **GoPhish:** An open-source phishing framework that can be used to run phishing campaigns.
- **RedELK:** An open-source tool that can be used to monitor and analyze Red Team activities.

## Getting Started

1. **Customize Modules:**

   - Open `main.tf`.
   - Uncomment/comment the modules you wish to use.
   - Fill in the required values for each module.

2. **Configure Variables:**

   - Open `variables.tf`.
   - Fill in all necessary values.

3. **Initialize and Validate:**

   - Open a terminal in the project folder.
   - Run `terraform init` to initialize the Terraform configuration.
   - Run `terraform validate` to ensure there are no errors in the configuration.

4. **Plan and Apply:**
   - Run `terraform plan` to review the changes Terraform will apply to your AWS infrastructure.
   - Run `terraform apply` to create the infrastructure.

## SSH Configuration

After `terraform apply` is completed, a bash script and an `ssh_config` file will be created. You can use these to SSH into the hosts without worrying about port forwarding.

```bash
ssh -F ssh_config bastion       # SSH into Bastion host
ssh -F ssh_config evilginx      # SSH into Evilginx host
ssh -F ssh_config gophish       # SSH into GoPhish host
ssh -F ssh_config redelk        # SSH into RedELK host
```

When you SSH into the GoPhish or RedELK hosts, port forwarding will be set up automatically.

## Accessing Interfaces

### RedELK Interface

- URL: https://127.0.0.1
- Username: redelk
- Password: redelk@123

### GoPhish Interface

- URL: https://127.0.0.1:3333
- Username: admin
- Password: gophish@123

## Accessing Havoc C2 Client
