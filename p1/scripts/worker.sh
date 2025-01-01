#!/bin/bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="agent --server https://$2:6443 --token-file /vagrant/node-token --node-ip=$1" sh -s -