#helm installation
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
# create namespace for gitlab
kubectl create namespace gitlab

#set this space to gitlab
kubectl config set-context --current --namespace=gitlab

#downloading and installing gitlab to thiss cluster
helm repo add gitlab https://charts.gitlab.io
helm search repo -l gitlab/gitlab