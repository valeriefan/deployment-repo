#!/bin/sh

echo "\n🏴️ Destroying Kubernetes cluster...\n"

minikube stop --profile rentsphere

minikube delete --profile rentsphere

echo "\n🏴️ Cluster destroyed\n"
