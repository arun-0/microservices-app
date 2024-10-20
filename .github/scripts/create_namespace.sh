#!/bin/bash

NAMESPACE="microservices"

if kubectl get ns $NAMESPACE > /dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' already exists. Skipping creation."
else
    echo "Creating namespace '$NAMESPACE'."
    kubectl create ns $NAMESPACE
fi
