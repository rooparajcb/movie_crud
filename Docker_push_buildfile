#!/bin/bash

set -e

IMAGE_NAME="sakit333/spring-kube-sakgroup"
DOCKER_USER="sakit333"

echo "🔍 Checking Docker..."

if ! command -v docker >/dev/null 2>&1; then
    echo "🐳 Docker not found. Installing using apt..."
    sudo apt update
    sudo apt install docker.io -y
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "✅ Docker already installed"
fi

# Optional but useful (avoid sudo for docker)
if ! groups $USER | grep -q docker; then
    sudo usermod -aG docker $USER
    echo "ℹ️ Added user to docker group. Log out & back in if needed."
fi

echo "🏗️ Building Docker image..."
docker build -t $IMAGE_NAME .

echo "🔐 Docker login (password will be prompted)"
docker login -u $DOCKER_USER

echo "📤 Pushing image to Docker Hub..."
docker push $IMAGE_NAME

echo "🧹 Removing local image..."
docker rmi $IMAGE_NAME

echo "✅ All done!"
