#!/bin/bash

# File types to be copied
TYPES="mp3,ogg,oga,aac,m4a"

# Run if files are older then this value.
# This is useful when using cron, to avoid copying over and over.
# Use 0 to disable.
MINUTES=60

# A prefix added to file names
PREFIX="refill-"

TEMP_DIR="/dev/shm/"

# Check params
if [ $# -ne 3 ]; then
    echo "Usage: refill.sh NUMBEROFSONGS /path/to/your/music/ /target/path/"
    exit 1
fi
SONGS=$1
MUSIC="$2"
TARGET="$3"

if [ ! -d "$MUSIC" ]; then
    echo "$MUSIC does not exist"
    exit 1
fi

if [ ! -d "$TARGET" ]; then
    echo "$TARGET does not exist"
    exit 1
fi


# Check commands
function checkCommand() {
    type -P $1 &>/dev/null || { echo "$1 command not found."; exit 1; }
}

checkCommand "rsync"
checkCommand "shuf"
checkCommand "find"
checkCommand "sed"
checkCommand "date"
checkCommand "basename"

# Check last refill time
if [ $MINUTES -gt 0 ]; then
    NOW=$(date +%s)
    TIME_FILE="$TARGET".refill
    if [ -f "$TIME_FILE" ]; then
        TARGET_MTIME=$(cat "$TIME_FILE");
        TARGET_AGE=$[$NOW-$TARGET_MTIME]
        MAX_SECONDS=$[$MINUTES*60]
        if [ $TARGET_AGE -lt $MAX_SECONDS ]; then
            echo "Refilled $[TARGET_AGE/60] minutes ago"
            exit 1
        fi
    fi
    echo $NOW > "$TIME_FILE"
fi

# Temp dir
TEMP="$TEMP_DIR$PREFIX$NOW/"
rm -rf "$TEMP" && mkdir "$TEMP"

# find, shuffle and symlink files
FIND_TYPES=$(echo $TYPES | sed 's/,/\\|/g' -)
find "$MUSIC" -type f -regex ".*\.\($FIND_TYPES\)$" | \
    shuf -n $SONGS --random-source=/dev/urandom |
while IFS= read -r i
do
    FILENAME=$(basename "$i")
    ln -s "$i" "$TEMP/$PREFIX$FILENAME"
done

# delete old files
rm "$TARGET"$PREFIX*

# copy new files
rsync -av --no-p --no-o --no-g --no-times --copy-links "$TEMP" "$TARGET"

# cleanup
rm -rf "$TEMP"
