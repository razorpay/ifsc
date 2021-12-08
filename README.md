# ifsc

This is part of the IFSC toolset released by Razorpay.
You can find more details about the entire release at
[ifsc.razorpay.com](https://ifsc.razorpay.com).

[![](https://images.microbadger.com/badges/image/razorpay/ifsc:2.0.5.svg)](https://microbadger.com/images/razorpay/ifsc:2.0.5) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

[![](https://images.microbadger.com/badges/version/razorpay/ifsc:2.0.5.svg)](https://microbadger.com/images/razorpay/ifsc:2.0.5) [![npm version](https://badge.fury.io/js/ifsc.svg)](https://badge.fury.io/js/ifsc) [![Gem Version](https://badge.fury.io/rb/ifsc.svg)](https://badge.fury.io/rb/ifsc) [![PHP version](https://badge.fury.io/ph/razorpay%2Fifsc.svg)](https://badge.fury.io/ph/razorpay%2Fifsc) [![Hex pm](http://img.shields.io/hexpm/v/ifsc.svg)](https://hex.pm/packages/ifsc)

## Dataset

If you are just looking for the dataset, go to the [releases][releases] section and download the latest release.

The latest `scraper` workflow on GitHub should publish a `release-artifact` as well.

### Source

The source for the dataset are the following files:

-  List of NEFT IFSCs from [RBI website][combined]
-  List of RTGS IFSCs from [RBI website][rtgs]
-  List of ACH Live Banks from [NPCI website][ach] used for IFSC sublet branches
-  List of [IMPS Live members](https://www.npci.org.in/what-we-do/imps/live-members) on the NPCI website.
-  RBI maintains a [list of banks in India](https://www.rbi.org.in/commonman/english/scripts/banksinindia.aspx) and [websites of banks in India](https://www.rbi.org.in/scripts/banklinks.aspx)

#### SWIFT

SWIFT/BIC codes are supported for a few banks.

##### SBI
-  https://sbi.co.in/web/nri/quick-links/swift-codes
-  https://sbi.co.in/documents/16012/263663/sbinri_merged_bran_swfcodet.xlsx
-  Branch codes from above are checked against the [SBI Branch Locator](https://www.sbi.co.in/web/home/locator/branch) to get the IFSC.

##### PNB
- https://pnbindia.com/downloadprocess.aspx?fid=Zb7ImdUNlz9Ge73qn1nXQg==
- https://www.pnbindia.in/document/PNB-helpdesk/bic_code.pdf

##### HDFC
- https://www.hdfcbank.com/nri-banking/correspondent-banks

## Installation

## Ruby

Add this line to your application's Gemfile:

```ruby
gem "ifsc"
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install ifsc
```

Inside of your Ruby program do:

```ruby
require "ifsc"
```

...to pull it in as a dependency.

## PHP

`composer require php-http/curl-client razorpay/ifsc`

The PHP package has a dependency on the virtual package `php-http/client-implementation` which requires you to install an adapter, but we do not care which one. That is an implementation detail in your application. You do not have to use the `php-http/curl-client` if you do not want to. You may use the `php-http/guzzle6-adapter`. Read more about the virtual packages, why this is a good idea and about the flexibility it brings at the [HTTPlug docs](http://docs.php-http.org/en/latest/httplug/users.html). You can find a list of suported providers on [packagist](https://packagist.org/providers/php-http/client-implementation).

The minimum [PHP version supported is 7.3](https://endoflife.date/php). The package can be installed on PHP>=7.1 however.

## Node.js

`$ npm install ifsc`

## Go

This package is compatible with modern Go releases in module mode, with Go installed:

`go get github.com/razorpay/ifsc/v2`

will resolve and add the package to the current development module, along with its dependencies.

Alternatively the same can be achieved if you use import in a package:

`import "github.com/razorpay/ifsc/v2/src/go"`

and run go get without parameters.

Finally, to use the top-of-trunk version of this repo, use the following command:

`go get github.com/razorpay/ifsc/v2@master`

## Support Matrix

Only the latest version of each SDK is considered.

| Language | Validation | API Client | Sublet Support (Custom) | Bank Constants |
| -------- | ---------- | ---------- | ----------------------- | -------------- |
| PHP      | ✅         | ✅         | ✅ (✅)                 | ✅             |
| Ruby     | ✅         | ✅         | ✅ (✅)                 | ✅             |
| Node.js  | ✅         | ✅         | ❎ (❎)                 | ✅             |
| Go       | ✅         | ✅         | ✅ (✅)                 | ✅             |

## API Documentation

This repository also hosts the source code for 5 modules: PHP/Node.js/Ruby/Go as of now.
The API is documented below:

### PHP

```php
<?php

use Razorpay\IFSC\Bank;
use Razorpay\IFSC\IFSC;
use Razorpay\IFSC\Client;

IFSC::validate('KKBK0000261'); // Returns true
IFSC::validate('BOTM0XEEMRA'); // Returns false

IFSC::validateBankCode('PUNB'); // Returns true
IFSC::validateBankCode('ABCD'); // Returns false

IFSC::getBankName('PUNB'); // Returns 'Punjab National Bank'
IFSC::getBankName('ABCD'); // Returns null

IFSC::getBankName(Bank::PUNB); //Returns Punjab National Bank

Bank::getDetails(Bank::PUNB);
Bank::getDetails('PUNB');

// Returns an array:
// [
//    'code' => 'PUNB',
//    'type' => 'PSB',
//    'ifsc' => 'PUNB0244200',
//    'micr' => '110024001',
//    'iin' => '508568',
//    'apbs' => true,
//    'ach_credit' => true,
//    'ach_debit' => true,
//    'nach_debit' => true,
//    'name' => 'Punjab National Bank',
//    'bank_code' => '024',
//    'upi' => true
// ]

$client = new Client();
$res = $client->lookupIFSC('KKBK0000261');

echo $res->bank; // 'KOTAK MAHINDRA BANK LIMITED'
echo $res->branch; // 'GURGAON'
echo $res->address; // 'JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,'
echo $res->contact; // '4131000'
echo $res->city; // 'GURGAON'
echo $res->district; // 'GURGAON'
echo $res->state; // 'HARYANA'
echo $res->getBankCode(); // KKBK
echo $res->getBankName(); // 'Kotak Mahindra Bank'

// lookupIFSC may throw `Razorpay\IFSC\Exception\ServerError`
// in case of server not responding in time
// or Razorpay\IFSC\Exception\InvalidCode in case
// the IFSC code is invalid
```

### Node.js

```js
var ifsc = require('ifsc');

ifsc.validate('KKBK0000261'); // returns true
ifsc.validate('BOTM0XEEMRA'); // returns false

ifsc.fetchDetails('KKBK0000261').then(function(res) {
   console.log(res);
});

console.log(ifsc.bank.PUNB); // prints PUNB
// Prints the entire JSON from https://ifsc.razorpay.com/KKBK0000261
// res is an object, not string
```

### Ruby

Make sure you have `require 'ifsc'` in your code.
Validating a code offline. (Remember to keep the gem up to date!)

```rb
# valid?

Razorpay::IFSC::IFSC.valid? 'KKBK0000261' # => true
Razorpay::IFSC::IFSC.valid? 'BOTM0XEEMRA' # => false

# validate!

Razorpay::IFSC::IFSC.validate! 'KKBK0000261' # => true
Razorpay::IFSC::IFSC.validate! 'BOTM0XEEMRA' # => Razorpay::IFSC::InvalidCodeError

# bank_name_for(code) gets you the bank name offline
Razorpay::IFSC::IFSC.bank_name_for 'PUNB0026200' -> "Punjab National Bank"
Razorpay::IFSC::IFSC.bank_name_for 'KSCB0006001' -> "Tumkur District Central Bank"

# get_details gets you the bank details from `banks.json`
Razorpay::IFSC::Bank.get_details 'PUNB'
{
   code: 'PUNB',
   type: 'PSB',
   ifsc: 'PUNB0244200',
   micr: '110024001',
   bank_code: '024',
   iin: '508568',
   apbs: true,
   ach_credit: true,
   ach_debit: true,
   nach_debit: true
}

# constants

Razorpay::IFSC::Bank::PUNB
'PUNB'
```

Validate online and retrieve details from the server

If you call `code.valid?` before calling `code.get`, the validation will be performed offline.

```rb
# 1. using find
code = Razorpay::IFSC::IFSC.find 'KKBK0000261'

# 2. using new(...).get
code = Razorpay::IFSC::IFSC.new 'KKBK0000261'
code.get

# result
code.valid?
# => true
code.bank
# => "Kotak Mahindra Bank"
code.branch
# => "GURGAON"
code.address
# => "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,"
code.contact
# => "4131000"
code.city
# => "GURGAON"
code.district
# => "GURGAON"
code.state
# => "HARYANA"
```

#### Sublet Branches

You can use the `code.bank_name` method to get the bank name considering sublet branches.

```rb
code = Razorpay::IFSC::IFSC.find 'HDFC0CKUB01'
code.bank_name "Khamgaon Urban Co-operative Bank"
```

This works offline, and doesn't need a network call. This information is stored across 2 files:

1. `src/sublet.json` - Autogenerated from the [NPCI website](https://www.npci.org.in/national-automated-clearing-live-members-1)
2. `src/custom-sublets.json` - Maintained manually. Coverage is not 100%. PRs are welcome.

Sublet (or Sub-Member) branches are IFSC codes belonging to a large bank, but leased out to
smaller banks. In some cases, entire ranges are given to a specific bank.
For eg, all IFSCs starting with `YESB0TSS` belong to `Satara Shakari Bank`. These are
maintained manually in `custom-sublets.json`.

#### Error handling

```rb
# all these `Razorpay::IFSC::InvalidCodeError` for an invalid code
Razorpay::IFSC::IFSC.validate! '...'
Razorpay::IFSC::IFSC.find '...'
code = Razorpay::IFSC::IFSC.new '...'; code.get

# these raise `Razorpay::IFSC::ServerError` if there is an error
# communicating with the server
Razorpay::IFSC::IFSC.find '...'
code = Razorpay::IFSC::IFSC.new '...'; code.get
```

### Go

```go
package main

import (
	ifsc "github.com/razorpay/ifsc/src/go"
)

// todo: change funcs not required to lower case.

func main() {

	ifsc.Validate("KKBK0000261") // Returns true
	ifsc.Validate("BOTM0XEEMRA") // Returns false

	ifsc.ValidateBankCode("PUNB") // Returns true
	ifsc.ValidateBankCode("ABCD") // Returns false

	ifsc.GetBankName("PUNB") // Returns "Punjab National Bank", nil
	ifsc.GetBankName("ABCD") // Returns "", errors.New(invalid bank code)
	ifsc.GetBankName(ifsc.HDFC) // Returns "HDFC Bank", nil


	ifsc.GetBankDetails("PUNB")
	// or
	ifsc.GetBankDetails(ifsc.PUNB)

	/* Returns
		(*ifsc.Bank){
		Name	  : "Punjab National Bank",
		BankCode  : "024",
		Code	  : "PUNB",
		Type	  : "PSB",
		IFSC	  : "PUNB0244200",
		MICR      : "110024001",
		IIN       : "508568",
		APBS      : true,
		AchCredit : true,
		AchDebit  : true,
		NachDebit : true,
		Upi       : true
	}), nil
	*/

	ifsc.LookUP("KKBK0000261")

	/*
	Returns
	(*ifsc.IFSCResponse)({
	 Bank	  :  "Kotak Mahindra Bank",
	 Branch	  :  "GURGAON",
	 Address  :  "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
	 Contact  :  "4131000",
	 City	  :  "GURGAON",
	 District :  "GURGAON",
	 State	  :  "HARYANA",
	 IFSC	  :  "KKBK0000261",
	 BankCode :  "KKBK"
	}), nil
	 */
}

```

### Code Notes

Both the packages ship with a 300kb JSON file, that
includes the entire list of IFSC codes, in a compressed,
but human-readable format.

The Bank Code and Names list is maintained manually, but verified
with tests to be accurate as per the latest RBI publications. This
lets us add older Bank codes to the name list, without worrying
about them getting deleted in newer builds.

## API Development

The IFSC API is maintained in a separate repository at <https://github.com/razorpay/ifsc-api>.

## License

The code in this repository is licensed under the MIT License. License
text is available in the `LICENSE` file. The dataset itself
is under public domain.

[combined]: https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xlsx
[releases]: https://github.com/razorpay/ifsc/releases
[rtgs]: https://rbidocs.rbi.org.in/rdocs/RTGS/DOCs/RTGEB0815.xlsx
[ach]: https://www.npci.org.in/what-we-do/nach/live-members/live-banks
