#!/bin/bash

CRD_NAME="mycrd.example.com"  # Change this to your CRD name

if kubectl get crd $CRD_NAME > /dev/null 2>&1; then
    echo "CRD '$CRD_NAME' already exists."
    exit 0
else
    echo "CRD '$CRD_NAME' does not exist."
    exit 1
fi
