#!/bin/sh
printf "Destroying existing infrastcuture first..."
terraform destroy --auto-approve

terraform init

printf "✅ terraform initialization done."

terraform apply --auto-approve

printf "✅ Infrastructure provisioned."

printf "Installing ansible's terraform plugin collection..."
ansible-galaxy collection install cloud.terraform

printf "Run playbook..."
ansible-playbook -i inventory.yaml playbook.yaml --ask-become-pass

printf "✅ Playbook applied. Infrastructure provisioned and managed."

export KUBECONFIG=/tmp/kubeconfig/config

printf "All ressources in cluster:"
kubectl get pods --all-namespaces

printf "All nodes in cluster:"
kubectl get nodes

kubectl cluster-info
printf "✅ Cluster is healthy"

printf "Copy k8-ressources into control panel..."
scp -i ../.ssh/operator -r ../../develop/backend ubuntu@$(terraform output -raw 'control_plane_ipv4'):~/deployment
scp -i ../.ssh/operator -r ../../develop/frontend ubuntu@$(terraform output -raw 'control_plane_ipv4'):~/deployment
printf "✅ Copied k8-ressources into control panel."


printf "Applying k8 ressources..."
ssh -i ../.ssh/operator -l ubuntu $(terraform output -raw 'control_plane_ipv4') 'bash -s' < ./files/apply.sh

printf "Opening SSH console to control plane..."
ssh -i ../.ssh/operator -l ubuntu $(terraform output -raw 'control_plane_ipv4')