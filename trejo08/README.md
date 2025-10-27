# Optimized NFS Server - Precompiled Docker Image

High-performance NFS server Docker image optimized for Kubernetes deployments, designed to significantly reduce startup time and provide reliable shared storage for containerized applications.

## 🚀 Key Features

- **⚡ 3x Faster Startup**: Reduced from ~90s to ~30s with precompiled utilities
- **🔧 Precompiled**: All NFS utilities included in the image for instant startup
- **🌐 Cross-platform**: Built for linux/amd64 (Kubernetes compatible)
- **🛠️ Dynamic Configuration**: Runtime configuration via `NFS_EXPORT_DIR` environment variable
- **✅ Version Compatible**: Resolved "Unsupported version" errors for maximum client compatibility
- **📦 Production Ready**: Tested in production environments with high availability

## 📦 Docker Image

**Public Registry**: [DockerHub](https://hub.docker.com/r/trejo08/nfs-server)

```bash
# Current stable version
docker pull trejo08/nfs-server:v1.1.0

# Latest version
docker pull trejo08/nfs-server:latest
```

## 🔧 Configuration

### Environment Variables

| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `NFS_EXPORT_DIR` | Directory to export via NFS | `/exports/data` | `/exports/shared` |

### Exposed Ports

| Port | Protocol | Service |
|------|----------|---------|
| `2049` | TCP | NFS |
| `111` | TCP | RPC portmapper |
| `20048` | TCP | mountd |

## 🐳 Docker Usage

### Basic Usage
```bash
docker run --privileged -p 2049:2049 -p 111:111 -p 20048:20048 \
  trejo08/nfs-server:v1.1.0
```

### Custom Configuration
```bash
docker run --privileged \
  -p 2049:2049 -p 111:111 -p 20048:20048 \
  -e NFS_EXPORT_DIR="/exports/myapp" \
  trejo08/nfs-server:v1.1.0
```

### With Persistent Volume
```bash
docker run --privileged \
  -p 2049:2049 -p 111:111 -p 20048:20048 \
  -v /host/data:/exports \
  trejo08/nfs-server:v1.1.0
```

## ☸️ Kubernetes Usage

### Basic Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nfs-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nfs-server
  template:
    metadata:
      labels:
        app: nfs-server
    spec:
      containers:
      - name: nfs-server
        image: trejo08/nfs-server:v1.1.0
        env:
        - name: NFS_EXPORT_DIR
          value: "/exports/shared"
        securityContext:
          privileged: true
        ports:
        - containerPort: 2049
        - containerPort: 111
        - containerPort: 20048
```

### PersistentVolume Configuration
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: shared-pv
spec:
  capacity:
    storage: 20Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: nfs-server.default.svc.cluster.local
    path: "/shared"
```

## 🏗️ Building from Source

### Requirements
- Docker with buildx enabled
- For Apple Silicon: Use buildx for cross-platform compilation

### Local Build
```bash
# Build using script
./build.sh

# Or manually
docker buildx build --platform linux/amd64 -t trejo08/nfs-server:v1.1.0 . --load
```

### Publishing to DockerHub
```bash
# Login to DockerHub
docker login

# Push the image
docker push trejo08/nfs-server:v1.1.0
docker push trejo08/nfs-server:latest
```

## 🔍 Troubleshooting

### Normal Startup Logs
```
🚀 Starting NFS Server...
📁 Export directory: /exports/shared
📁 NFS exports /exports with subdirectory: shared
📝 Starting rpcbind...
📝 Starting rpc.mountd...
📝 Starting rpc.nfsd...
📝 Exporting filesystems...
exporting *:/exports
✅ NFS Server ready!
📁 Exported: /exports (with subdirectory: shared)
🔗 NFSv4.1 server listening on port 2049
💡 Mount path: server:/shared
🔍 Starting filesystem monitoring for /exports/shared...
```

### Common Issues

#### 1. "Unsupported version" (FIXED in v1.0.4)
```bash
# ❌ Previous error (versions < v1.0.4)
rpc.nfsd: 2: Unsupported version

# ✅ Fixed in v1.0.4
# No NFS version restrictions
```

#### 2. Port Already in Use
```bash
# Error: bind: address already in use
# Solution: Change ports or stop conflicting service
docker run -p 12049:2049 -p 1111:111 -p 12048:20048 ...
```

#### 3. Insufficient Privileges
```bash
# Error: operation not permitted
# Solution: Use --privileged flag
docker run --privileged ...
```

### Verification

#### From Host
```bash
# Check available exports
showmount -e localhost

# Mount NFS (Linux/macOS)
sudo mount -t nfs localhost:/shared /mnt/test
```

#### From Another Container
```bash
# Create test container
docker run --rm -it alpine:3.19 sh

# Inside the container
apk add nfs-utils
mkdir /mnt/test
mount -t nfs host.docker.internal:/shared /mnt/test
```

## 📋 Changelog

### v1.1.0 (Current)
- 🔍 **NEW FEATURE**: Filesystem monitoring with inotifywait
- 📊 Real-time logging of file operations (create, delete, modify, move, attrib)
- 🛠️ Enhanced debugging capabilities for NFS operations
- 📝 Timestamped logs with event details
- 🚦 Graceful shutdown handling for monitoring process

### v1.0.4
- ✅ **CRITICAL FIX**: Removed NFS version restrictions
- ✅ Fixed "Unsupported version" errors
- ✅ Maximum compatibility with NFS clients

### v1.0.3
- ❌ Had "Unsupported version" issues
- ⚡ First functional precompiled version

### v1.0.2
- 🔧 Configuration adjustments

### v1.0.1
- 🐛 Minor bug fixes

### v1.0.0
- 🎉 First precompiled version
- ⚡ Startup time optimization

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Create Pull Request

## 📄 License

This project is open source and available under the MIT License.

## ⭐ Star Us

If you find this project useful, please consider giving it a star on GitHub! It helps others discover this optimized NFS solution.

---

**Built with ❤️ for the open source community**