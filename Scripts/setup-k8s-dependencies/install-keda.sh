#!/bin/bash
# This script installs KEDA for Kubernetes event-driven autoscaling

helm install keda kedacore/keda --namespace keda --create-namespace