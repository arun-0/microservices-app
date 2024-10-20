#!/bin/bash
set -e

# Set up kubeconfig
echo "${{ secrets.KUBE_CONFIG }}" > kubeconfig.yaml
export KUBECONFIG=kubeconfig.yaml
