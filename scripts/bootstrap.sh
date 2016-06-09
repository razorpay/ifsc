#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

wget "https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009" -O list.html -o /dev/null
ruby parse_list.rb > excel_list.txt
rm -rf sheets
mkdir -p sheets
wget -i excel_list.txt -P sheets/
mkdir -p data/by-bank
# This is the script that does all the data generation
ruby generate.rb

cd ..
npm install
cd scripts
node build-regex.js