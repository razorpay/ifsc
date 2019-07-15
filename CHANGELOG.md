# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[unreleased]: https://github.com/razorpay/ifsc/compare/1.4.5...HEAD
[1.4.5]: https://github.com/razorpay/ifsc/releases/tag/1.4.5
[1.4.4]: https://github.com/razorpay/ifsc/releases/tag/1.4.4
[1.4.3]: https://github.com/razorpay/ifsc/releases/tag/1.4.3
[1.4.2]: https://github.com/razorpay/ifsc/releases/tag/1.4.2
[1.4.1]: https://github.com/razorpay/ifsc/releases/tag/1.4.1
[1.3.4]: https://github.com/razorpay/ifsc/releases/tag/1.3.4
[1.3.3]: https://github.com/razorpay/ifsc/releases/tag/1.3.3
