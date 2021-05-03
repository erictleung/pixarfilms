#!/usr/bin/env bash

# Setup datasette deployment for pixarfilms to Heroku
# Author: Eric T Leung
# Created: 2021-04-13
# Last ran: 2021-05-02
# Run: bash datasette.sh

# Installation
# pip3 install datasette csvs-to-sqlite

# Convert CSV files to SQLite3 database file
FILE=pixarfilms.db
if [ -f "$FILE" ]; then
    rm $FILE
fi
csvs-to-sqlite *.csv pixarfilms.db

# Publish to Heroku
datasette publish heroku pixarfilms.db -n pixarfilms-datasette

# To serve locally
# datasette serve pixarfilms.db
