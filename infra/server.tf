# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

# Create a new server running debian
resource "hcloud_server" "web" {
  name        = "web"
  image       = "debian-10"
  server_type = "cpx11"
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
}