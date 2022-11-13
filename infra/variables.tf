variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "server_domain_zone" {
  type      = string
  sensitive = true
}

variable "server_domain_name" {
  type    = string
  default = "@"
}
