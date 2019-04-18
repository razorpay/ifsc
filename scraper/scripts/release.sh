#!/bin/bash

# Generate a Release Changelog
# 1. Clone the latest ifsc-api repo
git clone https://github.com/razorpay/ifsc-api.git --depth 1
# 2. Extract the latest files
(cd data && tar -xzvf by-bank.tar.gz)
# 3. Copy the data files to the repo
cp data/by-bank/* ifsc-api/data/
pushd ifsc-api
git add data/
# Generate the complete diff
git diff --staged -U0 |grep '"IFSC": "' |awk '{print $1substr($3,2,11)}'|sort -u > diff.txt
# Generate the summarized diff
cat diff.txt | cut -c-5 | sort |uniq -c | sort -n > diffsummary.txt
popd
# Run the php script
php releasenotes.php > release.md
