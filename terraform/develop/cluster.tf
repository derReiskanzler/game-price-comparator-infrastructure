resource "aws_key_pair" "develop" {
  key_name   = var.key_name
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "develop_control_plane" {
  # instance_type               = var.x86_medium_instance_type
  # ami                         = var.x86_ubuntu_ami
  instance_type               = var.arm_medium_instance_type
  ami                         = var.arm_ubuntu_ami
  key_name                    = aws_key_pair.develop.key_name
  subnet_id                   = aws_subnet.develop.id
  associate_public_ip_address = true

  # vpc_security_group_ids = [
  #   aws_security_group.allow_inbound_ssh_http_https.id,
  #   aws_security_group.control_plane_security_group.id,
  #   aws_security_group.weavenet_security_group.id,
  # ]
  # security_groups = [
  #   aws_security_group.allow_inbound_ssh_http_https.name,
  #   aws_security_group.control_plane_security_group.name,
  #   aws_security_group.flannel_security_group.name,
  # ]
  vpc_security_group_ids = [
    aws_security_group.allow_inbound_ssh_http_https.id,
    aws_security_group.control_plane_security_group.id,
    aws_security_group.flannel_security_group.id,
  ]

  root_block_device {
    volume_type = "gp2"
    volume_size = 14
  }

  tags = {
    Name = "develop_control_plane"
    Role = "Control plane node"
  }

  provisioner "local-exec" {
    command = "echo 'master ${self.public_ip}' >> ./files/hosts"
  }
}

resource "aws_instance" "develop_worker_nodes" {
  # instance_type               = var.x86_small_instance_type
  # ami                         = var.x86_ubuntu_ami
  count                       = var.worker_nodes_count
  instance_type               = var.arm_small_instance_type
  ami                         = var.arm_ubuntu_ami
  key_name                    = aws_key_pair.develop.key_name
  subnet_id                   = aws_subnet.develop.id
  associate_public_ip_address = true


  # vpc_security_group_ids = [
  #   aws_security_group.allow_inbound_ssh_http_https.id,
  #   aws_security_group.worker_node_security_group.id,
  #   aws_security_group.weavenet_security_group.id,
  # ]
  # security_groups = [
  #   aws_security_group.allow_inbound_ssh_http_https.name,
  #   aws_security_group.worker_node_security_group.name,
  #   aws_security_group.flannel_security_group.name,
  # ]
  vpc_security_group_ids = [
    aws_security_group.allow_inbound_ssh_http_https.id,
    aws_security_group.worker_node_security_group.id,
    aws_security_group.flannel_security_group.id,
  ]

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = {
    Name = "develop_worker_${count.index}"
    Role = "Worker node"
  }

  provisioner "local-exec" {
    command = "echo 'worker-${count.index} ${self.public_ip}' >> ./files/hosts"
  }

}
