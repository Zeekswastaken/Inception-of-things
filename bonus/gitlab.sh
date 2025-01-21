#helm installation
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

BLUE='\033[0;34m'
NC='\033[0m'
info() { echo -e "${BLUE}[INFO] $1${NC}"; }

info "Exporting k3d config cluster to kubectl config"
export KUBECONFIG=$(k3d kubeconfig write bonus-cluster)

info "creating gitlab name spcace"
kubectl create namespace gitlab

#downloading and installing gitlab to thiss cluster

helm uninstall gitlab -n gitlab 2>/dev/null || true
kubectl delete pvc --all -n gitlab 2>/dev/null || true

helm repo add gitlab https://charts.gitlab.io/
helm repo update

info "Installing gitlab ..."
helm upgrade --install gitlab gitlab/gitlab \
  --namespace gitlab \
  --timeout 600s \
  --values gitlab-values.yaml \

info "Waiting for services to be ready..."
kubectl wait --namespace gitlab --for=condition=ready pod -l app=webservice --timeout=600s || true

kubectl patch svc gitlab-webservice-default -n gitlab -p '{"spec": {"type": "LoadBalancer"}}'

kubectl port-forward services/gitlab-webservice-default 8080:8181 -n gitlab

info "Gitlab root password: "
GITLAB_PASSWORD=$(kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -ojsonpath='{.data.password}' | base64 --decode)

