resource "hcloud_server" "web" {
  name        = "web"
  image       = "debian-11"
  server_type = "cpx11"
  ssh_keys    = [hcloud_ssh_key.ansible.name]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_ssh_key" "ansible" {
  name       = "Ansible"
  public_key = var.ansible_ssh_public_key
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
