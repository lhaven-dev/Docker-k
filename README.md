# TP Docker & Kubernetes

TP Docker & Kubernetes — application Node.js, manifests Kubernetes, ConfigMap, Secret, PVC.

Rendu : https://forms.gle/XgRw3keyG6rGaRaq5

## Structure du dépôt

```
.
├── app/                          # Application + Dockerfile (Partie 1)
├── k8s/                          # Manifests YAML (Parties 2 & 3)
├── scripts/
└── docs/verifications/
```

| Fichier | Rôle |
|---------|------|
| `app/Dockerfile` | Image `hello-world-tp:1.0` |
| `k8s/pod.yaml` | Pod standalone |
| `k8s/deployment.yaml` | Deployment — **2 réplicas** |
| `k8s/deployment-3-replicas.yaml` | Deployment — **3 réplicas** (scaling manuel) |
| `k8s/service-clusterip.yaml` | Exposition interne |
| `k8s/service-nodeport.yaml` | Exposition externe (port **30080**) |
| `k8s/configmap.yaml` | Variables `APP_NAME`, `ENVIRONMENT`, `PORT` |
| `k8s/secret.yaml` | `DB_USERNAME` / `DB_PASSWORD` |
| `k8s/pvc.yaml` | Volume persistant 1 Gi |
| `k8s/deployment-with-config-storage.yaml` | ConfigMap + Secret (env) + PVC (volume) |

---

## Prérequis

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (build & run)
- Cluster Kubernetes local : **Minikube**, **Kind**, **k3s** ou **Kubernetes activé dans Docker Desktop**
- `kubectl` en ligne de commande

---

## Partie 1 — Docker (5 pts)

### Build & tag

```powershell
cd app
docker build -t hello-world-tp:1.0 .
docker images hello-world-tp:1.0
```

### Lancer le conteneur (port 3000)

```powershell
docker run -d --name hello-world-tp-run -p 3000:3000 hello-world-tp:1.0
```

### Vérifications

```powershell
curl http://localhost:3000/
curl http://localhost:3000/health
docker logs hello-world-tp-run
docker ps --filter name=hello-world-tp-run
```

Vérifications : `docs/verifications/docker-http-output.txt`, `k8s-nodeport-output.txt`, `k8s-clusterip-output.txt`, `k8s-config-storage-output.txt`, `kubectl-get-all-A.txt`
### Nettoyage Docker

```powershell
docker rm -f hello-world-tp-run
```

---

## Partie 2 — Kubernetes (9 pts)

### Préparer l'image dans le cluster

**Minikube :**

```powershell
minikube start
minikube docker-env | Invoke-Expression
docker build -t hello-world-tp:1.0 .\app
```

**Kind :**

```powershell
kind create cluster --name tp-k8s
docker build -t hello-world-tp:1.0 .\app
kind load docker-image hello-world-tp:1.0 --name tp-k8s
```

**Docker Desktop Kubernetes :** activer Kubernetes dans *Settings → Kubernetes*, puis builder l'image normalement (`imagePullPolicy: IfNotPresent` dans les manifests).

### Déploiement pas à pas

```powershell
# Namespace
kubectl apply -f k8s/namespace.yaml

# Pod standalone
kubectl apply -f k8s/pod.yaml
kubectl get pods -n tp-docker-k8s -w

# Deployment 2 réplicas
kubectl apply -f k8s/deployment.yaml
kubectl get deployments,pods -n tp-docker-k8s

# Scaling manuel → 3 réplicas (méthode 1)
kubectl scale deployment hello-world -n tp-docker-k8s --replicas=3

# Scaling manuel → 3 réplicas (méthode 2 — manifest)
kubectl apply -f k8s/deployment-3-replicas.yaml

kubectl get pods -n tp-docker-k8s -l app=hello-world

# Services
kubectl apply -f k8s/service-clusterip.yaml
kubectl apply -f k8s/service-nodeport.yaml
kubectl get svc -n tp-docker-k8s
```

### Vérifier l'accès

**ClusterIP (depuis un pod du cluster) :**

```powershell
kubectl run curl-test --rm -it --restart=Never -n tp-docker-k8s --image=curlimages/curl -- curl -s http://hello-world-clusterip/
```

**NodePort :**

```powershell
# Minikube
minikube service hello-world-nodeport -n tp-docker-k8s --url

# Kind / node local — remplacer NODE_IP
kubectl get nodes -o wide
curl http://<NODE_IP>:30080/
```

**Port-forward :**

```powershell
kubectl port-forward -n tp-docker-k8s svc/hello-world-nodeport 8080:80
curl http://localhost:8080/
```

### Commandes de contrôle

```powershell
kubectl describe deployment hello-world -n tp-docker-k8s
kubectl describe pod -n tp-docker-k8s -l app=hello-world
kubectl logs -n tp-docker-k8s -l app=hello-world --tail=20
```

Tout déployer : `.\scripts\deploy-k8s.ps1`

---

## Partie 3 — Configuration & stockage (4 pts)

```powershell
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secret.yaml
kubectl apply -f k8s/pvc.yaml
kubectl apply -f k8s/deployment-with-config-storage.yaml

kubectl get configmap,secret,pvc -n tp-docker-k8s
kubectl describe deployment hello-world-configured -n tp-docker-k8s
```

### Vérifier ConfigMap / Secret (variables d'environnement)

```powershell
$POD = kubectl get pod -n tp-docker-k8s -l app=hello-world-configured -o jsonpath='{.items[0].metadata.name}'
kubectl exec -n tp-docker-k8s $POD -- env | findstr /I "APP_NAME ENVIRONMENT DB_"
```

### Vérifier le volume persistant

```powershell
kubectl exec -n tp-docker-k8s $POD -- sh -c "echo 'donnees-tp' > /data/test.txt && cat /data/test.txt"
kubectl exec -n tp-docker-k8s $POD -- cat /etc/app-config/ENVIRONMENT
```

---

## État final du cluster

```powershell
kubectl get all -A
.\scripts\capture-kubectl-output.ps1
```

Sortie : `docs/verifications/kubectl-get-all-A.txt`

---

## Nettoyage

```powershell
kubectl delete namespace tp-docker-k8s
docker rm -f hello-world-tp-run
```
