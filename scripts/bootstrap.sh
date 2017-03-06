#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir data
wget --no-verbose "https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009" --output-document=list.html --output-file=/dev/null
bundle exec ruby parse_list.rb > excel_list.txt
rm --recursive --force sheets
mkdir --parents sheets
wget --no-verbose --input-file=excel_list.txt --directory-prefix=sheets/
mkdir --parents data/by-bank
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

cd ..
