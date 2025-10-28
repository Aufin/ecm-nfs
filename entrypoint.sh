#!/bin/bash

# NFS Server entrypoint script
set -e

echo "🚀 Starting NFS Server..."
echo "📁 Export directory: $NFS_EXPORT_DIR"

# For NFS export, we need to export /exports and create subdirectory structure
# This works around Docker filesystem export limitations
mkdir -p /exports
chmod 755 /exports

# Create the configured subdirectory within /exports
NFS_SUBDIR=$(basename "$NFS_EXPORT_DIR")
mkdir -p "/exports/$NFS_SUBDIR"
chmod 755 "/exports/$NFS_SUBDIR"

# Create a placeholder file to ensure directory has content
touch "/exports/$NFS_SUBDIR/.nfs_export_ready"
chmod 644 "/exports/$NFS_SUBDIR/.nfs_export_ready"

# Always export /exports (root) and clients can access subdirectories
echo "/exports *(rw,sync,no_subtree_check,no_root_squash,fsid=0)" > /etc/exports

echo "📁 NFS exports /exports with subdirectory: $NFS_SUBDIR"

# Start rpcbind in background
echo "📝 Starting rpcbind..."
rpcbind -f &
sleep 2

# Start rpc.mountd in background (all supported versions)
echo "📝 Starting rpc.mountd..."
rpc.mountd &
sleep 2

# Start rpc.nfsd in background (all supported versions) 
echo "📝 Starting rpc.nfsd..."
rpc.nfsd 8 &
sleep 2

# Export filesystems
echo "📝 Exporting filesystems..."
exportfs -arv

echo "✅ NFS Server ready!"
echo "📁 Exported: /exports (with subdirectory: $NFS_SUBDIR)"
echo "🔗 NFSv4.1 server listening on port 2049"
echo "💡 Mount path: server:/$NFS_SUBDIR"

# Start filesystem monitoring in background
echo "🔍 Starting filesystem monitoring for /exports/$NFS_SUBDIR..."
inotifywait -m -r -e create,delete,modify,move,attrib "/exports/$NFS_SUBDIR" --format '%T [%e] %w%f' --timefmt '%Y-%m-%d %H:%M:%S' &
INOTIFY_PID=$!

# Function to handle shutdown
shutdown_handler() {
    echo "🛑 Shutting down NFS server..."
    kill $INOTIFY_PID 2>/dev/null || true
    killall rpc.nfsd 2>/dev/null || true
    killall rpc.mountd 2>/dev/null || true
    killall rpcbind 2>/dev/null || true
    exit 0
}

# Set up signal handlers
trap shutdown_handler SIGTERM SIGINT

# Keep container running and wait for background processes
wait