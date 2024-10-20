#!/bin/bash

if kubectl get ns argocd > /dev/null 2>&1; then
    echo "Argo CD is already installed."
    exit 0
else
    echo "Argo CD is not installed."
    exit 1
fi
