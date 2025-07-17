#!/bin/bash
# This script installs cert-manager for managing TLS certificates in Kubernetes

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.18.2/cert-manager.yaml

# Wait for cert-manager to be ready
echo "Waiting for cert-manager to be ready..."
kubectl rollout status deployment/cert-manager -n cert-manager || { echo "cert-manager deployment rollout failed."; exit 1; }

# Create a Prod ClusterIssuer for Let's Encrypt
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: hominhdat2009@gmail.com
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cluster-issuer-prod-account-key
    solvers:
    - dns01:
        cloudflare:
          email: hominhdat2009@gmail.com
          apiKeySecretRef:
            name: cloudflare-api-key-secret
            key: api-key
EOF
# Create a Staging ClusterIssuer for Let's Encrypt
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    email: hominhdat2009@gmail.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: cluster-issuer-staging-account-key
    solvers:
    - dns01:
        cloudflare:
          email: hominhdat2009@gmail.com
          apiKeySecretRef:
            name: cloudflare-api-key-secret
            key: api-key
EOF