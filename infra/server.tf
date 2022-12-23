resource "hcloud_server" "web" {
  name        = "web"
  image       = "debian-11"
  server_type = "cpx11"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.ansible.name]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}

resource "hcloud_volume" "data" {
  name      = "data"
  size      = 10
  server_id = hcloud_server.web.id
  automount = true
  format    = "ext4"
}

resource "hcloud_ssh_key" "ansible" {
  name       = "Ansible"
  public_key = var.ansible_ssh_public_key
}

resource "hcloud_firewall" "web_firewall" {
  name = "web_firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  dynamic "rule" {
    for_each = toset([22, 80, 443])
    content {
      direction = "in"
      protocol  = "tcp"
      port      = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }

  dynamic "rule" {
    for_each = toset([443])
    content {
      direction = "in"
      protocol  = "udp"
      port      = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }
}

resource "hcloud_firewall_attachment" "firewall_assignments" {
  firewall_id = hcloud_firewall.web_firewall.id
  server_ids  = [hcloud_server.web.id]
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

locals {
  docker_compose_file_paths = fileset(".", "../software/roles/docker_compose_apps/templates/*/docker-compose.yml")
  docker_compose_data       = [for path in local.docker_compose_file_paths : yamldecode(file(path))]
  services                  = flatten([for data in local.docker_compose_data[*].services : values(data)])
  labels                    = flatten([for service in local.services : try(service.labels, [])])
  subdomains                = flatten([for label in local.labels : try(regex(".*Host\\(`(\\w+)\\.\\$BASE_DOMAIN`\\).*", label), [])])
}

resource "cloudflare_record" "aliases" {
  for_each = toset(local.subdomains)
  zone_id  = cloudflare_zone.personal_domain.id
  name     = each.key
  value    = "@"
  type     = "CNAME"
  ttl      = 300
}
