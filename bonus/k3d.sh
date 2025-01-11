#installing k3d
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

#creating a namespace for agrocd
sudo kubectl create namespace argocd

#this dev namesapace where i will deploy my app using argocd
sudo kubectl create namespace dev

#install argocd in k3d cluster
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "checking agrocd status"
sudo kubectl get pods -n argocd

echo "Username: amdin"
echo "Password: yU1QJ6s4MUYYfaID"
echo "Expose the ArgoCD API server locally, then try to accessing the dashboard"
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443

sudo kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d

