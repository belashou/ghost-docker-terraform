variable "keys_folder" {
  type      = string
  sensitive = false
  default   = "~/.ssh/ghost"
}

variable "hcloud_token" {
  type      = string
  sensitive = true
}

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

variable "app_bucket_name" {
  description = "Bucket to store Ghost data"
  type = string
}

variable "app_backup_bucket_name" {
  description = "Bucket to store Ghost backups"
  type = string
}

variable "node_base_path" {
  description = "Directory on the node where Docker volumes will be mounted"
  type = string
}

variable "s3_access_key" {
  description = "S3 Bucket Key ID"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 Bucket Access Key"
  type        = string
  sensitive   = true
}

variable "docker_registry" {
  type = string
}

variable "docker_user" {
  type = string
}

variable "docker_password" {
  type = string
  sensitive = true
}
