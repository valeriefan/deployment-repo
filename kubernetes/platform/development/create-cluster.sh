#!/bin/sh

echo "\n📦 Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --disk-size=50g --driver docker --profile rentsphere

echo "\n🔌 Enabling NGINX Ingress Controller...\n"

minikube addons enable ingress --profile rentsphere

sleep 15

echo "\n📦 Deploying Keycloak..."

kubectl apply -f services/keycloak-config.yml
kubectl apply -f services/keycloak.yml

sleep 5

echo "\n⌛ Waiting for Keycloak to be deployed..."

while [ $(kubectl get pod -l app=rentsphere-keycloak | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=rentsphere-keycloak \
  --timeout=300s

echo "\n⌛ Ensuring Keycloak Ingress is created..."

kubectl apply -f services/keycloak.yml

echo "\n📦 Deploying PostgreSQL..."

kubectl apply -f services/postgresql.yml

sleep 5

echo "\n⌛ Waiting for PostgreSQL to be deployed..."

while [ $(kubectl get pod -l db=rentsphere-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for PostgreSQL to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=rentsphere-postgres \
  --timeout=180s

echo "\n📦 Deploying Redis..."

kubectl apply -f services/redis.yml

sleep 5

echo "\n⌛ Waiting for Redis to be deployed..."

while [ $(kubectl get pod -l db=rentsphere-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Redis to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=rentsphere-redis \
  --timeout=180s

echo "\n📦 Deploying RabbitMQ..."

kubectl apply -f services/rabbitmq.yml

sleep 5

echo "\n⌛ Waiting for RabbitMQ to be deployed..."

while [ $(kubectl get pod -l db=rentsphere-rabbitmq | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for RabbitMQ to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=db=rentsphere-rabbitmq \
  --timeout=180s

echo "\n📦 Deploying RentSphere UI..."

kubectl apply -f services/ui.yml

sleep 5

echo "\n⌛ Waiting for RentSphere UI to be deployed..."

while [ $(kubectl get pod -l app=rentsphere-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for RentSphere UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=rentsphere-ui \
  --timeout=180s

echo "\n⛵ Happy Sailing!\n"
