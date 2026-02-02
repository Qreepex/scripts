# Docker Container Backup to S3

Docker container that creates encrypted backups of Docker volumes to S3-compatible storage with intelligent retention.

## What it does

- Creates compressed backups of Docker volumes using tar and zstd
- Encrypts backups with AES256 using GPG
- Automatically uploads encrypted backups to S3
- Automatically deletes old backups based on retention policy
- Can be run as Docker container or systemd timer

## Features

- **Compression**: Maximum zstd compression (Level 19)
- **Encryption**: AES256 symmetric encryption with passphrase
- **S3 Compatible**: Works with AWS S3, OVH, MinIO, or any S3-compatible service
- **Intelligent Retention**: Multi-tier retention policy
  - Keep all backups from the last 7 days
  - Keep one backup per day for days 7-30
  - Keep one backup per week for backups older than 30 days
- **Detailed Logging**: Comprehensive backup operation logging

## Configuration

### 1. Edit `.env`

Set your S3 credentials and GPG passphrase:

```bash
GPG_PASSPHRASE="your-secure-passphrase-here"
S3_BUCKET="your-backup-bucket-name"
S3_KEY="your-s3-access-key"
S3_SECRET="your-s3-secret-key"
```

### 2. Edit `docker-compose.yml`

Configure your backup source and S3 endpoint:

```yaml
volumes:
  - /path/to/your/data:/home/data:ro # Change to your data path
environment:
  - BACKUP_SOURCE=/home/data # Match volume path
  - S3_ENDPOINT=https://s3.amazonaws.com/ # Your S3 endpoint
  - S3_PATH=backups # S3 backup path
```

## Usage

### Run Manually

```bash
docker-compose run --rm backup
```

### Schedule with Systemd Timer

1. Copy systemd files:

```bash
sudo cp mailserver-backup.service /etc/systemd/system/
sudo cp mailserver-backup.timer /etc/systemd/system/
```

2. Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable mailserver-backup.timer
sudo systemctl start mailserver-backup.timer
```

3. Check status:

```bash
sudo systemctl status mailserver-backup.timer
sudo systemctl list-timers
```

## Retention Policy

- **Last 7 days**: Keep all backups
- **7-30 days**: Keep one backup per day
- **Over 30 days**: Keep one backup per week

## Restore from Backup

```bash
# Download backup from S3
aws s3 cp s3://your-bucket/backups/backup_YYYYMMDD_HHMMSS.tar.zst.gpg . \
  --endpoint-url https://s3.amazonaws.com/

# Decrypt backup
gpg --decrypt backup_YYYYMMDD_HHMMSS.tar.zst.gpg | tar xzst -

# Extract files
tar -xf backup_YYYYMMDD_HHMMSS.tar.zst
```

## Encryption

Backups are encrypted using GPG with AES256 symmetric encryption. The passphrase is stored in the `.env` file and should be kept secure.

## Security Notes

- Store `.env` file securely (not in version control)
- Use strong passphrases for encryption
- Rotate S3 credentials regularly
- Test restore procedures regularly
- Consider using IAM roles instead of static keys
- Verify backup integrity periodically
