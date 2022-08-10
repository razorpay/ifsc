# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [UNRELEASED][unreleased]

## [2.0.10][2.0.10]

### Changed
- Metadata Updates

## [2.0.9][2.0.9]
### Changed
- Updates on list of UPI enabled banks
```diff
+ABSB Abhinav Sahakari Bank
+AJKB Akola Janata Commercial Co-operative Bank
+APRR A.P. Raja Rajeswari Mahila Co-operative Urban Bank
+BDBX Bellary District Co-operative Central Bank
+BHCX Bhuj Commercial Co-operative Bank
+BMCB Bombay Mercantile Co-operative Bank
-CGBX Chhattisgarh Rajya Gramin Bank
+CRGB Chhattisgarh Rajya Gramin Bank
+FINX Financial Co-operative Bank
+GUNX Guntur Co-operative Urban Bank
+JONX Jodhpur Nagrik Sahakari Bank
+MCUX Mahaveer Co-operative Urban Bank
-MMMX Mahila Nagrik Sahakari Bank Maryadit Mahasamund
-MSOX Manorama Co-operative Bank Solapur
+MSSX Merchants Souharda Sahakara Bank Niyamitha
+SWSX Shree Warana Sahakari Bank
+TKTX Kottakkal Co-operative Urban Bank
+UCBX Urban Co-operative Bank Bareilly
+VADX Valsad District Central Co-operative Bank
+VASJ Vasai Janata Sahakari Bank
-VJSX Vasai Janata Sahakari Bank
+COMX Co-operative Bank of Mehsana
```
- Metadata Updates
- Dependency Updates

## [2.0.8][2.0.8]
### Changed
- Metadata updates

## [2.0.7][2.0.7]
### Changed
- Dependency Updates
- Updated metadata
- All constant files are now automatically generated
- `IXXX` as custom bank code for "Indrayani Co-operative Bank"
- NPCI does not publish bank type any more, so these are now maintained in this repository as patches
- Minor bank name updates
- Support for Go 1.18
- New field added: `ISO3166` (`IN-XX`, as per the ISO-3166 specification).

## [2.0.6][2.0.6]
### Changed
- Updated Metadata

## [2.0.5][2.0.5]
### Changed
- Updated Metadata

## [2.0.4][2.0.4]
### Changed
- Update IFSC.json for the below 20 IFSC codes

## [2.0.3][2.0.3]
### Changed
- Adds back 20 IFSC codes removed due to a change on the RBI sheet structure in 2.0.2

## [2.0.2][2.0.2]
### Changed
- Metadata changes

## [2.0.1][2.0.1]
### Changed
- Metadata changes

## [2.0.0][2.0.0]
### Removed
- Removed support for Elixir package
### Changed
- Builds are now powered by GitHub Actions, instead of Wercker
### Added
- There is a supported golang SDK. See the README for instructions on how to use it.
- 1 New Bank: `"AHDC": "Ahmednagar District Central Co-operative Bank"`

## [1.6.1][1.6.1]
### Added
- Only metadata changes in this release.
- 2 new banks
    - RDCB: Rajnandgaon District Central Co Operative Bank
    - TMSB: The Malad Sahakari Bank Ltd
