#!/bin/bash

if command -v argocd > /dev/null 2>&1; then
    echo "Argo CD CLI is already installed."
else
    echo "Installing Argo CD CLI."
    curl -sSL https://raw.githubusercontent.com/argoproj/argo-cd/stable/install.sh | bash
fi
