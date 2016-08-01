# ifsc

This is part of the IFSC toolset released by Razorpay.
You can find more details about the entire release at
[ifsc.razorpay.com](https://ifsc.razorpay.com).

If you are just looking for the dataset, go to
the [releases][releases] section and download
the latest release.

The code is just the downloader portion that scrapes
the entire dataset from the RBI. The list of Excel
files can be found [here][rbi]. There is also a
[combined Excel file][combined] link around on the internet
but that file doesn't seem to be updated.

You will need ruby and wget to run the script, which
is just `cd scripts && sh bootstrap.sh`. This will scrape the list page,
download all the excel files in the `sheets/` directory,
parse them and generate datasets in the `scripts/data/` directory.

The following files will be generated, with approx file
sizes given as well:

|File|Size|
|----|----|
|IFSC.csv|19M|
|IFSC.json|38M|
|IFSC-list.bloom|264K|
|IFSC-list.json|1.8M|
|IFSC-list.marshal |2.3M|
|IFSC-list.yml|1.8M|
|IFSC.marshal|38M|
|IFSC.yml|30M|

The files with the `-list` suffix only contain the list of IFSC codes.
This can be used for validation purposes. The `.bloom` file is a binary
bloom filter dump generated and readable using the [bloom-filter][bf-gem]
ruby gem. It uses the bloom filter implementation from [here][bf-c].

Note that the bloom filter is always probabilistic, and will return
false positives for at max 0.1% of the cases.

The `data/by-bank` directory holds multiple JSON files corresponding
to each bank, for faster lookups.

## License

The code in this repository is licensed under the MIT License. License
text is available in the `LICENSE.txt` file. The dataset itself
should be under public domain.

[rbi]: https://goo.gl/T9188H "goo.gl link because RBI doesn't allow you to link to their website"
[combined]: https://goo.gl/UryY8j "goo.gl link because RBI doesn't allow you to link to their website"
[bf-gem]: https://github.com/deepfryed/bloom-filter
[bf-c]: https://github.com/fragglet/c-algorithms/blob/master/src/bloom-filter.c
[releases]: https://github.com/razorpay/ifsc-downloader/releases