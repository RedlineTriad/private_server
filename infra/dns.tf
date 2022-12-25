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
