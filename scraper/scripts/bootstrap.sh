#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir -p data/by-bank sheets
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/97.0.4692.99 Safari/537.36"

# Downloads are disabled for now, since NPCI setup Bot protection at their end.
# wget --no-verbose --timeout=30 "https://www.npci.org.in/what-we-do/nach/live-members/live-banks" --output-document=nach.html --user-agent="$USER_AGENT"
# wget --no-verbose --timeout=30 "https://www.npci.org.in/what-we-do/upi/live-members" --output-document=upi.html --user-agent="$USER_AGENT"

if [[ $@ == *'--no-download'* ]]; then
  echo "Skipping sheet download"
else
  wget --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xlsx" --user-agent="$USER_AGENT"
  wget --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/RTGS/DOCs/RTGEB0815.xlsx" --user-agent="$USER_AGENT"

  echo "Sheet Download complete, starting export"
fi

if [[ $@ == *'--no-convert'* ]]; then
  echo "Skipping sheet conversion"
else
  # Convert the NEFT and RTGS lists from RBI
  ssconvert --export-file-per-sheet sheets/RTGEB0815.xlsx sheets/RTGS-%n.csv
  echo "Converted RTGS file to CSV"
  ssconvert --export-file-per-sheet sheets/68774.xlsx sheets/NEFT-%n.csv
  echo "Converted NEFT file to CSV"
fi

# This is the script that does all the data generation
bundle exec ruby generate.rb

pushd data

# Compress the $BANK.json files
tar --gzip --create --file by-bank.tar.gz by-bank
tar cvf by-bank.tar by-bank
rm --recursive --force by-bank/

# Delete all the sheets for a much smaller
# container store if we are in a build
if [ "$CI" = "true" ]; then
  rm --recursive --force sheets/
fi

popd
