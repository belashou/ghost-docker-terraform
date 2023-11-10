resource "cloudflare_tunnel_config" "ssh_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id

  config {
    ingress_rule {
      hostname = "ssh.${var.cloudflare_zone}"
      service  = "ssh://localhost:22"
    }
    ingress_rule {
      hostname = "backup.${var.cloudflare_zone}"
      service  = "http://localhost:8090"
    }
    ingress_rule {
      hostname = var.cloudflare_zone
      service  = "http://localhost:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.cloudflare_zone
  secret     = random_id.tunnel_secret.b64_std
  config_src = "cloudflare"
}

locals {
  tunnel_token = base64encode(<<-EOF
    {"a":"${var.cloudflare_account_id}","t":"${cloudflare_tunnel.tunnel.id}","s":"${random_id.tunnel_secret.b64_std}"}
    EOF
  )
}

output "tunnel_token" {
  value = local.tunnel_token
}