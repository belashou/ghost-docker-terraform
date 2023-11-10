resource "cloudflare_record" "backup_record" {
  zone_id = var.cloudflare_zone_id
  name    = "backup"
  value   = "${cloudflare_tunnel.tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_access_application" "backup_app" {
  zone_id          = var.cloudflare_zone_id
  name             = "backup.${var.cloudflare_zone} app"
  domain           = "backup.${var.cloudflare_zone}"
  type             = "self_hosted"
  session_duration = "1h"
  allowed_idps = [
    cloudflare_access_identity_provider.pin_login.id,
    cloudflare_access_identity_provider.google.id,
    cloudflare_access_identity_provider.github.id
  ]
}

resource "cloudflare_access_group" "backup_access_group" {
  zone_id = var.cloudflare_zone_id
  name    = "backup.${var.cloudflare_zone} group"

  include {
    email = var.cloudflare_admin_emails
  }
}

resource "cloudflare_access_policy" "backup_policy" {
  application_id = cloudflare_access_application.backup_app.id
  zone_id        = var.cloudflare_zone_id
  name           = "backup.${var.cloudflare_zone} policy"
  precedence     = "1"
  decision       = "allow"
  include {
    group = [cloudflare_access_group.backup_access_group.id]
  }
}
