# Kubernetes (K8s)

> Docker runs containers on **one** machine. Kubernetes runs containers across **many** machines and keeps them in the state you declared: right number of copies, restarted if they crash, rolled out gradually, reachable through stable names.

**Learn Docker first.** Kubernetes builds on it.

## The core idea: desired state

You write YAML saying **what you want** ("3 replicas of `example-app:1.0`"). Kubernetes **controllers** constantly compare reality to that and fix the difference. A pod dies → a new one is created. That loop is called **reconciliation**.

## Architecture

```
┌─────────────────────── Control plane ───────────────────────┐
│  kube-apiserver   ← everything (kubectl, controllers) talks │
│                     to the API server                       │
│  etcd             ← key-value store holding cluster state   │
│  kube-scheduler   ← decides which node runs each new pod    │
│  controller-manager ← reconciliation loops (Deployments…)   │
└─────────────────────────────────────────────────────────────┘
          │                    │                    │
┌──── Node 1 ────┐   ┌──── Node 2 ────┐   ┌──── Node 3 ────┐
│ kubelet        │   │ kubelet        │   │ kubelet        │  ← runs the pods on the node
│ kube-proxy     │   │ kube-proxy     │   │ kube-proxy     │  ← Service networking
│ containerd     │   │ containerd     │   │ containerd     │  ← container runtime
│ [pod] [pod]    │   │ [pod] [pod]    │   │ [pod]          │
└────────────────┘   └────────────────┘   └────────────────┘
```
On managed services (EKS, AKS, GKE) the cloud provider runs the control plane for you.

## Core objects

| Object | Purpose |
|---|---|
| **Pod** | Smallest unit: one (or a few tightly coupled) containers sharing an IP. Disposable |
| **Deployment** | Manages identical pods: replica count, rolling updates, rollbacks |
| **ReplicaSet** | Created by a Deployment to keep N pods running (you rarely touch it) |
| **Service** | A stable virtual IP + DNS name that load-balances across matching pods |
| **Ingress** / **Gateway API** | HTTP routing from outside the cluster (hosts, paths, TLS) |
| **ConfigMap** | Non-secret configuration (env vars, files) |
| **Secret** | Sensitive config. ⚠️ Only base64-*encoded* by default; enable encryption at rest / use an external secrets manager |
| **Namespace** | A virtual cluster for separating teams/environments |
| **StatefulSet** | Pods with stable identities and storage (databases) |
| **DaemonSet** | One pod on every node (log collectors, monitoring agents) |
| **Job / CronJob** | Run-to-completion tasks / scheduled tasks |
| **PersistentVolumeClaim** | A request for storage |
| **HorizontalPodAutoscaler** | Scale replicas on CPU/memory/custom metrics |

### Service types
| Type | Reachable from | Use |
|---|---|---|
| `ClusterIP` (default) | Inside the cluster only | Internal services (API → DB) |
| `NodePort` | Each node's IP on a high port (30000–32767) | Local testing |
| `LoadBalancer` | A cloud load balancer | Exposing a service publicly on EKS/AKS/GKE |

## kubectl essentials

```bash
kubectl get nodes
kubectl get pods -A                         # all namespaces
kubectl get pods -n demo -o wide            # with node and IP
kubectl get deploy,svc,pods -n demo         # several kinds at once
kubectl describe pod <pod> -n demo          # details + EVENTS (read these when debugging!)
kubectl logs <pod> -n demo -f               # follow logs
kubectl logs <pod> -n demo --previous       # logs from the crashed previous container
kubectl exec -it <pod> -n demo -- sh        # shell inside the pod
kubectl apply -f manifests/                 # create/update from YAML (declarative)
kubectl delete -f manifests/
kubectl port-forward svc/example-app 8080:80 -n demo   # reach a service from your laptop
kubectl rollout status deploy/example-app -n demo
kubectl rollout undo deploy/example-app -n demo        # roll back!
kubectl scale deploy/example-app --replicas=5 -n demo
kubectl explain deployment.spec.strategy    # built-in docs for any field
```
💡 Add `alias k=kubectl` to your `~/.zshrc`.

## 🧪 Hands-on: deploy the example app locally

Requires Docker and a local cluster. **kind** (Kubernetes in Docker) is the simplest:

```bash
brew install kind kubectl
kind create cluster --name lab

# Build the image and load it into the kind cluster (no registry needed)
docker build -t example-app:1.0 ../docker/example-app
kind load docker-image example-app:1.0 --name lab

kubectl apply -f manifests/
kubectl get pods -n demo -w                 # watch until Running (Ctrl+C)
kubectl port-forward svc/example-app 8080:80 -n demo
# in another terminal:
for i in 1 2 3 4 5; do curl -s localhost:8080; echo; done   # hostname = pod name

kind delete cluster --name lab              # clean up
```

The manifests in [`manifests/`](manifests/) are numbered because `kubectl apply -f <folder>` applies files in alphabetical order, and the namespace must exist first:
| File | Creates |
|---|---|
| [`00-namespace.yaml`](manifests/00-namespace.yaml) | The `demo` namespace |
| [`01-configmap.yaml`](manifests/01-configmap.yaml) | `GREETING` and `APP_VERSION` settings |
| [`02-deployment.yaml`](manifests/02-deployment.yaml) | 3 replicas with probes, resource limits, security context, rolling updates |
| [`03-service.yaml`](manifests/03-service.yaml) | A ClusterIP Service on port 80 → container port 8080 |

**Challenges**
1. Delete a pod (`kubectl delete pod <name> -n demo`) and watch Kubernetes replace it.
2. Change `GREETING` in the ConfigMap, apply, then `kubectl rollout restart deploy/example-app -n demo`.
3. Set the image to `example-app:2.0` (which doesn't exist). What status do the new pods show? Roll back with `rollout undo`.
4. Lower the memory limit to `10Mi`. What happens? (Look for `OOMKilled` in `describe`.)
5. Add a HorizontalPodAutoscaler (needs metrics-server).

## Troubleshooting pods

| Status | Meaning | Debug with |
|---|---|---|
| `Pending` | Can't be scheduled: not enough CPU/memory, no matching node, PVC not bound | `kubectl describe pod` → Events |
| `ImagePullBackOff` / `ErrImagePull` | Wrong image name/tag, private registry without credentials | `describe pod`; check the image exists |
| `CrashLoopBackOff` | Container starts, crashes, restarts with growing delays | `kubectl logs <pod> --previous` |
| `OOMKilled` | Exceeded its memory limit | `describe pod` → Last State; raise the limit or fix the leak |
| `Running` but not `Ready` | Readiness probe failing: no traffic is sent to it | `describe pod`; check the probe path/port |
| Service returns nothing | Service selector doesn't match pod labels | `kubectl get endpoints <svc> -n demo` (empty = mismatch) |

**Debug order:** `get pods` → `describe pod` (events!) → `logs` / `logs --previous` → `get endpoints` → `exec` inside / debug pod.

## Beyond the basics (later)
- **Helm:** package manager / templating for K8s YAML
- **Kustomize:** overlays per environment (`kubectl apply -k`)
- **GitOps:** Argo CD or Flux sync the cluster from a Git repo
- **Ingress controllers:** ingress-nginx, AWS Load Balancer Controller
- **Observability:** Prometheus, Grafana, Loki ([monitoring](../monitoring/))

## 🎓 Certifications
**CKAD** (developer), **CKA** (administrator), **CKS** (security). Hands-on, terminal-based exams.

## 📚 Learn more
- Official docs and tutorials: https://kubernetes.io/docs/tutorials/
- kind: https://kind.sigs.k8s.io/
