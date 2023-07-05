#!/bin/bash

SCAN_DIR=/srv/ftp

[ $# -ne 0 ] && SCAN_DIR=$1

echo "Scanning $SCAN_DIR..."
clamscan -r --quiet --move=/var/quarantine/ $SCAN_DIR
echo "Done"
