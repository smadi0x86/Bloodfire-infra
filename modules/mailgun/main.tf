terraform {
  required_providers {
    mailgun = {
      source  = "wgebis/mailgun"
      version = "0.7.4"
    }
  }
}

provider "mailgun" {
  api_key = "<API Key>"
}

module "namecheap_to_route53" {
  source = "../../modules/aws/namecheap-to-route53"

  domains = var.mailgun_domain_name
}

resource "mailgun_domain" "default" {
  depends_on = [
    module.namecheap_to_route53
  ]

  count         = length(var.mailgun_domain_name)
  name          = var.mailgun_domain_name[count.index]
  region        = var.mailgun_region
  spam_action   = "disabled"
  dkim_key_size = 1024
}

data "mailgun_domain" "domain" {
  count = length(var.mailgun_domain_name)
  depends_on = [
    mailgun_domain.default
  ]
  name = var.mailgun_domain_name[count.index]
}

# Create a new SMTP Mailgun credential
resource "mailgun_domain_credential" "mail_smtp_creds" {
  depends_on = [
    mailgun_domain.default
  ]

  count    = length(var.mailgun_domain_name)
  domain   = var.mailgun_domain_name[count.index]
  login    = var.mailgun_smtp_users[count.index]
  password = var.mailgun_smtp_passwords[count.index]
  region   = "us"

  lifecycle {
    ignore_changes = [password]
  }
}

data "aws_route53_zone" "selected" {
  count = length(var.mailgun_domain_name)
  depends_on = [
    mailgun_domain.default, module.namecheap_to_route53
  ]
  name = var.mailgun_domain_name[count.index]
}

resource "aws_route53_record" "mailgun-dkim" {
  count = length(var.mailgun_domain_name)
  depends_on = [
    mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = data.mailgun_domain.domain[count.index].sending_records.1.name
  type    = "TXT"
  ttl     = 60
  records = [
    "${data.mailgun_domain.domain[count.index].sending_records.1.value}"
  ]
}

resource "aws_route53_record" "mailgun-spf" {
  count = length(var.mailgun_domain_name)
  depends_on = [
    mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = data.mailgun_domain.domain[count.index].sending_records.0.name
  type    = "TXT"
  ttl     = 60
  records = [
    "${data.mailgun_domain.domain[count.index].sending_records.0.value}",
  ]
}

resource "aws_route53_record" "mailgun-cname" {
  count = length(var.mailgun_domain_name)
  depends_on = [
    mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = "email"
  type    = "CNAME"
  ttl     = 5

  weighted_routing_policy {
    weight = 10
  }

  set_identifier = "email"
  records = [
    "mailgun.org"
  ]
}

resource "aws_route53_record" "dmarc-record" {
  count = length(var.mailgun_domain_name)
  depends_on = [
    mailgun_domain.default, module.namecheap_to_route53
  ]
  zone_id = data.aws_route53_zone.selected[count.index].zone_id
  name    = "_dmarc"
  type    = "TXT"
  ttl     = 60
  records = [
    "v=DMARC1; p=none"
  ]
}
