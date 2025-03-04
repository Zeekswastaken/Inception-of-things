#!/bin/bash
# kubelet requires swap off
swapoff -a
# keep swap off after reboot
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
curl -sfL https://get.k3s.io | sh -s -- --write-kubeconfig-mode=644

sleep 20

kubectl apply -f /vagrant/app-one.yaml
kubectl apply -f /vagrant/app-two.yaml
kubectl apply -f /vagrant/app-three.yaml
kubectl apply -f /vagrant/apps-ingress.yaml

sleep 20

kubectl get all

