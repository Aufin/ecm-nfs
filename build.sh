#!/bin/bash

# Build script for NFS Server image - Public DockerHub
set -e

# Configuration
DOCKERHUB_USER="trejo08"
IMAGE_NAME="nfs-server"
IMAGE_TAG="v1.1.0"
FULL_IMAGE_NAME="$DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG"

echo "🐳 Building NFS Server Docker image for DockerHub..."
echo "📦 Image: $FULL_IMAGE_NAME"

# Build the image for Linux/amd64 platform (compatible with most Kubernetes clusters)
# Using optimized cache from registry for faster builds
docker buildx build \
  --platform linux/amd64 \
  --cache-from type=registry,ref="$DOCKERHUB_USER/$IMAGE_NAME:latest" \
  --cache-to type=inline \
  -t "$FULL_IMAGE_NAME" \
  -t "$DOCKERHUB_USER/$IMAGE_NAME:latest" \
  . --push

echo "✅ Build and push completed!"
echo ""
echo "📝 Next steps:"
echo "1. ✅ Image automatically pushed to DockerHub with optimized cache"
echo "2. Update k8s/common/nfs-server.yaml to use:"
echo "   image: $FULL_IMAGE_NAME"
echo ""
echo "3. Test locally (optional - pull from registry):"
echo "   docker pull $FULL_IMAGE_NAME"
echo "   docker run --privileged -p 2049:2049 -p 111:111 $FULL_IMAGE_NAME"
echo ""
echo "💡 Configuration options:"
echo "   Environment variable NFS_EXPORT_DIR (default: /exports/data)"
echo "   Example: docker run --privileged -e NFS_EXPORT_DIR=/exports/shared -p 2049:2049 -p 111:111 $FULL_IMAGE_NAME"
echo ""
echo "🏗️  Architecture: linux/amd64 (Kubernetes compatible)"
echo ""
echo "⚡ Build optimizations enabled:"
echo "   - Registry cache from latest tag for faster builds"
echo "   - Inline cache export for future builds"
echo "   - Single command build+push workflow"