## [1.6.0][1.6.0]
- Support PHP8
- Fix for some invalid IFSCs being marked as valid. Ex: `PUNB0000000` (#229)
- Update list of UPI enabled banks
- Fix all exported datasets to include correct bank name.
- Only use validated MICR codes

## [1.5.13][1.5.13]
- [upi] Vijaya Bank and Dena Gujarat Gramin Bank are no more
- [upi] 7 new banks now support UPI
- Metadata update for new release
- Sanitizes most text fields to remove special characters that show up from encoding errors. Fixes #29, #32
- Start parsing contact numbers from NEFT sheet as well. Published in E.164 wherever possible
- Changes some empty fields to null instead of "NA"

## [1.5.12][1.5.12]

- Only metadata changes in this release.
- Data corrections to account for broken alignment in RBI's RTGS spreadsheet
- Improved support for Contact details that are sourced from RTGS dataset. CONTACT details are returned in E.164 format

## [1.5.11][1.5.11]
### Changed
- Metadata updates

## [1.5.10][1.5.10]
### Changed
- 2 new banks:
  - ARBL: Arvind Sahakari Bank
  - TNCB: Nawanagar Co-operative Bank
- Name for STCB changed from "State Bank of Mauritius" to "SBM Bank"
- Temporary code added for "Sri Rama Co-operative Bank": `SXXX`
- Support for ICLL (Indian Clearing Corporation) added. `ICLL0000001` is the branch.

## [1.5.9][1.5.9]
### Added
- Initial support for SWIFT mappings. Only SBI and PNB branches are currently supported, and accuracy is not guaranteed. Feedback is welcome.

### Changed
- Metadata changes

## [1.5.8][1.5.8]
### Changed
- Only metadata changes in this release
- New Banks:
    - `AKKB`: Akkamahadevi Mahila Sahakari Bank Niyamit
    - `MUCG`: Merchants Urban Coop Bank
    - `SBCR`: Shree Basaveshwar Urban Coop Bank
    - `SBPS`: Sri Basaveshwar Pattana Sahakari Bank

## [1.5.7][1.5.7]
### Changed
- 1 new bank - TPSC ("Punjab State Cooperative Bank")
- 15 new banks in UPI
- Patches `PUNB0641100` to give correct response.
- [php] Returns the BANKCODE from the API instead of using the first 4 characters.
- The large number of additions to Union Bank/Punjab National bank is due to the upcoming mergers. The existing IFSC for the merged banks are not impacted.

## [1.5.6][1.5.6]
### Changed
- Metadata updates

## 1.5.5

### Changed

- Metadata updates
- New Banks:
	- HUCH : Hanamasagar Urban Co-operative Bank
	- MDBK : Model Co-operative Bank
	- SDTC : Shri D T Patil Co-operative Bank

## 1.5.4

### Changed

- Metadata updates
- Optimized memory consumption in php tests.
- New Banks:
	- KBKB : Kookmin Bank
	- SUSB : Suco Souharda Sahakari Bank

## 1.5.3

### Changed

- Metadata updates

## 1.5.2

### Changed

- Metadata updates

## 1.5.1

### Changed

-   Metadata updates
-   Madhya Bihar Gramin Bank and Bihar Gramin Bank merged to form
    Dakshin Bihar Gramin Bank.

### Fixed

-   Fixes a critical bug in the node.js SDK which reported some valid IFSCs as invalid.
-   `CENTRE` and `CITY` fields should now be present across all rows. If we don't have a value, it will be set to `NA`.

### Added

-   New `DatasetTest` to ensure fields don't get missed out in the future

## 1.5.0

### Added

-   Adds bank constants in nodejs
-   Adds offline bank details fetch method in ruby.
-   Adds support for `upi: true` flag in `banks.json`
-   Adds `UPI: true/false` flag in `IFSC.csv` and `by-banks` JSON files

### Changed

-   Improves coverage of bank constants in ruby.

## [1.4.10][1.4.10] - 2020-01-02

-   Metadata Updates
-   Support for patches that can override data for specific IFSC codes
-   NEFT Block for certain banks:
    -   Bank Of Ceylon
    -   Krung Thai Bank
    -   Kaveri Grameena Bank
    -   Kerala Gramin Bank
    -   Pragathi Krishna Gramin Bank
    -   Sbm Bank Mauritius Ltd

## [1.4.9][1.4.8] - 2019-11-07

-   Metadata Updates

## [1.4.7][1.4.7] - 2019-10-14

-   Minor Metadata updates

## [1.4.6][1.4.6] - 2019-09-05

-   Metadata updates
-   Catholic Syrian Bank is renamed to CSB Bank

## [1.4.5][1.4.5] - 2019-07-15

-   Regular Metadata Updates

## [1.4.4][1.4.4] - 2019-06-17

### Changed

-   Regular Metadata Updates

### Added

-   Adds support for custom sublets. (#114)

## [1.4.2][1.4.2] - 2019-05-16

### Changed

-   Regular Metadata Updates

## [1.4.1][1.4.1] - 2019-04-25

### Fixed

-   Parsing of empty/NA MICR/IINs/IFSCs in NPCI ACH List. #100

### Changed

-   Updated list of sublets to remove all exceptions

## [1.4.0][1.4.0] - 2019-04-19

### Added

-   Regular Metadata Changes. See [Release Page][1.4.0] for a list.
-   One new Bank: `AJAR`
-   Adds NPCI-only IFSCs from https://www.npci.org.in/national-automated-clearing-live-members-1. See #100 and #109 for some more details.
-   A `NEFT=true|false` flag is added on all datasets, which will get added to the API with this release.
-   A `IMPS=true|false` flag is added, which is currently in alpha. There is not enough clarity around this yet (See #109), so please don't use this in production yet. This can be removed at any time. Feedback on the correctness of this flag is welcome.
-   A MICR is now available for all rows. This will also reflect on the API.

### Changed

-   Parser speed and general improvements. Builds only take 3 minutes, and caching related stuff is removed.
-   The parser converts XLS/XLSX files to CSV before parsing, which results in cleaner data in some cases.

### Removed

-   Removes some data formats (YAML/Large JSON) for cleaner code. If you were using them, please let create an issue.

[unreleased]: https://github.com/razorpay/ifsc/compare/2.0.10...HEAD
[2.0.10]: https://github.com/razorpay/ifsc/releases/tag/2.0.10
[2.0.9]: https://github.com/razorpay/ifsc/releases/tag/2.0.9
[2.0.8]: https://github.com/razorpay/ifsc/releases/tag/2.0.8
[2.0.7]: https://github.com/razorpay/ifsc/releases/tag/2.0.7
[2.0.6]: https://github.com/razorpay/ifsc/releases/tag/2.0.6
[2.0.5]: https://github.com/razorpay/ifsc/releases/tag/2.0.5
[2.0.4]: https://github.com/razorpay/ifsc/releases/tag/2.0.4
[2.0.3]: https://github.com/razorpay/ifsc/releases/tag/2.0.3
[2.0.2]: https://github.com/razorpay/ifsc/releases/tag/2.0.2
[2.0.1]: https://github.com/razorpay/ifsc/releases/tag/2.0.1
[2.0.0]: https://github.com/razorpay/ifsc/releases/tag/2.0.0
[1.6.1]: https://github.com/razorpay/ifsc/releases/tag/1.6.1
[1.5.13]: https://github.com/razorpay/ifsc/releases/tag/1.5.13
[1.5.12]: https://github.com/razorpay/ifsc/releases/tag/1.5.12
[1.5.11]: https://github.com/razorpay/ifsc/releases/tag/1.5.11
[1.5.10]: https://github.com/razorpay/ifsc/releases/tag/1.5.10
[1.5.9]: https://github.com/razorpay/ifsc/releases/tag/1.5.9
[1.5.8]: https://github.com/razorpay/ifsc/releases/tag/1.5.8
[1.5.7]: https://github.com/razorpay/ifsc/releases/tag/1.5.7
[1.5.6]: https://github.com/razorpay/ifsc/releases/tag/1.5.6
[1.4.10]: https://github.com/razorpay/ifsc/releases/tag/1.4.10
[1.4.9]: https://github.com/razorpay/ifsc/releases/tag/1.4.9
[1.4.8]: https://github.com/razorpay/ifsc/releases/tag/1.4.8
[1.4.7]: https://github.com/razorpay/ifsc/releases/tag/1.4.7
[1.4.6]: https://github.com/razorpay/ifsc/releases/tag/1.4.6
[1.4.5]: https://github.com/razorpay/ifsc/releases/tag/1.4.5
[1.4.4]: https://github.com/razorpay/ifsc/releases/tag/1.4.4
[1.4.3]: https://github.com/razorpay/ifsc/releases/tag/1.4.3
[1.4.2]: https://github.com/razorpay/ifsc/releases/tag/1.4.2
[1.4.1]: https://github.com/razorpay/ifsc/releases/tag/1.4.1
[1.3.4]: https://github.com/razorpay/ifsc/releases/tag/1.3.4
[1.3.3]: https://github.com/razorpay/ifsc/releases/tag/1.3.3
