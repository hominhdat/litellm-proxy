#!/bin/bash
# This script installs Redis for Kubernetes

helm upgrade --install -n redis litellm-proxy-redis bitnami/redis --create-namespace \
  --set architecture=standalone \
  --set auth.enabled=false \
  --set master.persistence.enabled=false