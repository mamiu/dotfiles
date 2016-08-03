#!/bin/bash
# 
# cron job calls this script periodically
# e.g. backup every 3 hours from disk1 to disk2
#             every day from disk1 to disk3
#             every week from disk1 to disk4
# 
# backup process:
# 1. mount destination disk
# 2. start backup
# 3. when backup finished unmount destination disk
# 4. spin down destination disk
# 

BACKUP_DEST_DEV="${1}"
SRC_DISK="disk1"
BASE_MOUNT_DIR="/mnt/"
SRC_DIR="."
DEST_DIR="."
RUN_AS_USER="manu"
#LOG_FILE="/var/log/backup_script.log"

function log() {
    STATE="$1"
    MESSAGE="$2"
    if [ ! -z "$LOG_FILE" ]; then
        echo "$(date "+%d.%m.%Y %R:%S") - ${STATE}: ${MESSAGE}" | tee "$LOG_FILE"
    else
        echo "$(date "+%d.%m.%Y %R:%S") - ${STATE}: ${MESSAGE}"
    fi
}

function mount() {
    MOUNT_POINT="$1"
    if mountpoint "${MOUNT_POINT}" > /dev/null 2>&1 || /bin/false; then
        log "SUCCESS" "${MOUNT_POINT} is already mounted."
    else
        command mount "${MOUNT_POINT}"
        if mountpoint "${MOUNT_POINT}" > /dev/null 2>&1 || /bin/false; then
            log "SUCCESS" "Mounted ${MOUNT_POINT} successfully."
        else
            log "ERROR" "Failed to mount ${MOUNT_POINT}."
            exit 1
        fi
    fi
}

function unmount_and_spindown() {
    UMOUNT_POINT="$1"
    SPINDOWN_DEV="$2"

    # try to unmount destination device
    if umount "$UMOUNT_POINT" > /dev/null 2>&1 || /bin/false; then
        log "INFO" "Backup device unmounted."
    else
        log "WARNING" "Backup device couldn't be unmounted."
    fi
    
    # try to spin down the hard drive
    if /sbin/hdparm -Y "$SPINDOWN_DEV" > /dev/null 2>&1 || /bin/false; then
        log "INFO" "Backup device spinned down."
    else
        log "WARNING" "Backup device couldn't be spinned down."
    fi
}

function backup() {
    log "INFO" "Starting backup process from ${SRC_PATH} to ${DEST_PATH}..."
    su -s /bin/bash -c "rsync -ayhEAX --progress --delete-after --inplace --compress-level=0 --log-file=\"$LOG_FILE\" \"$SRC_PATH\" \"$DEST_PATH\"" $RUN_AS_USER
}

function main() {
    # initialize variables
    DEST_PATH="${BASE_MOUNT_DIR}${DEST_DISK}/${DEST_DIR}"
    SRC_PATH="${BASE_MOUNT_DIR}${SRC_DISK}/${SRC_DIR}"

    # check if logfile exist, if not create it
    if [ ! -e "$LOG_FILE" ]; then
        touch "$LOG_FILE" > /dev/null 2>&1
        chown $RUN_AS_USER:$RUN_AS_USER "$LOG_FILE" > /dev/null 2>&1
    fi

    # check if source device is mounted
    if ! mountpoint "${BASE_MOUNT_DIR}${SRC_DISK}" > /dev/null 2>&1 || /bin/false; then
        log "ERROR" "Backup source device is not mounted!"
        exit 1
    fi

    # check if source directory is readable
    if [ ! -r  "$SRC_PATH" ]; then
        log "ERROR" "Unable to read source directory."
        exit 1
    fi

    # mount destination device
    mount "${BASE_MOUNT_DIR}${DEST_DISK}"

    # check if target directory exist and is writable
    if [ ! -w  "$DEST_PATH" ]; then
        log "ERROR" "Unable to write to target dir."
        exit 1
    fi

    # start the backup process
    backup

    # Unmount the drive so it does not accidentally get damaged or wiped
    unmount_and_spindown "${BASE_MOUNT_DIR}${DEST_DISK}" "$DEST_DEV"

    # exit successfully
    exit 0
}

case "$BACKUP_DEST_DEV" in
    "disk2")
        DEST_DISK="disk2"
        DEST_DEV="/dev/sdb"
    ;;
    "disk3")
        DEST_DISK="disk3"
        DEST_DEV="/dev/sdc"
    ;;
    "disk4")
        DEST_DISK="disk4"
        DEST_DEV="/dev/sdd"
    ;;
    *)
        echo "${BACKUP_DEST_DEV} is no valid parameter."
        echo "Usage: `basename ${0}` backup-destination-disk"
        exit 1 # Exit the script with status 1
esac

main
