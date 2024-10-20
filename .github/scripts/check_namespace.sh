#!/bin/bash

NAMESPACE="microservices"

if kubectl get ns $NAMESPACE > /dev/null 2>&1; then
    echo "Namespace '$NAMESPACE' already exists."
    exit 0
else
    echo "Namespace '$NAMESPACE' does not exist."
    exit 1
fi
