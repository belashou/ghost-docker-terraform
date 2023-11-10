variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "tunnel_token" {
  type = string
  sensitive = true
}

variable "root_key_private" {
  type = string
}

variable "root_key_pub" {
  type = string
}

variable "app_key_pub" {
  type = string
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

variable "node_base_path" {
  type = string
}