# Ports from https://kubernetes.io/docs/reference/networking/ports-and-protocols/
resource "aws_security_group" "control_plane_security_group" {
  vpc_id = aws_vpc.develop.id

  ingress {
    description = "API Server"
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "etcd server client API"
    protocol    = "tcp"
    from_port   = 2379
    to_port     = 2380
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API"
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube Scheduler"
    protocol    = "tcp"
    from_port   = 10259
    to_port     = 10259
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube Contoller Manager"
    protocol    = "tcp"
    from_port   = 10257
    to_port     = 10257
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "develop_control_plane_security_group"
  }
}

resource "aws_security_group" "worker_node_security_group" {
  vpc_id = aws_vpc.develop.id
  
  ingress {
    description = "kubelet API"
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort services"
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "develop_worker_node_security_group"
  }
}

resource "aws_security_group" "allow_inbound_ssh_http_https" {
  vpc_id = aws_vpc.develop.id

  ingress {
    description = "Allow SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "develo_allow_http_and_https_security_group"
  }
}

# Flannel ports from https://github.com/coreos/coreos-kubernetes/blob/master/Documentation/kubernetes-networking.md
resource "aws_security_group" "flannel_security_group" {
  vpc_id = aws_vpc.develop.id
  
  ingress {
    description = "flannel overlay backend"
    protocol    = "udp"
    from_port   = 8285
    to_port     = 8285
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "flannel vxlan backend"
    protocol    = "udp"
    from_port   = 8472
    to_port     =  8472
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "develop_flannel_overlay_backend_security_group"
  }
}

# resource "aws_security_group" "weavenet_security_group" {
#   ingress {
#     description = "Weavenet TCP"
#     protocol    = "tcp"
#     from_port   = 6783
#     to_port     = 6783
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Weavenet UDP"
#     protocol    = "udp"
#     from_port   = 6784
#     to_port     = 6784
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     description = "Weavenet UDP"
#     protocol    = "udp"
#     from_port   = 6783
#     to_port     = 6783
#     cidr_blocks = ["0.0.0.0/0"]
#   }


#   tags = {
#     Name = "develop_flannel_overlay_backend_security_group"
#   }
# }
