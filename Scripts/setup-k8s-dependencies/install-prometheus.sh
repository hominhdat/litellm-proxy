#!/bin/bash
# This script installs Prometheus for monitoring Kubernetes clusters

LATEST=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
curl -sL https://github.com/prometheus-operator/prometheus-operator/releases/download/${LATEST}/bundle.yaml | kubectl create -f -

helm upgrade --install litellm-proxy-prometheus bitnami/kube-prometheus -f prometheus-values.yaml \
-n monitoring --create-namespace