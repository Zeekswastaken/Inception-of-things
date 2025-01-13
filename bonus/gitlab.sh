#helm installation
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

export KUBECONFIG=$(k3d kubeconfig write bonus-cluster)
kubectl create namespace gitlab
# create namespace for gitlab
kubectl config set-context --current --namespace=gitlab

#set this space to gitlab

#downloading and installing gitlab to thiss cluster
helm repo add gitlab https://charts.gitlab.io
helm search repo -l gitlab/gitlab
helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set global.hosts.domain=localhost \
  --set global.hosts.externalIP=127.0.0.1 \
  --set certmanager-issuer.email=abdelilahoman@gmail.com \
  --set postgresql.image.tag=13.6.0 \
  --set livenessProbe.initialDelaySeconds=220 \
  --set readinessProbe.initialDelaySeconds=220

kubectl port-forward services/gitlab-nginx-ingress-controller 8082:443 -n gitlab --address="0.0.0.0" 2>&1 > /var/log/gitlab-webserver.log &

echo "geting gitlab passwor"
kubectl get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

