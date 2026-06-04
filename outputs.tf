output "instance_id" {
    description = "ID for the instance"
    value = module.hcloud_server.instance_id
}

output "instance_ip" {
  description = "IP for the instance"
  value = module.hcloud_server.instance_ip
}