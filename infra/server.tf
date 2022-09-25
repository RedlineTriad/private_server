variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type = string
  sensitive = true
}

variable "server_domain_zone" {
  type = string
}

variable "server_domain_name" {
  type = string
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "hcloud_server" "web" {
  name        = "web"
  image       = "debian-10"
  server_type = "cpx11"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "cloudflare_zone" "personal_domain" {
  zone = var.server_domain_zone
  lifecycle {
      prevent_destroy = true
  }
}

resource "cloudflare_record" "a" {
  zone_id = cloudflare_zone.personal_domain.id
  name    = var.server_domain_name
  value   = hcloud_server.web.ipv4_address
  type    = "A"
  ttl     = 300
}

resource "cloudflare_record" "aaaa" {
  zone_id = cloudflare_zone.personal_domain.id
  name    = var.server_domain_name
  value   = hcloud_server.web.ipv6_address
  type    = "AAAA"
  ttl     = 300
}
