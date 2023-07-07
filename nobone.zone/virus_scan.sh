#!/bin/bash

SCAN_DIR=/bdisk/ftp

[ $# -ne 0 ] && SCAN_DIR=$1

echo "$(date) Scanning $SCAN_DIR..."
clamscan -r --quiet --move=/var/quarantine/ $SCAN_DIR
echo "Done"
