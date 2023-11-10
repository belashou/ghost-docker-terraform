module "cloudflare" {
  source = "./cloudflare"
  
  cloudflare_token        = var.cloudflare_token

  cloudflare_zone_id      = var.cloudflare_zone_id
  cloudflare_account_id   = var.cloudflare_account_id
  cloudflare_zone         = var.cloudflare_zone
  cloudflare_admin_emails = var.cloudflare_admin_emails

  google_client_id        = var.google_client_id
  google_client_secret    = var.google_client_secret
  github_client_id        = var.github_client_id
  github_client_secret    = var.github_client_secret
}

module "node" {
  source     = "./node"
  depends_on = [module.cloudflare]

  hcloud_token = var.hcloud_token

  app_key_pub     =  "${var.keys_folder}/${var.cloudflare_zone}.app.id_ed25519.pub"
  root_key_pub     = "${var.keys_folder}/${var.cloudflare_zone}.root.id_ed25519.pub"
  root_key_private = "${var.keys_folder}/${var.cloudflare_zone}.root.id_ed25519"
  tunnel_token     = module.cloudflare.tunnel_token

  node_base_path = var.node_base_path

  docker_registry = var.docker_registry
  docker_user = var.docker_user
  docker_password = var.docker_password
}

module "s3" {
  source     = "./s3"
  
  cloudflare_account_id = var.cloudflare_account_id

  app_bucket_name = var.app_bucket_name
  app_backup_bucket_name = var.app_backup_bucket_name
  s3_secret_key = var.s3_secret_key
  s3_access_key = var.s3_access_key

}
