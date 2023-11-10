resource "cloudflare_access_identity_provider" "pin_login" {
  zone_id = var.cloudflare_zone_id
  name    = "Login with one time PIN"
  type    = "onetimepin"
}

resource "cloudflare_access_identity_provider" "google" {
  zone_id = var.cloudflare_zone_id
  name    = "Login with Google"
  type    = "google"

  config {
    client_id     = var.google_client_id
    client_secret = var.google_client_secret
  }
}

resource "cloudflare_access_identity_provider" "github" {
  zone_id = var.cloudflare_zone_id
  name    = "Login with GitHub"
  type    = "github"

  config {
    client_id     = var.github_client_id
    client_secret = var.github_client_secret
  }
}
