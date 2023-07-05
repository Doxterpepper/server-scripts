#!/bin/bash

SEARCH_DIR=/bdisk/ftp
GRAVEYARD=/bdisk/zip_graveyard
JOBS=4

fd -j $JOBS ".*zip$" $SEARCH_DIR --exec "mv {} $GRAVEYARD"
