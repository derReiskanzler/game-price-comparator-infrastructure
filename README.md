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

### Remote Setup with Terraform, Ansible and Kubeadm

We followed [this tutorial](https://www.youtube.com/watch?v=Cr6oLkCAwiA) to set up an unmanaged K8-Cluster.

![](./docs//assets/infrastructure.png)
<strong>Fig. 1: Architecture diagramm</strong>


#### Prerequisites

Make sure you:
- [install](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) Ansible
- a ssh key-pair named `operator` in `/terraform/<environment>/.ssh`

#### Setup

Run script to set it up in one go or do it step by step by following the same steps in the script:
```bash
./terraform/<environment>/provision.sh
```

Check if you can connect to the control plane:
```bash
ssh -i .ssh/operator -l ubuntu $(terraform output -raw 'control_plane_ipv4')
```

