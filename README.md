# Game Price Comparator Infrastructure

The Game Price Comparator Infrastructure makes use of docker images published respectively in the [Backend]((https://github.com/kirdreamer/GamePriceComparator)) and [Frontend](https://github.com/derReiskanzler/fe-angular-game-price-comparator) Repository.

## Table Of Contents
1. [Local Setup with Minikube](#local-setup-with-minikube)
    - [Preparation](#preparation)
    - [Setup](#setup)
        - [Problems with Minikube on Unix-OS](#problems-with-minikube-on-unix-os)
    - [Stop](#stop)
2. [Local Setup with Terraform and Minikube](#local-setup-with-terraform-and-minikube)
    - [Problems with Minikube on Unix-OS (again)](#problems-with-minikube-on-unix-os-again)
2. [Remote Setup with Terraform, Ansible and Kubeadm](#remote-setup-with-terraform-ansible-and-kubeadm)

## Local Setup with minikube

In `./[develop,staging,production]/[backend,frontend]` relevant yaml-files can be found.
For the Backend:
   - `postgres.yaml`: contains PersistentVolumeClaim, Deployment and Service for postgres. 
   - `postgres-config.yaml`: contains Configuration for postgres
   - `postgres-secret.yaml.template`: Secrets template for postgres. Requires updating credentials.
   - `backend.yaml`: contains Deployment and Service (LoadBalancer) for Backend service
   - `ingress.yaml`:  contains Ingress for Backend service (Can be ignored as Frontend will take over this responsibility)
   - `image-checker.yaml`: responsible for checking new images of the Backend

### Preparation
To use environment variables for Backend you need to use .env.template as a template: 

- Create `.env` file based on `.env.template`
- Write your URL and credentials to connect database for PostgresDB. By default, URL is "localhost" and port is "5432".
- Add your gmail in MAIL_PROVIDER_USERNAME and App-password from google in MAIL_PROVIDER_PASSWORD: Google-Account -> Security -> 2-Factor Authentication -> App Passwords. To use a different mail provider, you must change the host in spring.mail.host
- Add secret key for jwt. To generate this key you can use such sites like [www.browserling.com](https://www.browserling.com/tools/random-hex)

#### Namespace

If required, create a namespace for each project or environment:
``` bash
kubectl create namespace <environment>
```

And change current context to respective environment:
``` bash
kubectl config set-context --current --namespace=<environment>
``` 

You need to run commands with namespace flag accordingly e.g.:
``` bash
kubectl apply -f ./postgres.yaml -n <environment>
``` 

### Setup

1. [Download](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download) minikube and start cluster:
``` bash
minikube start \
    --cpus=2 --memory=3920m \
    --container-runtime=cri-o \
    --driver=docker \
    --addons=ingress
```

2. Watch pods, services & ingress (run in seprate terminals).
``` bash
watch --exec kubectl get pods --output wide
watch --exec kubectl get services --output wide
watch --exec kubectl get ingress --output wide
```

3. Apply Configurations and Secrets:
``` bash
kubectl apply -f ./<environment>/backend/postgres-config.yaml
# After creating yaml-file with your credentials
kubectl apply -f ./<environment>/backend/postgres-secret.yaml
# To be able to use secrets from .env you need to create them
kubectl create secret generic be-java-game-price-comparator-<environment>-secret --from-env-file=.env
```

4. Start Postgres and Backend:

``` bash
kubectl apply -f ./<environment>/backend/postgres.yaml
kubectl apply -f ./<environment>/backend/backend.yaml
kubectl apply -f ./<environment>/backend/ingress.yaml
# Or for whole directory
kubectl apply -f ./<environment>/backend
```

5. Start all or specific K8-ressources for Frontend:
``` bash
# Whole directory
kubectl apply -f ./<environment>/frontend

# Specific file
kubectl apply -f ./<environment>/frontend/<K8-ressource>
```

If there are problems, try:
``` bash
# checking pods if they haven't been created
kubectl describe pod

# or if they are created and have an error in the status
kubectl logs <pod-name>
```

6. To enable image-checking (CronJob) for Frontend and/or Backend:

``` bash
kubectl apply -f ./<environment>/[backend,frontend]/image-check.yaml
```

#### Problems with Minikube on Unix-OS

7. As per the [K8 doc](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress), we are using Docker on a Unix-OS (Darwin), thus we need to create a tunnel to our cluster to make it accessible from outside.
``` bash
minikube tunnel
```

8. Test from terminal if html is returned
``` bash
# Should return HTML of Angular app
curl --resolve "fe-angular-game-price-comparator-develop.nip.io:80:127.0.0.1" -i http://fe-angular-game-price-comparator-develop.nip.io
```

Optionally you add the Frontend ingress host to `/etc/hosts` and checkout the browser:
```
127.0.0.1 fe-angular-game-price-comparator.<environment>.nip.io
```

9. Test if Backend service is reachable:
``` bash
# Get exposed service url of cluster
minikube service be-java-game-price-comparator-<environment>-service --url

# send backend api call - should return Ok as a string
curl <service-url>/api/v1/health
```

### Stop

Stop/Delete cluster:
``` bash
minikube stop
minikube delete
```


Delete ressources:
``` bash
kubectl delete all --all
# Or
kubectl delete --all ingresses
kubectl delete --all services
kubectl delete --all deployments
kubectl delete --all secrets
kubectl delete --all configmaps

# Specific ressources
kubectl delete [configmap,ingress,service,pod] <name>
```

## Local Setup with Terraform and Minikube

Start minikube:
``` bash
minikube start \
    --cpus=2 --memory=3920m \
    --container-runtime=cri-o \
    --driver=docker \
    --addons=ingress
```

Spin up terraform:
``` bash
terraform init
terraform apply
```

Delete ressources:
``` bash
terraform destroy
```

### Problems with Minikube on Unix-OS (again)

As we are using a local cluster again and described in the 7. step of [Setup](#setup), when using Docker on Darwin, the URLs of the ingresses cannot be accessed from outside the cluster.

To access the Frontend URL locally in the browser, run:
```bash
minikube tunnel
```

And add the Frontend URL to `/etc/hosts`:
```
127.0.0.1 fe-angular-game-price-comparator.<environment>.nip.io
```

The Frontend application is then accessible at `fe-angular-game-price-comparator.<environment>.nip.io`.

To be CORS compliant with the Backend, we need to get the URL of the exposed Backend ingress and add it as an environment variable to our Frontend .tf-file:
```bash
# Get exposed service url of cluster
minikube service be-java-game-price-comparator-<environment>-service --url
```

Add in `frontend-deployment.tf` file:
```
env {
    name  = "API_BASE_URL"
    value = "<service-url>/api"
}
```

Reapply change:
```bash
terraform apply
```

### Problems with AWS Cloud

Virtual machine with more than 2Gi CPU is required to be able to use Kubernetes on the aws.

Firstly, we've tried to install kubernetes on the aws instance manually using minikube and kubelet+kubeadm, but received following errors:
```log
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
I0825 11:29:59.416029   12189 version.go:256] remote version is much newer: v1.31.0; falling back to: stable-1.30
[init] Using Kubernetes version: v1.30.4
[preflight] Running pre-flight checks
W0825 11:29:59.527174   12189 checks.go:1079] [preflight] WARNING: Couldn't create the interface used for talking to the container runtime: crictl is required by the container runtime: executable file not found in $PATH
	[WARNING FileExisting-socat]: socat not found in system path
	[WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR NumCPU]: the number of available CPUs 1 is less than the required 2
	[ERROR Mem]: the system RAM (446 MB) is less than the minimum 1700 MB
	[ERROR FileExisting-crictl]: crictl not found in system path
	[ERROR FileExisting-conntrack]: conntrack not found in system path
[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
To see the stack trace of this error execute with --v=5 or higher
```

```log
sudo minikube start --driver=none
😄  minikube v1.33.1 on Ubuntu 22.04 (xen/amd64)
✨  Using the none driver based on user configuration

⛔  Exiting due to RSRC_INSUFFICIENT_CORES: None has less than 2 CPUs available, but Kubernetes requires at least 2 to be available
```

To achieve the goal of deploying services on the aws_instance with Terraform, we needed a more efficient machine. Therefore, we've decided to deploy everything locally with all problems with Minikube on Unix-OS.


### Remote Setup with Terraform, Ansible and Kubeadm

Make sure you have a ssh key-pair named `operator` in `/terraform/.ssh`.

Run script:
```bash
./terraform/develop/provision.sh
```

Or step by step.

Infrastructure setup:
```bash
terraform init
terraform apply # optionally run with --auto-approve
```

Check if you can connect to the control plane:
```bash
ssh -i ../.ssh/operator -l ubuntu $(terraform output -raw 'control_plane_ipv4')
```

Make sure you have terraform installed as this setup uses a plugin to [provide ansible for terraform](https://www.ansible.com/blog/providing-terraform-with-that-ansible-magic/). The plugin can be used in the inventory.yaml but needs to be installed from [this site](https://galaxy.ansible.com/ui/repo/published/cloud/terraform/) and shows following command to run:
```bash
ansible-galaxy collection install cloud.terraform
```

It enables the hosts file (that is saved in the terraform state) to be accessible for ansible in order to create a dynamic hosts file. To check if it worked run:
```bash
ansible-inventory -i inventory.yaml --graph

# Expected output something like:
@all:
  |--@ungrouped:
  |--@master:
  |  |--control_plane
  |--@workers:
  |  |--worker-0
  |  |--worker-1
```

To run the playbook:
```bash
ansible-playbook -i inventory.yaml playbook.yaml --ask-become-pass
```

The flag `--ask-become-pass` asks for your sudo password that is used on your local machine so it can create and execute commands on the remote host machines.

Check kube config file and look for server property e.g. `server: https://[master-ip]` and check if it matches the master-ip (check master-ip in files/hosts). Then set that config as default by exporting the path to the file as the KUBECONFIG-Variable
```bash
# Print
cat /tmp/kubeconfig/config

# Overwrites kubeconfig on your machine with remote config that has been saved on your machine after running the playbook (only temporarily - resets as soon as you destroy everything)
export KUBECONFIG=/tmp/kubeconfig/config

# Check applied config
kubectl config view

# Check if you have access to the remote cluster that you created
kubectl get pods --all-namespaces
# Or 
kubectl get all --all-namespaces

# get all machines
kubectl get nodes

kubectl cluster-info

```
