## Check whether a new release is required
1. Whenever a change in detected on the RBI website (https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009), an automated email from the "RBI Updates" is sent on the "#tech_ifsc" Slack channel.
2. Open the website it has detected change and compare the RBI release date with the `RBI Update Date` of the latest release. If the release date and update date differ, make a new release.

## Publish a new release of IFSC repository (https://github.com/razorpay/ifsc)
1. Clone the IFSC repository (https://github.com/razorpay/ifsc) locally.
2. Create a new `release/{version}` branch. The branch name must be `release/x.y.z`. Start with a patch version bump unless you are making code level changes, in which case you can use a minor/major version bump.
3. Grep for the current version in the codebase. Bump the versions in `package.json`, `ifsc.gemspec`. Do not change it in `package-lock.json`.
4. Update `CHANGELOG.md` with the appropriate description.
5. Commit this as `[release] x.y.z`. Push these changes to the IFSC repository (https://github.com/razorpay/ifsc).
6. Github Actions are run automatically and under the "Scraper" Action, download the artifacts produced during runtime (`release-artifact` and `release-notes.md`) from the build pipeline. Make sure all the tests (Github Actions) are passing successfully.
7. Extract the artifacts and copy the files `banks.json`, `IFSC.json` and `sublet.json` into the `ifsc/src/` directory.
8. Again, commit these changes and push it into the IFSC repository and check the tests. If something is failing, you might need to edit the constants or `banknames.json` file.
9. Create a new pull request with this branch. Copy the `release-notes.md` file and use that as description for the PR. Review and merge the PR. Tag the merge commit (don't use a prefix, just `X.Y.Z`).
10. Create a release on GitHub (https://github.com/razorpay/ifsc/releases/new).
    - Create a new tag.
    - Use `release-notes.md` file as the template.
    - Replace `TODO` as applicable for the release.
    - Upload the `release-artifact` files as part of the release.
11. On making a new release, Github Actions for SDK update are automatically triggered. After all the actions run successfully, the `npm`, `gem` and `php` packages are updated to the latest versions, which can be checked by the badges in the `README.md` file.

## Publish a new release of IFSC-API repository (https://github.com/razorpay/ifsc-api)
1. Ensure that a new gem release has been made for the latest release (https://rubygems.org/gems/ifsc).
2. Clone the IFSC-API repository (https://github.com/razorpay/ifsc-api) locally.
3. Create a new `{version}` branch. The branch name must be `x.y.z`. Start with a patch version bump unless you are making code level changes, in which case you can use a minor/major version bump.
4. Go to the latest IFSC release (https://github.com/razorpay/ifsc/releases).
5. Download and extract the `by-bank.tar.gz` file from the release assets and copy the files into the `ifsc-api/data` directory.
6. Run a dependency update (`bundle update && bundle update --gemfile Gemfile.build`).
7. Dependency update updates `Redis` package, which could break workflows. In such a case, manually edit the package version to its previous one.
8. Check whether the ifsc gem is updated to the latest version (`grep ifsc Gemfile.lock`).
9. Commit this as `[release] x.y.z`. Push these changes to the IFSC-API repository (https://github.com/razorpay/ifsc-api).
10. Create a new pull request with this branch. Review and merge the PR. Tag the merge commit (don't use a prefix, just `X.Y.Z`).
11. Create a release on GitHub (https://github.com/razorpay/ifsc-api/releases/new).
    - Create a new tag.
    - Add a description as applicable for the release. 
12. Check whether a new tag has been created on docker hub (https://hub.docker.com/r/razorpay/ifsc/tags).

## Deploy the new IFSC release on X Dashboard / IFSC-API repository SDK update

1. Run `composer update razorpay/ifsc --ignore-platform-req=ext-grpc`.
```
composer update razorpay/ifsc --ignore-platform-req=ext-grpc
```
2. You will get to see something like this,
```
Your GitHub credentials are required to fetch private repository metadata (git@github.com:razorpay/hodor.git)
When working with _public_ GitHub repositories only, head to https://github.com/settings/tokens/new?scopes=&description=Composer+on+{...} to retrieve a token.
This token will have read-only permission for public information only.
When you need to access _private_ GitHub repositories as well, go to https://github.com/settings/tokens/new?scopes=repo&description=Composer+on+{...} 
Note that such tokens have broad read/write permissions on your behalf, even if not needed by Composer.
Tokens will be stored in plain text in "/Users/{...}/.composer/auth.json" for future use by Composer.
For additional information, check https://getcomposer.org/doc/articles/authentication-for-private-packages.md#github-oauth
```
Go to the private repository token generation link and generate token.  

3. Paste the token on terminal and press enter. You will get to see something like this,
```
Token stored successfully.
GitHub API token requires SSO authorization. Authorize this token at https://github.com/orgs/razorpay/sso?authorization_request={...}

After authorizing your token, confirm that you would like to retry the request
```
Go to the link to authorise.  

4. Post authorising, just press `y` or write `yes` on terminal and press enter. It will update IFSC repository in API.
5. Commit the `composer.lock` file and raise PR. Fix any tests that fail due to the IFSC codes removed / added (need to let CI run and check required suites for failures, most of the ifsc tests are required only).
6. Merge and deploy.

## Deploy the new Stage IFSC release on the Stage API website (http://ifsc.stage.razorpay.in/)  
1. Go to Spinnaker (https://deploy.razorpay.com/#/applications/stage-ifsc/executions).
2. Run the "stage-ifsc-infra" pipeline, by clicking on "Start Manual Execution" against it. In the parameters section, enter the latest tag number as "2.0.14" (OR) simply "latest" against the "Image tag" parameter and enter the latest kube-manifest commit ID against the "kube_manifests_commit" parameter. Take the latest commit ID from kube-manifest repository (https://github.com/razorpay/kube-manifests).
3. Open the "stage-ifsc" endpoint (http://ifsc.stage.razorpay.in/) and test the API by running deleted and newly added IFSC codes in the latest release.

## Deploy the new Production IFSC release on the Production API website (https://ifsc.razorpay.com/)  
1. Go to Spinnaker (https://deploy.razorpay.com/#/applications/stage-ifsc/executions).
2. Run the "prod deploy" pipeline, by clicking on "Start Manual Execution" against it. In the parameters section, enter the latest tag number as "2.0.14" (OR) simply "latest" against the "Image tag" parameter.
3. Open the API (https://ifsc.razorpay.com/)  and test the website by running deleted and newly added IFSC codes in the latest release.