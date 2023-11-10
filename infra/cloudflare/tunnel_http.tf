resource "cloudflare_record" "http_record" {
  zone_id = var.cloudflare_zone_id
  name    = "@"
  value   = "${cloudflare_tunnel.tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}