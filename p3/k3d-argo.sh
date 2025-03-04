# #!/bin/bash
# sudo k3d cluster create test
# sudo kubectl create namespace argocd
# sudo kubectl create namespace dev
# sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# sudo kubectl port-forward svc/argocd-server -n argocd 8080:443
# sudo kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
#!/bin/bash

sudo k3d cluster create zouazahr-cluster --api-port 6443 -p 8080:80@loadbalancer  -p 8888:8888@loadbalancer --agents 2 --wait

sudo kubectl create namespace argocd
sudo kubectl create namespace dev

sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# This command will complete quickly, but pods will still be spinning up on the back end.
# These need to be in a running state before you can move forward. Use the watch command
# to ensure the pods are running and ready.
# watch kubectl get pods -n argocd

sudo kubectl wait --for=condition=Ready pods --all -n argocd

# By default ArgoCD uses the server pod name as the default password for the admin user,
# To get server pod name => kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
# so we're gonna replace it with 123 (we used https://bcrypt-generator.com/
# to generate the blowfish hash version of "123" below)

sudo kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$12$xyk8mlgC6l6gWQhTA.LF8uqlX5ng6Ju5BU7zhJ4Sp4VuCzQT7szIm",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

sudo kubectl apply -f ./argo-application.yaml -n argocd
sudo kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

sudo kubectl wait --for=condition=Ready pods --all -n argocd
# sudo kubectl port-forward svc/argocd-server -n argocd 8080:80 2>&1 >/dev/null &
# sudo kubectl port-forward svc/wil-playground-service -n dev 8888:8888 2>&1 >/dev/null &

