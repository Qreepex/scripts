#!/bin/bash
set -e

# Configuration from environment variables
BACKUP_SOURCE="${BACKUP_SOURCE:-/home/data}" # Change in .env or docker-compose.yml
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/tmp/mailserver_backup"
BACKUP_FILE="mailserver_${TIMESTAMP}.tar.zst"
ENCRYPTED_FILE="mailserver_${TIMESTAMP}.tar.zst.gpg"

# S3 Configuration
S3_BUCKET="${S3_BUCKET}"
S3_ENDPOINT="${S3_ENDPOINT}"
S3_PATH="${S3_PATH:-backups}"

# GPG Encryption
GPG_RECIPIENT="${GPG_RECIPIENT}" # GPG Key ID or Email (optional)
GPG_PASSPHRASE="${GPG_PASSPHRASE}" # Passphrase for GPG Key

echo "[$(date)] ===== Starting Backup Job ====="
echo "[$(date)] Source: ${BACKUP_SOURCE}"

# Create temporary backup directory
mkdir -p ${BACKUP_DIR}

# Create backup with tar and maximum zstd compression (Level 19)
echo "[$(date)] Creating compressed backup..."

# Pipe tar through zstd for compression
tar -cf - -C $(dirname "${BACKUP_SOURCE}") $(basename "${BACKUP_SOURCE}") | \
    zstd -19 -T0 -o ${BACKUP_DIR}/${BACKUP_FILE}

BACKUP_SIZE=$(du -h ${BACKUP_DIR}/${BACKUP_FILE} | cut -f1)
echo "[$(date)] Backup created: ${BACKUP_FILE} (${BACKUP_SIZE})"

# Encrypt backup with passphrase using AES256
echo "[$(date)] Encrypting backup with passphrase..."
echo "${GPG_PASSPHRASE}" | gpg \
    --batch \
    --yes \
    --passphrase-fd 0 \
    --symmetric \
    --cipher-algo AES256 \
    --output ${BACKUP_DIR}/${ENCRYPTED_FILE} \
    ${BACKUP_DIR}/${BACKUP_FILE}

# Delete unencrypted backup file
rm ${BACKUP_DIR}/${BACKUP_FILE}

ENCRYPTED_SIZE=$(du -h ${BACKUP_DIR}/${ENCRYPTED_FILE} | cut -f1)
echo "[$(date)] Encrypted backup: ${ENCRYPTED_FILE} (${ENCRYPTED_SIZE})"

# Upload to S3
echo "[$(date)] Uploading to S3..."
aws s3 cp ${BACKUP_DIR}/${ENCRYPTED_FILE} \
    s3://${S3_BUCKET}/${S3_PATH}/${ENCRYPTED_FILE} \
    --endpoint-url ${S3_ENDPOINT}

echo "[$(date)] Upload successful"

# Clean up local backup
rm -rf ${BACKUP_DIR}

# ===== INTELLIGENT RETENTION CLEANUP =====
echo "[$(date)] Starting retention cleanup..."

NOW=$(date +%s)
SEVEN_DAYS_AGO=$((NOW - 7*86400))
THIRTY_DAYS_AGO=$((NOW - 30*86400))

BACKUP_LIST="/tmp/backup_list.txt"

# List all encrypted backups
aws s3 ls s3://${S3_BUCKET}/${S3_PATH}/ \
    --endpoint-url ${S3_ENDPOINT} | \
    awk '{print $4}' | \
    grep -E '^backup_[0-9]{8}_[0-9]{6}\.tar\.zst\.gpg$' | \
    sort > ${BACKUP_LIST}

KEEP_LIST="/tmp/keep_backups.txt"
> ${KEEP_LIST}

KEEP_COUNT=0
DELETE_COUNT=0

echo "[$(date)] Processing $(wc -l < ${BACKUP_LIST}) backups..."

# Temporäre Tracking-Dateien initialisieren
> /tmp/days_7_30.txt
> /tmp/weeks_30plus.txt

while IFS= read -r FILE; do
    if [ -z "$FILE" ]; then
        continue
    fi
    
    # Extract date (YYYYMMDD)
    FILE_DATE=$(echo "$FILE" | sed -E 's/backup_([0-9]{8})_.*/\1/')
    
    if [ -z "$FILE_DATE" ] || [ ${#FILE_DATE} -ne 8 ]; then
        echo "Warning: Could not parse date for ${FILE}"
        continue
    fi
    
    # Convert date to epoch
    YEAR=${FILE_DATE:0:4}
    MONTH=${FILE_DATE:4:2}
    DAY=${FILE_DATE:6:2}
    FILE_EPOCH=$(date -d "${YEAR}-${MONTH}-${DAY}" +%s 2>/dev/null || echo 0)
    
    if [ $FILE_EPOCH -eq 0 ]; then
        echo "Warning: Invalid date in ${FILE}"
        continue
    fi
    
    AGE_DAYS=$(( (NOW - FILE_EPOCH) / 86400 ))
    
    KEEP=0
    
    if [ $FILE_EPOCH -gt $SEVEN_DAYS_AGO ]; then
        # < 7 days: KEEP all
        KEEP=1
        REASON="< 7 days"
        
    elif [ $FILE_EPOCH -gt $THIRTY_DAYS_AGO ]; then
        # 7-30 days: Keep only 1 per day
        DAY_KEY="${FILE_DATE}"
        
        if ! grep -q "^${DAY_KEY}$" /tmp/days_7_30.txt 2>/dev/null; then
            KEEP=1
            REASON="7-30 days (first of day)"
            echo "${DAY_KEY}" >> /tmp/days_7_30.txt
        else
            REASON="7-30 days (duplicate)"
        fi
        
    else
        # > 30 days: Keep only 1 per week
        WEEK_NUMBER=$(date -d "${YEAR}-${MONTH}-${DAY}" +%Y-W%V 2>/dev/null || echo "")
        
        if [ ! -z "$WEEK_NUMBER" ]; then
            if ! grep -q "^${WEEK_NUMBER}$" /tmp/weeks_30plus.txt 2>/dev/null; then
                KEEP=1
                REASON="> 30 days (first of week)"
                echo "${WEEK_NUMBER}" >> /tmp/weeks_30plus.txt
            else
                REASON="> 30 days (duplicate)"
            fi
        fi
    fi
    
    if [ $KEEP -eq 1 ]; then
        echo "KEEP: ${FILE} (${AGE_DAYS}d, ${REASON})"
        echo "${FILE}" >> ${KEEP_LIST}
        KEEP_COUNT=$((KEEP_COUNT + 1))
    else
        echo "DELETE: ${FILE} (${AGE_DAYS}d, ${REASON})"
        aws s3 rm s3://${S3_BUCKET}/${S3_PATH}/${FILE} \
            --endpoint-url ${S3_ENDPOINT} || echo "Failed to delete ${FILE}"
        DELETE_COUNT=$((DELETE_COUNT + 1))
    fi
    
done < ${BACKUP_LIST}

echo ""
echo "[$(date)] Retention summary:"
echo "  Kept: ${KEEP_COUNT} backups"
echo "  Deleted: ${DELETE_COUNT} backups"

# Clean up temp files
rm -f ${BACKUP_LIST} ${KEEP_LIST} /tmp/days_7_30.txt /tmp/weeks_30plus.txt

echo "[$(date)] ===== Backup job completed successfully ====="