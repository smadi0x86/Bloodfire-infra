# Bloodfire-infra: Red Team Infrastructure

<div align="center">
  <img src="https://github.com/smadi0x86/Bloodfire-infra/assets/75253629/0a2afe55-f957-4882-abb0-9e80d2041517" alt="Fire-Blood">
</div>

## Overview

Bloodfire-infra is a Red Team infrastructure that can be deployed on AWS using Terraform and Ansible. The infrastructure includes several components that can be used to conduct Red Team operations, such as phishing attacks and monitoring Red Team activities.

**The infrastructure includes the following components:**

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

   - Open a terminal in the project root folder.
   - Run `terraform init` to initialize the Terraform configuration.
   - Run `terraform validate` to ensure there are no errors in the configuration.

4. **Plan and Apply:**

   - Run `terraform plan` to review the changes Terraform will apply to your AWS infrastructure.
   - Run `terraform apply` to create the infrastructure.

**Note:** Make sure you have the necessary AWS credentials configured on your machine using `aws configure`.

## SSH Configuration

After `terraform apply` is completed, a bash script and an `ssh_config` file will be created. You can use these to SSH into the hosts without worrying about port forwarding.

```bash
ssh -X -F ssh_config bastion    # SSH into Bastion host with X11 forwarding for client
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

This is an optional step, you can install the client wherever you like but make sure to update security group rules to allow traffic from the client to the teamserver (which is only possible from the bastion host by default).

1. SSH into the bastion host.
2. Move to `/opt/havoc` directory.
3. Run `./havoc client` to start the client.

**Note: Make sure you have the teamserver running, as an example SSH into the teamserver from the bastion host then:**

```bash
cd /opt/havoc
sudo ./havoc server --profile ./profiles/havoc.yaotl -v --debug
```

## Development

Please refer to the [DEVELOPMENT.md](DEVELOPMENT.md) file for detailed instructions on how to develop and customize the infrastructure.

## Known Issues

### Error while running the client on the bastion host

When running the client on the bastion host, it gives the following error:

```bash
[20:53:30] [info] Havoc Framework [Version: 0.7] [CodeName: Bites The Dust]
[20:53:30] [error] [DB] Failed to open database
[20:53:30] [info] loaded config file: client/config.toml
QSqlQuery::prepare: database not open
[20:53:30] [error] [DB] Error while query teamserver list: No query Unable to fetch row
[20:53:50] [info] Exit program from Connection Dialog
```

Also note that the client GUI spins up and you can connect to the teamserver but the error is still there.

## License

This project is licensed under the GPL-3.0 License - see the [LICENSE](https://github.com/smadi0x86/Bloodfire-infra/blob/main/LICENSE) file for details.

## Acknowledgements

https://github.com/dazzyddos/HSC24RedTeamInfra
