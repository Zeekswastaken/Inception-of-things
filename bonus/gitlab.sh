#helm installation
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

export KUBECONFIG=$(k3d kubeconfig write bonus-cluster)
kubectl create namespace gitlab
# create namespace for gitlab


sudo sed -i '/gitlab.localhost/d' /etc/hosts
sudo sed -i '/minio.localhost/d' /etc/hosts
sudo sed -i '/registry.localhost/d' /etc/hosts
sudo sed -i '/kas.localhost/d' /etc/hosts
echo "127.0.0.1 gitlab.localhost minio.localhost registry.localhost kas.localhost" | sudo tee -a /etc/hosts
#set this space to gitlab

#downloading and installing gitlab to thiss cluster

helm uninstall gitlab -n gitlab 2>/dev/null || true
kubectl delete pvc --all -n gitlab 2>/dev/null || true

helm repo add gitlab https://charts.gitlab.io/
helm repo update

helm install gitlab gitlab/gitlab \
  --set global.hosts.domain=gitlab.localhost \
  --set certmanager-issuer.email=me@example.com

kubectl port-forward services/gitlab-nginx-ingress-controller 8082:443 -n gitlab --address="0.0.0.0" 2>&1 > /var/log/gitlab-webserver.log &

echo "geting gitlab passwor"
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

