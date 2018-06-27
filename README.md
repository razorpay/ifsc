# ifsc

This is part of the IFSC toolset released by Razorpay.
You can find more details about the entire release at
[ifsc.razorpay.com](https://ifsc.razorpay.com).

[![wercker status](https://app.wercker.com/status/bc9b22047e1b8eb55ce98ba451d7b504/s/master 'wercker status')](https://app.wercker.com/project/byKey/bc9b22047e1b8eb55ce98ba451d7b504) [![](https://images.microbadger.com/badges/version/razorpay/ifsc:1.1.5.svg)](https://microbadger.com/images/razorpay/ifsc:1.1.5) [![](https://images.microbadger.com/badges/image/razorpay/ifsc:1.1.5.svg)](https://microbadger.com/images/razorpay/ifsc:1.1.5) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

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

The latest [`build` pipeline][buildlist] on Wercker should result in a container
with the complete dataset as well.

The following files will be generated, with approx file
sizes given as well:

| File           | Size |
| -------------- | ---- |
| IFSC.csv       | 19M  |
| IFSC.yml       | 30M  |
| IFSC-list.json | 1.8M |
| IFSC-list.yml  | 1.8M |
| by-bank.tar.gz | 6.3M |

The files with the `-list` suffix only contain the list of IFSC codes.
This can be used for validation purposes.

The `data/by-bank` directory holds multiple JSON files corresponding
to each bank, for faster lookups.

## Installation

`gem install ifsc` - Ruby
`composer require razorpay/ifsc` - PHP
`npm install ifsc`

## API Documentation

This repository also hosts the source code for 3 modules: PHP/Node.js/Ruby as of now.
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

This works offline, and doesn't need a network call.

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

### Elixir

[![Hex pm](http://img.shields.io/hexpm/v/ifsc.svg?style=flat)](https://hex.pm/packages/ifsc)

Documentation: [https://hexdocs.pm/ifsc](https://hexdocs.pm/ifsc)

Online validation

```elixir
iex> IFSC.get("KKBK0000261")
{:ok,
 %Razorpay.IFSC{
   address: "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,",
   bank: "Kotak Mahindra Bank",
   bank_code: "KKBK",
   branch: "GURGAON",
   city: "GURGAON",
   contact: "4131000",
   district: "GURGAON",
   ifsc: "KKBK0000261",
   rtgs: true,
   state: "HARYANA"
 }}

iex> IFSC.get("foobar")
{:error, :invalid_ifsc}
```

Offline validation

```elixir
iex> IFSC.validate("KKBK0000261")
{:ok,
 %Razorpay.IFSC{
   address: nil,
   bank: "Kotak Mahindra Bank",
   bank_code: "KKBK",
   branch: nil,
   city: nil,
   contact: nil,
   district: nil,
   ifsc: "KKBK0000261",
   rtgs: nil,
   state: nil
 }}

iex> IFSC.validate("foobar")
{:error, :invalid_format}

iex> IFSC.validate("AAAA0000000")
{:error, :invalid_bank_code}

iex(> IFSC.validate("HDFC0000000")
{:error, :invalid_branch_code}
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
text is available in the `LICENSE.txt` file. The dataset itself
should be under public domain.

[rbi]: https://goo.gl/T9188H "goo.gl link because RBI doesn't allow you to link to their website"
[combined]: https://goo.gl/UryY8j "goo.gl link because RBI doesn't allow you to link to their website"
[releases]: https://github.com/razorpay/ifsc/releases
[buildlist]: https://app.wercker.com/captn3m0/ifsc/runs?view=runs&q=pipeline%3Abuild
