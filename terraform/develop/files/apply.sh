#!/bin/sh
# echo "Apply ingress controller resources..."
# kubectl apply -f ./deployment/ingress-controller.yaml

echo "Apply k8 backend resources..."
kubectl apply -f ./deployment/backend/postgres-config.yaml
kubectl apply -f ./deployment/backend/postgres-secret.yaml
kubectl create secret generic be-java-game-price-comparator-develop-secret --from-env-file=./deployment/backend/.env
kubectl apply -f ./deployment/backend/postgres.yaml
kubectl apply -f ./deployment/backend/backend.yaml
kubectl apply -f ./deployment/backend/ingress.yaml
kubectl apply -f ./deployment/backend/image-checker.yaml

echo "Apply k8 frontend resources..."
kubectl apply -f ./deployment/frontend

echo "✅ Done"