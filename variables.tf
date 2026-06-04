variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "ssh_key" {
  description = "SSH public key for accessing the HCLOUD server"
  type = object({
    name    = string
    ssh_key = string
  })

}

variable "hcloud_server" {
  description = "Configuration for the HCLOUD server"
  type = object({
    name        = string
    image       = string
    server_type = string
    firewall_ids = list(string)
    owner       = string
    user_data   = string
  })
}