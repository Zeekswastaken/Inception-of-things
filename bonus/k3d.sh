#installing k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

k3d cluster create bonus-cluster --api-port 8765 -p 8081:80@loadbalancer  -p 8888:8888@loadbalancer --agents 2 --wait

#creating a namespace for agrocd

export KUBECONFIG=$(k3d kubeconfig write bonus-cluster)

kubectl config current-context

kubectl create namespace argocd

#this dev namesapace where i will deploy my app using argocd
kubectl create namespace dev


#install argocd in k3d cluster
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl wait --for=condition=Ready pods --all -n argocd
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$12$xyk8mlgC6l6gWQhTA.LF8uqlX5ng6Ju5BU7zhJ4Sp4VuCzQT7szIm",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

echo "kubectl apply -f ./argo-application.yaml -n argocd"
kubectl apply -f ./argo-application.yaml -n argocd
echo "kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'"
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
echo "kubectl get pods -n argocd"
kubectl get pods -n argocd
kubectl wait --for=condition=Ready pods --all -n argocd

echo "Username: admin"
echo "forwarding to argocd"
kubectl port-forward svc/argocd-server -n argocd 8082:443 2>&1 >/dev/null &

# kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d