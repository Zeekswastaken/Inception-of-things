#!/bin/bash
sudo k3d cluster create test
sudo kubectl create namespace argocd
sudo kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sudo kubectl port-forward svc/argocd-server -n argocd 8080:443

