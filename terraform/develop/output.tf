output "control_plane_ipv4" {
  value = aws_instance.develop_control_plane.public_ip
}

output "worker_nodes_ipv4" {
  value = [for instance in aws_instance.develop_worker_nodes : instance.public_ip]
  # value = join("", aws_instance.develop_worker_nodes[*].public_ip)
}