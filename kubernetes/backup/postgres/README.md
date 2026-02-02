# PostgreSQL Backup to S3

Kubernetes CronJob for automated PostgreSQL database backups to S3-compatible storage with intelligent retention.

## What it does

- Creates compressed backups of the PostgreSQL database
- Automatically uploads them to S3
- Automatically deletes old backups based on retention policy

## Retention

- **Last 30 days**: Keep all backups
- **30-90 days**: Keep one backup per day
- **Over 90 days**: Keep one backup per week

## Configuration

Edit in `pg-backup-job.yaml`:

| Variable        | Description                                       |
| --------------- | ------------------------------------------------- |
| `POSTGRES_HOST` | PostgreSQL hostname/service                       |
| `POSTGRES_USER` | Database user                                     |
| `POSTGRES_DB`   | Database name                                     |
| `schedule`      | Cron schedule (e.g. `"0 */12 * * *"` = every 12h) |

Set in `pg-backup-secret.yaml`:

| Variable                | Description     |
| ----------------------- | --------------- |
| `AWS_ACCESS_KEY_ID`     | S3 access key   |
| `AWS_SECRET_ACCESS_KEY` | S3 secret key   |
| `S3_ENDPOINT`           | S3 endpoint URL |
| `S3_BUCKET`             | S3 bucket name  |
