resource "cloudflare_record" "ssh_record" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh"
  value   = "${cloudflare_tunnel.tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_access_application" "ssh_app" {
  zone_id          = var.cloudflare_zone_id
  name             = "ssh.${var.cloudflare_zone} app"
  domain           = "ssh.${var.cloudflare_zone}"
  type             = "ssh"
  session_duration = "1h"
  allowed_idps = [
    cloudflare_access_identity_provider.pin_login.id,
    cloudflare_access_identity_provider.google.id,
    cloudflare_access_identity_provider.github.id
  ]
}

resource "cloudflare_access_group" "ssh_service_token_access_group" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh.${var.cloudflare_zone} service token group"

  include {
    any_valid_service_token = true
  }
}

resource "cloudflare_access_policy" "ssh_service_token_policy" {
  application_id = cloudflare_access_application.ssh_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "ssh.${var.cloudflare_zone} service token policy"
  precedence     = "1"
  decision       = "non_identity"

  include {
    group = [cloudflare_access_group.ssh_service_token_access_group.id]
  }
}

resource "cloudflare_access_group" "ssh_idp_access_group" {
  zone_id = var.cloudflare_zone_id
  name    = "ssh.${var.cloudflare_zone} IDP group"

  include {
    email = var.cloudflare_admin_emails
  }
}

resource "cloudflare_access_policy" "ssh_idp_policy" {
  application_id = cloudflare_access_application.ssh_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "ssh.${var.cloudflare_zone} IDP policy"
  precedence     = "2"
  decision       = "allow"
  include {
    group = [cloudflare_access_group.ssh_idp_access_group.id]
  }
}