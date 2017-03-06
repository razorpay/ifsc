#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

wget "https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009" -O list.html -o /dev/null
bundle exec ruby parse_list.rb > excel_list.txt
rm -rf sheets
mkdir -p sheets
wget -i excel_list.txt -P sheets/
mkdir -p data/by-bank
# This is the script that does all the data generation
bundle exec ruby generate.rb
