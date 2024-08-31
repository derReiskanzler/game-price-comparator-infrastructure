#!/bin/sh

# Destroy
echo "🔄 Destroying existing infrastructure first..."
terraform destroy --auto-approve
echo "✅ Existing Infrastructure destroyed.\n"


# Initialize
echo "🔄 Initializing terraform provider..."
terraform init
echo "✅ terraform initialization done.\n"

# Apply
terraform apply --auto-approve
echo "✅ Infrastructure provisioned.\n"

# Check if the plugin works by printing the parsed hosts file (from the terraform state)
# for ansible to be accessible in order to create a dynamic hosts file
# ansible-inventory -i inventory.yaml --graph
# Expected output something like:
# @all:
#   |--@ungrouped:
#   |--@master:
#   |  |--control_plane
#   |--@workers:
#   |  |--worker-0
#   |  |--worker-1

# Run Ansible Playbook
# so it can create and execute commands on the remote host machines
# Problems with sudo password while running the playbook: ansible-playbook -i inventory.yaml playbook.yaml
# thats why `--ask-become-pass` flag is used: https://stackoverflow.com/questions/21870083/specify-sudo-password-for-ansible
echo "🔄 Run playbook..."
ansible-playbook -i inventory.yaml playbook.yaml --ask-become-pass
echo "✅ Playbook applied. Infrastructure provisioned and managed.\n"

echo "🔄 Applying k8 ressources..."
ssh -i .ssh/operator -l ubuntu $(terraform output -raw 'control_plane_ipv4') 'sh ./deployment/apply.sh'

echo "Waiting 10s before printing resource overview...\n"
sleep 10
# Sets the config as default by exporting the path to the file as the KUBECONFIG-Variable
# Overwrites kubeconfig on your machine with remote config
# that has been saved on your machine after running the playbook (only temporarily - resets as soon as you destroy everything)
# For local config -> you can run 'kubectl config view' to access the cluster from your local machine
# Comment this for production as for security reasons cluster config should not be copied anywhere away from the remote machines
export KUBECONFIG=/tmp/kubeconfig/config
# kubectl config view

# Health Check/Overview
echo "🏥 All nodes in cluster:"
kubectl get nodes -o wide
echo "\n"

echo "🏥 All ressources in cluster:"
kubectl get all --all-namespaces
echo "\n"

echo "🏥 Cluster info:"
kubectl cluster-info
echo "\n"

# Set default path for local kubeconfig & delete config copied from remote machine
export KUBECONFIG=~/.kube/config
rm -rf /tmp/kubeconfig/config
