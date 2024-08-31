#!/bin/sh


# Destroy
echo "🔄 Destroying existing infrastructure first..."
terraform destroy --auto-approve
echo "✅ Existing Infrastructure destroyed."


# Initialize
echo "🔄 Initializing terraform provider..."
terraform init
echo "✅ terraform initialization done."

# Apply
terraform apply --auto-approve
echo "✅ Infrastructure provisioned."

# Install Ansible's Terraform Plugin
# Provide ansible for terraform - https://www.ansible.com/blog/providing-terraform-with-that-ansible-magic/
# The plugin is used in the inventory.yaml - https://galaxy.ansible.com/ui/repo/published/cloud/terraform/
echo "🔄 Installing ansible's terraform plugin collection..."
ansible-galaxy collection install cloud.terraform

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
# flag `--ask-become-pass` asks for your sudo password that is used on your local machine
# so it can create and execute commands on the remote host machines
echo "🔄 Run playbook..."
ansible-playbook -i inventory.yaml playbook.yaml --ask-become-pass
echo "✅ Playbook applied. Infrastructure provisioned and managed."

# Check kube config file and look for server property e.g. `server: https://[master-ip]`
# and check if it matches the master-ip (check master-ip in files/hosts).
# cat /tmp/kubeconfig/config

# Sets the config as default by exporting the path to the file as the KUBECONFIG-Variable
# Overwrites kubeconfig on your machine with remote config
# that has been saved on your machine after running the playbook (only temporarily - resets as soon as you destroy everything)
# For local config -> you can run 'kubectl config view' to access the cluster from your local machine
# Comment this for production as for security reasons cluster config should not be copied anywhere away from the remote machines
export KUBECONFIG=/tmp/kubeconfig/config
# kubectl config view

# Health Check/Overview
echo "🩺 All ressources in cluster:"
kubectl get pods --all-namespaces
# Or
# kubectl get all --all-namespaces

echo "🩺 All nodes in cluster:"
kubectl get nodes

echo "🩺 Cluster info:"
kubectl cluster-info
echo "✅ Cluster is healthy"

# echo "Copy k8-ressources into control panel..."
# scp -i .ssh/operator -r ../../develop/backend ubuntu@$(terraform output -raw 'control_plane_ipv4'):~/deployment
# scp -i .ssh/operator -r ../../develop/frontend ubuntu@$(terraform output -raw 'control_plane_ipv4'):~/deployment
# echo "✅ Copied k8-ressources into control panel."


echo "🔄 Applying k8 ressources..."
ssh -i .ssh/operator -l ubuntu $(terraform output -raw 'control_plane_ipv4') 'sh ./deployment/apply.sh'

echo "🔄 Opening SSH console to control plane..."
ssh -i .ssh/operator -l ubuntu $(terraform output -raw 'control_plane_ipv4')

# Check ingress controller
# kubectl get all -n ingress-nginx

# kubectl get pods -n cert-manager
# kubectl get all -n cert-manager
# kubectl describe certificate letsencrypt-prod

# kubectl get ingress

# nslookup fe-angular-game-price-comparator.develop.com
# nslookup be-java-game-price-comparator.develop.com