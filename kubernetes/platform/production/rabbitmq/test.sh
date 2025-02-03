#!/bin/sh

export RABBITMQ_USERNAME=$(kubectl get secret rentsphere-rabbitmq-default-user -o jsonpath='{.data.username}' --namespace=rabbitmq-system | base64 --decode)
export RABBITMQ_PASSWORD=$(kubectl get secret rentsphere-rabbitmq-default-user -o jsonpath='{.data.password}' --namespace=rabbitmq-system | base64 --decode)
export RABBITMQ_SERVICE=$(kubectl get service rentsphere-rabbitmq -o jsonpath='{.spec.clusterIP}' --namespace=rabbitmq-system)

kubectl run perf-test --image=pivotalrabbitmq/perf-test --namespace=rabbitmq-system -- --uri amqp://$RABBITMQ_USERNAME:$RABBITMQ_PASSWORD@$RABBITMQ_SERVICE

unset RABBITMQ_USERNAME
unset RABBITMQ_PASSWORD
unset RABBITMQ_SERVICE