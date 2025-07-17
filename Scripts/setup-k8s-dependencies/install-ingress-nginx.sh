#!/bin/bash
# This script installs the Ingress NGINX controller for Kubernetes

kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.1.0/deploy/crds.yaml

helm upgrade --install litellm-proxy-ingress-nginx ingress-nginx \
--repo https://kubernetes.github.io/ingress-nginx \
--namespace ingress-nginx \
--set controller.replicaCount=1 \
--set controller.autoscaling.enabled=true \
--set controller.autoscaling.minReplicas=1 \
--set controller.metrics.enabled=true \
--set controller.publishService.enabled=true \
--set controller.service.externalTrafficPolicy=Cluster \
--set controller.metrics.serviceMonitor.enabled=true \
--create-namespace

