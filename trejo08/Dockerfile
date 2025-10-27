# NFS Server Image - Alpine Linux with NFSv4.1
FROM alpine:3.19

# Install NFS utilities and dependencies
RUN apk add --no-cache \
    nfs-utils \
    rpcbind \
    bash \
    inotify-tools

# Environment variable for export directory (configurable at runtime)
ENV NFS_EXPORT_DIR=/exports/data

# Create base exports directory (container will create subdirs as needed)
RUN mkdir -p /exports \
    && chmod 755 /exports

# Create startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose NFS ports
EXPOSE 2049 111

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]