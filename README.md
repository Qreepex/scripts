# Backup Scripts Collection

A collection of handy backup scripts for databases and Docker containers to S3-compatible storage.

**Disclaimer**: These scripts are provided as-is without any warranty. They are meant to be a helpful reference and starting point for your own backup solutions. No claims are made regarding their functionality, security, or suitability for production use. Always test thoroughly in your environment and implement additional security measures as needed.

## Available Backups

### Kubernetes Backups

- [PostgreSQL Backup](kubernetes/backup/postgres) - Automated PostgreSQL backups with intelligent retention
- [MongoDB Backup](kubernetes/backup/mongodb) - Automated MongoDB backups with intelligent retention

### Docker Backups

- [Docker Container Backup](docker/backup/docker-mailserver) - Encrypted Docker volume backups with AES256 encryption

## Features

All backup solutions include:

- **Compression**: Efficient storage using gzip or zstd
- **Encryption**: Optional GPG encryption (Docker backups)
- **S3 Compatible**: Works with AWS S3, OVH, MinIO, and other S3-compatible services
- **Intelligent Retention**: Multi-tier retention policies to manage backup storage
- **Automated Cleanup**: Old backups are automatically deleted based on retention rules
- **Detailed Logging**: Comprehensive operation logs for monitoring

## Quick Start

1. Choose your backup solution:
   - **Kubernetes**: See [PostgreSQL](kubernetes/backup/postgres/README.md) or [MongoDB](kubernetes/backup/mongodb/README.md)
   - **Docker**: See [Docker Container Backup](docker/backup/docker-mailserver/README.md)

2. Configure your S3 credentials and deployment settings

3. Deploy and test your backup

## Retention Policies

Each backup solution implements a multi-tier retention strategy:

- **PostgreSQL/MongoDB (Kubernetes)**:
  - Keep all backups from the last 30 days
  - Keep one per day for days 30-90
  - Keep one per week for backups over 90 days old

- **Docker Containers**:
  - Keep all backups from the last 7 days
  - Keep one per day for days 7-30
  - Keep one per week for backups over 30 days old

## License

MIT License - See [LICENSE](LICENSE) file for details

## Security Considerations

- Store credentials in environment variables or secrets management systems
- Never commit `.env` files or secret configurations to version control
- Use strong, unique passphrases for encryption
- Regularly test backup and restore procedures
- Use S3-side encryption in addition to backup encryption
- Implement access controls on S3 buckets and credentials
