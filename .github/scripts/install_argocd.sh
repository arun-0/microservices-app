#!/bin/bash

# Check if Argo CD is installed
if kubectl get ns argocd > /dev/null 2>&1; then
    echo "Argo CD is already installed. Skipping installation."
else
    echo "Installing Argo CD in the Kubernetes cluster."
    kubectl create namespace argocd
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Expose Argo CD API server
    kubectl expose svc argocd-server -n argocd --type=LoadBalancer --port 80 --target-port 443
fi
