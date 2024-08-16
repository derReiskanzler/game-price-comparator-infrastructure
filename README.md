# Game Price Comparator Infrastructure

## Local with minikube

### Frontend

1. Start a minikube.

```bash
minikube start \
    --cpus=2 --memory=4096m \
    --container-runtime=cri-o \
    --driver=docker \
    --addons=ingress
```

2. Watch pods, services & ingress (run in seprate terminals).
```bash
watch --exec kubectl get pods --output wide
watch --exec kubectl get services --output wide
watch --exec kubectl get ingress --output wide
```

3. Apply deployment, ingress & load balancer.
```bash
# Deploy all files in directory
kubectl apply -f ./[develop,staging,production]/[frontend,backend]

# Deploy specific file
kubectl apply -f ./[develop,staging,production]/[frontend,backend]/<K8-ressource>
```

If there are problems, try:
```bash
# checking pods if they haven't been created
kubectl describe pod

# or if they are created and have an error in the status
kubectl logs <pod-name>
```

4. As per the [K8 doc](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress), we are using Docker on a Unix-OS (Darwin), thus we need to create a tunnel to our cluster to make it accessible from outside.
```bash
minikube tunnel
```

5. Test from terminal if html is returned
```bash
curl --resolve "fe-angular-game-price-comparator-develop.nip.io:80:127.0.0.1" -i http://fe-angular-game-price-comparator-develop.nip.io
```
