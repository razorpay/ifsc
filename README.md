# ifsc-downloader

This is part of the IFSC toolset released by Razorpay.
You can find more details about the entire release at
[ifsc.razorpay.com](https://ifsc.razorpay.com).

This is just the downloader portion that scrapes
the entire dataset from the RBI. The list of Excel
files can be found [here][rbi]. There is also a
[combined Excel file][combined] link around on the internet
but that file doesn't seem to be updated.

You will need ruby and wget to run the script, which
is just `sh bootstrap.sh`. This will scrape the list page,
download all the excel files in the `sheets/` directory,
parse them and generate datasets in the `data/` directory.

The following files will be generated, with approx file
sizes given as well:

|File|Size|
|----|----|
|IFSC.csv|19M|
|IFSC.json|40M|
|IFSC.marshal|40M|
|IFSC.yml|31M|
|IFSC-list.json|1.8M|
|IFSC-list.marshal|2.3M|
|IFSC-list.yml|1.8M|

The files with the `-list` suffix only contain the list of IFSC codes.
This can be used for validation purposes.

[rbi]: https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009
[combined]: https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xls