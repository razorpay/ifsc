#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir --parents data/by-bank sheets

if [[ $@ == *'--no-download'* ]]; then
  echo "Skipping download"
else
  # List of sublet branches, and IMPS only branches
  # Till NPCI fixes their certificate: https://twitter.com/captn3m0/status/1247806778529599496
  wget --no-check-certificate --timeout=10 "https://www.npci.org.in/what-we-do/nach/live-members/live-banks" --output-document=nach.html --user-agent="Firefox"
  wget --no-check-certificate --timeout=10 "https://www.npci.org.in/what-we-do/upi/live-members" --output-document=upi.html --user-agent="Firefox"
  wget --no-check-certificate --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xlsx" || true
  wget --no-check-certificate --timestamping --no-verbose --directory-prefix=sheets/ "https://rbidocs.rbi.org.in/rdocs/RTGS/DOCs/RTGEB0815.xlsx" || true

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
