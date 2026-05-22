$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

kubectl apply -f "$Root\k8s\namespace.yaml"
kubectl apply -f "$Root\k8s\configmap.yaml"
kubectl apply -f "$Root\k8s\secret.yaml"
kubectl apply -f "$Root\k8s\pvc.yaml"
kubectl apply -f "$Root\k8s\pod.yaml"
kubectl apply -f "$Root\k8s\deployment.yaml"
kubectl apply -f "$Root\k8s\service-clusterip.yaml"
kubectl apply -f "$Root\k8s\service-nodeport.yaml"
kubectl apply -f "$Root\k8s\deployment-with-config-storage.yaml"
kubectl get all -n tp-docker-k8s
