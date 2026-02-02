# MongoDB Backup to S3

Kubernetes CronJob for automated MongoDB database backups to S3-compatible storage with intelligent retention.

## What it does

- Creates compressed backups of the MongoDB database
- Automatically uploads them to S3
- Automatically deletes old backups based on retention policy

## Retention

- **Last 7 days**: Keep all backups
- **7-30 days**: Keep one backup per day
- **Over 30 days**: Keep one backup per week

## Configuration

Edit in `mongo-backup-job.yaml`:

| Variable         | Description                                       |
| ---------------- | ------------------------------------------------- |
| `MONGO_HOST`     | MongoDB hostname/service                          |
| `MONGO_PORT`     | MongoDB port                                      |
| `MONGO_DATABASE` | Database name to backup                           |
| `schedule`       | Cron schedule (e.g. `"0 */12 * * *"` = every 12h) |

Set in `mongo-backup-secret.yaml`:

| Variable                | Description      |
| ----------------------- | ---------------- |
| `MONGO_USER`            | MongoDB user     |
| `MONGO_PASSWORD`        | MongoDB password |
| `AWS_ACCESS_KEY_ID`     | S3 access key    |
| `AWS_SECRET_ACCESS_KEY` | S3 secret key    |
| `S3_ENDPOINT`           | S3 endpoint URL  |
| `S3_BUCKET`             | S3 bucket name   |
