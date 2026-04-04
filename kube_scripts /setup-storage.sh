#!/bin/bash

set -e

echo "🔹 Installing local-path-provisioner..."
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

echo "🔹 Waiting for local-path-provisioner pod to be ready..."
kubectl wait --namespace local-path-storage \
  --for=condition=Ready pod \
  --selector=app=local-path-provisioner \
  --timeout=180s

echo "🔹 Setting local-path as default StorageClass..."
kubectl patch storageclass local-path \
  -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "🔹 Verifying StorageClass..."
kubectl get storageclass

echo "✅ Storage setup completed successfully"
