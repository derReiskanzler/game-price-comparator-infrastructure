# Game Price Comparator Infrastructure

## Local with minikube

### Frontend

1. Start a minikube.

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

3. Apply deployment, ingress & load balancer.
``` bash
# Deploy all files in directory
kubectl apply -f ./[develop,staging,production]/[frontend,backend]

# Deploy specific file
kubectl apply -f ./[develop,staging,production]/[frontend,backend]/<K8-ressource>
```

If there are problems, try:
``` bash
# checking pods if they haven't been created
kubectl describe pod

# or if they are created and have an error in the status
kubectl logs <pod-name>
```

4. As per the [K8 doc](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress), we are using Docker on a Unix-OS (Darwin), thus we need to create a tunnel to our cluster to make it accessible from outside.
``` bash
minikube tunnel
```

5. Test from terminal if html is returned
``` bash
curl --resolve "fe-angular-game-price-comparator-develop.nip.io:80:127.0.0.1" -i http://fe-angular-game-price-comparator-develop.nip.io
```

### Backend

0. In folder `./[develop,staging,production]/backend` can be found next yaml-files:
   1. postgres.yaml - contains PersistentVolumeClaim, Deployment and Service for postgres. 
   2. postgres-config.yaml - contains Configuration for postgres
   3. postgres-secret.yaml.template - Secrets template for postgres. Requires updating credentials.
   4. backend.yaml - contains Deployment and Service (LoadBalancer) for backend service
   5. ingress.yaml - contains Ingress for backend service (Can be ignored as Frontend will take over this responsibility)
   6. image-checker.yaml - responsible for checking new images of the backend


1. [Download](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Farm64%2Fstable%2Fbinary+download) minikube and start using next command:
``` bash
minikube start \
    --cpus=2 --memory=3920m \
    --container-runtime=cri-o \
    --driver=docker \
    --addons=ingress
```

2. Create Namespace for the current project by using command 
``` bash
kubectl create namespace if important
```
Change current context by using next command:
``` bash
kubectl config set-context --current --namespace=<environment>
```
3. Apply Configurations and Secrets using next commands:
``` bash
kubectl apply -n <environment> --filename ./postgres-config.yaml
# After creating yaml-file with your credentials
kubectl apply -n <environment> --filename ./postgres-secret.yaml
# To be able to use secrets from .env you need to create them
kubectl create secret generic game-price-comparator-secret -n <environment> --from-env-file=.env
```

4. Start Postgres and Backend using next commands:

``` bash
kubectl apply -n <environment> --filename ./postgres.yaml
kubectl apply -n <environment> --filename ./backend.yaml
```

5. To available image-checking update 

6. To stop service and delete everything use next command:
``` bash
kubectl delete --all <environment>
# Or
kubectl delete --all ingresses -n <environment>
kubectl delete --all services -n <environment>
kubectl delete --all deployments -n <environment>
kubectl delete --all secrets -n <environment>
kubectl delete --all configmaps -n <environment>
```
