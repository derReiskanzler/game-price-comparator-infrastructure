variable "ssh_public_key_path" {
  type = string
  default = "../.ssh/operator.pub"
  description = "path to the public part of the SSH key pair"
}

variable "key_name" {
  type        = string
  description = "the name of our keypair"
  default     = "develop_aws_key"
}

variable "availability_zone" {
  type        = string
  description = "availability zone"
  default     = "us-east-1a"
}

# ARM
variable "arm_ubuntu_ami" {
  type        = string
  description = "the arm AMI ID of our linux instance"
  default     = "ami-096ea6a12ea24a797"
}

variable "arm_small_instance_type" {
  type        = string
  description = "2 vCPU, 2 GiB RAM, 0.0168 USD"
  default     = "t4g.small"
}

variable "arm_medium_instance_type" {
  type        = string
  description = "2 vCPU, 4 GiB RAM, 0.0336 USD"
  default     = "t4g.medium"
}

variable "worker_nodes_count" {
  type        = number
  description = "the total number of worker nodes"
  default     = 2
}

variable "cidr_vpc" {
  description = "cidr range for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cidr_subnet" {
  description = "cidr range for public VPC Subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# variable "k8s_name" {
#   type        = string
#   description = "cluster"
#   default     = "kubeadm-cluster"
# }

# x86
# variable "x86_ubuntu_ami" {
#   type = string
#   description = "the x86 AMI ID of our linux instance"
#   default = "ami-0e86e20dae9224db8"

#   # from tutorial
#   # default = "ami-053b0d53c279acc90"
# }

# variable "x86_small_instance_type" {
#   type = string
#   description = "2 vCPU, 2 GiB RAM, 0.0168 USD"
#   default = "t2.small"
# }

# variable "x86_medium_instance_type" {
#   type = string
#   description = "2 vCPU, 4 GiB RAM, 0.0464 USD"
#   default = "t2.medium"
# }

# variable "availability_zone" {
#   description = "Availability zone of resources"
#   default     = "us-east-1a"
#   type        = string
# }

# variable "vpc_cidr_block" {
#   type = string
#   description = "vpc default cidr block"
#   default = "10.0.0.0/16"
# }
