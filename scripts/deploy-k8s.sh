#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

kubectl apply -f "$ROOT/k8s/namespace.yaml"
kubectl apply -f "$ROOT/k8s/configmap.yaml"
kubectl apply -f "$ROOT/k8s/secret.yaml"
kubectl apply -f "$ROOT/k8s/pvc.yaml"
kubectl apply -f "$ROOT/k8s/pod.yaml"
kubectl apply -f "$ROOT/k8s/deployment.yaml"
kubectl apply -f "$ROOT/k8s/service-clusterip.yaml"
kubectl apply -f "$ROOT/k8s/service-nodeport.yaml"
kubectl apply -f "$ROOT/k8s/deployment-with-config-storage.yaml"

kubectl get all -n tp-docker-k8s
