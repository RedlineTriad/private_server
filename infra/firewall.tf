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
