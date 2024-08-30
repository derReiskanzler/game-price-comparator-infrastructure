resource "ansible_host" "develop_control_plane" {
  depends_on = [ aws_instance.develop_control_plane ]
  name = "control_plane"
  groups = ["master"]
  variables = {
    ansible_user = "ubuntu"
    ansible_host = aws_instance.develop_control_plane.public_ip
    ansible_ssh_private_key_file = ".ssh/operator"
    node_hostname = "master" # has to match with name ./files/hosts
  }
}

resource "ansible_host" "develop_worker_nodes" {
  depends_on = [ aws_instance.develop_worker_nodes ]
  count = 2
  name = "worker-${count.index}"
  groups = ["workers"]
  variables = {
    ansible_user = "ubuntu"
    ansible_host = aws_instance.develop_worker_nodes[count.index].public_ip
    ansible_ssh_private_key_file = ".ssh/operator"
    node_hostname = "worker-${count.index}" # has to match with name in ./files/hosts
  }
}
