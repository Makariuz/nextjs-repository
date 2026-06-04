resource "hcloud_firewall" "waterFirewall" {
  name = "water-firewall"
  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

module "hcloud_server" {
  source = "github.com/Makariuz/up-down//modules/server"

  hcloud_server = {
    name         = "nextjs-server"
    image        = "ubuntu-22.04"
    server_type  = "cx23"
    firewall_ids = [hcloud_firewall.waterFirewall.id]
    owner        = "makariuz"
    user_data    = file("scripts/cloud-init.sh")
  }

  ssh_key = {
    name    = "nextjs-terraform-key"
    ssh_key = file("~/.ssh/id_ed25519.pub")
  }

}
