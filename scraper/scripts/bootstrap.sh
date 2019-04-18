#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir --parents data/by-bank sheets

# Sublet listing comes from NPCI
wget "https://www.npci.org.in/national-automated-clearing-live-members-1" --output-document=nach.html --user-agent="Firefox"
bundle exec ruby parse_nach.rb

wget --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xls" || true
wget --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/RTGS/DOCs/RTGEB0815.xlsx" || true

# This gives us sheets/RTGS-{0|1|2}.csv
ssconvert --export-file-per-sheet sheets/RTGEB0815.xlsx sheets/RTGS-%n.csv
ssconvert --export-file-per-sheet sheets/68774.xls sheets/IFSC-%n.csv

echo "Sheet Download complete, starting export"

# This is the script that does all the data generation
bundle exec ruby generate.rb

cd data

# Compress the $BANK.json files
tar --gzip --create --file by-bank.tar.gz by-bank
rm --recursive --force by-bank/

# Delete all the sheets for a much smaller
# container store if we are in a build
if [ "$CI" = "true" ]; then
  rm --recursive --force sheets/
fi
