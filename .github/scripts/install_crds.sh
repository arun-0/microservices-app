#!/bin/bash

CRD_FILE="path/to/your/crd-definition.yaml"  # Update with the path to your CRD definition file

if kubectl get crd mycrd.example.com > /dev/null 2>&1; then
    echo "CRD 'mycrd.example.com' already exists. Skipping installation."
else
    echo "Installing CRDs."
    kubectl apply -f $CRD_FILE
fi
