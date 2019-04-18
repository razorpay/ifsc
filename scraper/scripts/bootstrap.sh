#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir --parents data/by-bank sheets

# List of sublet branches, and IMPS only branches
wget "https://www.npci.org.in/national-automated-clearing-live-members-1" --output-document=nach.html --user-agent="Firefox"
wget --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xls" || true
wget --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/RTGS/DOCs/RTGEB0815.xlsx" || true

echo "Sheet Download complete, starting export"

# Convert the NEFT and RTGS lists from RBI
ssconvert --export-file-per-sheet sheets/RTGEB0815.xlsx sheets/RTGS-%n.csv
echo "Converted RTGS file to CSV"
ssconvert --export-file-per-sheet sheets/68774.xls sheets/NEFT-%n.csv
echo "Converted NEFT file to CSV"

# This is the script that does all the data generation
bundle exec ruby generate.rb

pushd data

# Compress the $BANK.json files
tar --gzip --create --file by-bank.tar.gz by-bank
rm --recursive --force by-bank/

# Delete all the sheets for a much smaller
# container store if we are in a build
if [ "$CI" = "true" ]; then
  rm --recursive --force sheets/
fi

popd
