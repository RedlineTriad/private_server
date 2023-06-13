resource "hcloud_server" "web" {
  name        = "web"
  image       = "debian-11"
  server_type = "cpx21"
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
