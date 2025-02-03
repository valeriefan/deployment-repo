#!/bin/sh

set -euo pipefail

echo "\n📦 Deploying RentSphere UI..."

kubectl apply -f resources

echo "⌛ Waiting for RentSphere UI to be deployed..."

while [ $(kubectl get pod -l app=rentsphere-ui | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for RentSphere UI to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app=rentsphere-ui \
  --timeout=180s

echo "\n📦 RentSphere UI deployment completed.\n"