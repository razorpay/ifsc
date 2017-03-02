#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir data
wget "https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009" -O list.html -o /dev/null
bundle exec ruby parse_list.rb > excel_list.txt
rm -rf sheets
mkdir -p sheets
wget -i excel_list.txt -P sheets/
mkdir -p data/by-bank
# This is the script that does all the data generation
bundle exec ruby generate.rb
cd data

# Zip the bank files
zip -r by-bank.zip by-bank
rm -rf by-bank/

# Delete all the sheets for a much smaller
# container store if we are in a build
if [ "$CI" = "true" ]; then
  rm -rf sheets/
fi

cd ..
