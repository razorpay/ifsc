#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

mkdir --parents data
mkdir --parents sheets

# # Sublet listing comes from NPCI
wget "https://www.npci.org.in/national-automated-clearing-live-members-1" --output-document=nach.html
NACH_URL=$(bundle exec ruby parse_nach.rb)

# Primary IFSC listings
RBI_LIST_URL="https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009"

wget --verbose "$RBI_LIST_URL" --output-document=list.html

bundle exec ruby parse_list.rb > excel_list.txt
rm --recursive --force sheets

# Cache the downloaded files
if [ -z "$WERCKER_CACHE_DIR" ]; then
    # A few files return a 404, so we force true here
    wget --timestamping --no-verbose --input-file=excel_list.txt --directory-prefix=sheets/ || true
else
    # Make sure we have a cache
    mkdir -p "$WERCKER_CACHE_DIR/sheets"
    wget --timestamping --no-verbose --input-file=excel_list.txt --directory-prefix="$WERCKER_CACHE_DIR/sheets/" || true
    # Copy back to the cache if the download worked
    cp --recursive --preserve=timestamps "$WERCKER_CACHE_DIR/sheets" .
fi


echo "Sheet Download complete, starting export"

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
