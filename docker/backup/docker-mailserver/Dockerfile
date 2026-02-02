FROM alpine:3.19

# Install required tools
RUN apk add --no-cache \
    bash \
    tar \
    zstd \
    gnupg \
    aws-cli \
    coreutils \
    gzip

RUN mkdir -p /scripts

# Copy backup script
COPY docker-mailserver-backup.sh /scripts/backup.sh
RUN chmod +x /scripts/backup.sh

CMD ["/scripts/backup.sh"]