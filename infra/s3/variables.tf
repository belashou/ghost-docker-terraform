variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
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