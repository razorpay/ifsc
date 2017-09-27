# Contribution Guidelines

Rough guidelines:

1. Please ensure that the build passes.
2. Packages in other languages are welcome.

## Bank Names Guidelines

The `banknames.json` file is committed to the repo
and is used to maintain a list of human-readable
bank names in India. If you are touching that
file, here are a few guidelines:

1. Do not include `ltd`, `Ltd` at the end.
2. Ensure that the case is consistent with the official name.
3. Do not prefix the bank name with "The".
4. The canonical way to spell Coop is `Co-operative`.
5. Do not include a city name in the bank name, unless it is part of the IFSC code.
6. Include the city name in brackets at the end if it is necessary for disambiguation.
7. Try not to leave any unexpanded abbreviations in the name
8. Also ensure that the 4 character code is committed to `Bank.php`
9. No period after `Co-operative`

## Code Guidelines

We use `prettier` for the javascript and `rubocop` for the Ruby code for style fixes


## Releases

Releases are partially automated. To draft a new release, follow these steps:

1. Create a new release/{version} branch
2. Copy the artifacts from the build pipeline and commit it (`IFSC.json` and `sublet.json`)
3. Make sure that the tests are passing
4. Download the `release.md` file from the release pipeline
5. Bump the versions in the following places: `package.json`, `ifsc.gemspec` and commit it
6. Merge the PR
7. Tag the merge commit (don't use a prefix, just `X.Y.Z`)
8. Push the tag to GitHub.
9. Create a release on GitHub for the tag. Use `release.md` from Step 4 as the template. Replace `TODO` as applicable for the release.
