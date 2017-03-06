# ifsc

This is part of the IFSC toolset released by Razorpay.
You can find more details about the entire release at
[ifsc.razorpay.com](https://ifsc.razorpay.com).

[![wercker status](https://app.wercker.com/status/bc9b22047e1b8eb55ce98ba451d7b504/s/master "wercker status")](https://app.wercker.com/project/byKey/bc9b22047e1b8eb55ce98ba451d7b504)

## Dataset

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
|----|----------|
| IFSC.csv| 19M |
| IFSC.yml| 30M |
| IFSC.json| 38M |
| IFSC-list.json| 1.8M |
| IFSC-list.yml| 1.8M |
| by-bank.zip| 6.3M |

The files with the `-list` suffix only contain the list of IFSC codes.
This can be used for validation purposes.

The `data/by-bank` directory holds multiple JSON files corresponding
to each bank, for faster lookups.

## API Documentation

This repository also hosts the source code for 2 modules: PHP/Node.js as of now.
The only API they provide is validation, as of now. Both are available as a
package in their respective language repos (packagist.org and npmjs.com).

The API is documented below:

### PHP

```php
<?php

use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Bank;

IFSC::validate('KKBK0000261'); // Returns true
IFSC::validate('BOTM0XEEMRA'); // Returns false

IFSC::validateBankCode('PUNB'); // Returns true
IFSC::validateBankCode('ABCD'); // Returns false

IFSC::getBankName('PUNB'); // Returns 'Punjab National Bank'
IFSC::getBankName('ABCD'); // Returns null

IFSC::getBankName(Bank::PUNB); //Returns Punjab National Bank

```

### Node.js

```js
var ifsc = require('ifsc');

ifsc.validate('KKBK0000261'); // returns true
ifsc.validate('BOTM0XEEMRA'); // returns false
```

### Code Notes

Both the packages ship with a 300kb JSON file, that
includes the entire list of IFSC codes, in a compressed,
but human-readable format.

The Bank Code and Names list is mantained manually, but verified
with tests to be accurate as per the latest RBI publications. This
lets us add older Bank codes to the name list, without worrying
about them getting deleted in newer builds.

## License

The code in this repository is licensed under the MIT License. License
text is available in the `LICENSE.txt` file. The dataset itself
should be under public domain.

[rbi]: https://goo.gl/T9188H "goo.gl link because RBI doesn't allow you to link to their website"
[combined]: https://goo.gl/UryY8j "goo.gl link because RBI doesn't allow you to link to their website"
[bf-gem]: https://github.com/deepfryed/bloom-filter
[bf-c]: https://github.com/fragglet/c-algorithms/blob/master/src/bloom-filter.c
[releases]: https://github.com/razorpay/ifsc/releases
