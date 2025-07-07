#!/bin/bash
# This script sets up the environment for the Litellm Proxy
# Author: David Ho

set -e
# Check if the required tools are installed: terraform, kubectl, and aws cli
if ! command -v terraform &> /dev/null; then
    echo "Terraform is not installed. Please install Terraform to proceed."
    exit 1
fi
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install kubectl to proceed."
    exit 1
fi
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install AWS CLI to proceed."
    exit 1
fi

# Use Personal AWS account only for this challenge
echo "Checking AWS account..."
aws_account_id=$(aws sts get-caller-identity --query "Account" --output text)
expected_account_id="129166099783"
if [ "$aws_account_id" != "$expected_account_id" ]; then
    echo "wrong AWS account. Expected account ID: $expected_account_id, but found: $aws_account_id"
    exit 1
fi

# Terraform
cd Terraform-codes
echo "Initializing Terraform..."
terraform init  || { echo "Terraform initialization failed."; exit 1; }
echo "Applying Terraform configuration..."
terraform apply -auto-approve || { echo "Terraform apply failed."; exit 1; }

# Check if the Kubernetes context is set
if ! kubectl config current-context &> /dev/null; then
    echo "Kubernetes context is not set. Please set the Kubernetes context to proceed."
    exit 1
fi
# Apply Kubernetes configurations
echo "Applying Kubernetes configurations..."
kubectl apply -f Kubernetes/configmaps.yaml || { echo "Failed to apply configmaps."; exit 1; }
kubectl apply -f Kubernetes/secrets.yaml || { echo "Failed to apply secrets."; exit 1; }
kubectl apply -f Kubernetes/deployment.yaml || { echo "Failed to apply deployment."; exit 1; }
kubectl apply -f Kubernetes/service.yaml || { echo "Failed to apply service."; exit 1; }
# Wait for the deployment to be ready
echo "Waiting for the deployment to be ready..."
kubectl rollout status deployment/litellm || { echo "Deployment rollout failed."; exit 1; }


exit 0