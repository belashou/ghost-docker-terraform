variable "cloudflare_zone" {
  description = "Domain used to expose instance to the Internet"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Zone ID for your domain"
  type        = string
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_admin_emails" {
  description = "Admin emails for SSH access"
  type        = list(string)
  sensitive   = true
}

variable "cloudflare_token" {
  description = "Cloudflare API token created at https://dash.cloudflare.com/profile/api-tokens"
  type        = string
  sensitive   = true
}

variable "google_client_id" {
  description = "Google Client ID"
  type        = string
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google Client Secret"
  type        = string
  sensitive   = true
}

variable "github_client_id" {
  description = "Github Client ID"
  type        = string
  sensitive   = true
}

variable "github_client_secret" {
  description = "Github Client Secret"
  type        = string
  sensitive   = true
}
