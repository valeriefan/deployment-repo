#!/bin/sh

set -euo pipefail

echo "\n🗝️  Keycloak deployment started.\n"

echo "📦 Installing Keycloak..."

clientSecret=$(echo $ random | openssl md5 | head -c 20)

kubectl apply -f resources/namespace.yml
sed "s/rentsphere-keycloak-secret/$clientSecret/" resources/keycloak-config.yml | kubectl apply -f -

echo "\n📦 Configuring Helm chart..."

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install rentsphere-keycloak bitnami/keycloak \
  --values values.yml \
  --namespace keycloak-system

echo "\n⌛ Waiting for Keycloak to be deployed..."

sleep 15

while [ $(kubectl get pod -l app.kubernetes.io/component=keycloak -n keycloak-system | wc -l) -eq 0 ] ; do
  sleep 15
done

echo "\n⌛ Waiting for Keycloak to be ready..."

kubectl wait \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=keycloak \
  --timeout=600s \
  --namespace=keycloak-system

echo "\n✅  Keycloak cluster has been successfully deployed."

echo "\n🔐 Your Keycloak Admin credentials...\n"

echo "Admin Username: user"
echo "Admin Password: $(kubectl get secret --namespace keycloak-system rentsphere-keycloak -o jsonpath="{.data.admin-password}" | base64 --decode)"

echo "\n🔑 Generating Secret with Keycloak client secret."

kubectl delete secret rentsphere-keycloak-client-credentials || true

kubectl create secret generic rentsphere-keycloak-client-credentials \
    --from-literal=spring.security.oauth2.client.registration.keycloak.client-secret="$clientSecret"

echo "\n🍃 A 'rentsphere-keycloak-client-credentials' has been created for Spring Boot applications to interact with Keycloak."

echo "\n🗝️  Keycloak deployment completed.\n"
