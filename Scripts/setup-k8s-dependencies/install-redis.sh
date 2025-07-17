#!/bin/bash
# This script installs Redis for Kubernetes

helm upgrade --install -n redis litellm-proxy-redis bitnami/redis --create-namespace \
  --set architecture=standalone \
  --set auth.enabled=true \
  --set auth.password=REdis123 \
  --set master.persistence.enabled=false