#!/bin/sh

printf "Apply k8 backend resources..."
kubectl apply -f ./backend/postgres-config.yaml
kubectl apply -f ./backend/postgres-secret.yaml
kubectl create secret generic be-java-game-price-comparator-develop-secret --from-env-file=./backend/.env
kubectl apply -f ./backend/postgres.yaml
kubectl apply -f ./backend/backend.yaml
kubectl apply -f ./backend/ingress.yaml
kubectl apply -f ./backend/image-checker.yaml

printf "Apply k8 frontend resources..."
kubectl apply -f ./frontend

printf "✅ Done"