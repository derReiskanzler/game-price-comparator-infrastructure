#!/bin/sh
# echo "🔄 Apply tls resources..."
# kubectl apply -f ./deployment/cluster-issuer.yaml

# Backend
kubectl apply -f ./deployment/backend/postgres-config.yaml
kubectl apply -f ./deployment/backend/postgres-secret.yaml
kubectl create secret generic be-java-game-price-comparator-develop-secret --from-env-file=./deployment/backend/.env
kubectl apply -f ./deployment/backend/postgres.yaml
kubectl apply -f ./deployment/backend/load-balancer.yaml
kubectl apply -f ./deployment/backend/image-checker.yaml

# Frontend
kubectl apply -f ./deployment/frontend/load-balancer.yaml
kubectl apply -f ./deployment/frontend/image-checker.yaml

echo "✅ Done\n"