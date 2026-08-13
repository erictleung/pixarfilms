#!/usr/bin/env bash

# Setup datasette deployment for pixarfilms to Heroku
# Author: Eric T Leung
# Created: 2021-04-13
# Last ran: 2026-08-12
# Run: bash datasette.sh

# Installation
# pip3 install datasette csvs-to-sqlite

# Convert CSV files to SQLite3 database file
echo "Converting CSV files into a SQLite3 database file..."
FILE=pixarfilms-datasette/pixarfilms.db
if [ -f "$FILE" ]; then
    rm $FILE
fi
csvs-to-sqlite *.csv pixarfilms-datasette/pixarfilms.db
echo "Done!"

# To serve locally
# cd pixarfilms-datasette
# datasette serve pixarfilms.db

# To serve on Vercel preview
# vercel

# To serve on Vercel production
# vercel --prod
