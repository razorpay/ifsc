# Deployment Manager Sub-Skill (Updated)

## Purpose
Manage the automated release process after PR is merged to master, including GitHub Actions workflows for NPM and RubyGems publishing.

## When to Use
- After release PR is merged to master
- When creating manual releases
- For troubleshooting failed deployments
- To verify publish workflows

## Deployment Architecture

### Automated Workflow (Current State)

```
PR Merged to Master
        ↓
    [Tagged?]
        ↓
   ┌────┴────┐
   NO        YES
   ↓          ↓
Skip     Trigger Workflows
            ↓
    ┌───────┴────────┐
    ↓                ↓
NPM Publish    RubyGems Publish
(parallel)        (parallel)
```

**Key Point**: Publishing is **tag-triggered**, not automatic on merge.

## Publishing Workflows

### 1. NPM Package Publication
**Workflow**: `.github/workflows/NPM_Publish.yml`

**Trigger**: Git tag push (e.g., `v2.0.54`)

**Steps**:
```yaml
on:
  push:
    tags:
      - 'v*'

name: Publish to NPM

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-node@v2
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'

      - name: Publish to NPM
        run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

**Published Package**: `ifsc` on npmjs.com
**Version**: Reads from `package.json`
**Contents**: src/node/, data/, README.md, package.json

### 2. RubyGems Publication
**Workflow**: `.github/workflows/Ruby_Gem_Publish.yml`

**Trigger**: Git tag push (same as NPM)

**Steps**:
```yaml
on:
  push:
    tags:
      - 'v*'

name: Publish to RubyGems

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.1

      - name: Build gem
        run: gem build ifsc.gemspec

      - name: Publish to RubyGems
        run: gem push ifsc-*.gem
        env:
          GEM_HOST_API_KEY: ${{ secrets.RUBYGEMS_API_KEY }}
```

**Published Gem**: `ifsc` on rubygems.org
**Version**: Reads from `ifsc.gemspec`
**Contents**: src/ruby/, data/, README.md, gemspec

## Release Creation Process

### Manual Release Flow (Current)

**Step 1: Merge PR**
```bash
# PR #450 merged to master
# Commit: [release] 2.0.54
```

**Step 2: Create Git Tag**
```bash
git tag v2.0.54
git push origin v2.0.54
```

**Step 3: Workflows Triggered**
- NPM_Publish.yml runs
- Ruby_Gem_Publish.yml runs

**Step 4: Create GitHub Release** (Manual)
```
1. Go to https://github.com/razorpay/ifsc/releases/new
2. Select tag: v2.0.54
3. Title: Release 2.0.54
4. Description: Copy from release.md
5. Attach: ifsc-2.0.54.tar.gz
6. Publish release
```

### Automated Release Flow (Proposed for Claude Agent)

```bash
# After PR is merged
git checkout master
git pull origin master

# Create tag
VERSION=$(node -p "require('./package.json').version")
git tag "v${VERSION}"
git push origin "v${VERSION}"

# Create GitHub release with tarball
gh release create "v${VERSION}" \
  --title "Release ${VERSION}" \
  --notes-file scraper/scripts/release.md \
  releases/ifsc-${VERSION}.tar.gz
```

**Why Automated?**
- Eliminates manual steps
- Ensures consistency
- Faster releases (minutes vs hours)
- No human error

## Deployment Validation

### Verify NPM Publication
```bash
# Check if version is published
npm view ifsc version
# Should output: 2.0.54

# Check package contents
npm view ifsc dist
# Should show: tarball URL, integrity hash
```

### Verify RubyGems Publication
```bash
# Check if gem is published
gem list -r ifsc
# Should output: ifsc (2.0.54)

# Download and inspect
gem fetch ifsc
tar -xzf ifsc-2.0.54.gem
```

### Verify GitHub Release
```bash
# List releases
gh release list

# View specific release
gh release view v2.0.54
```

## Error Handling

### NPM Publish Failure
**Symptoms**:
```
npm ERR! code E403
npm ERR! 403 Forbidden - PUT https://registry.npmjs.org/ifsc - You cannot publish over the previously published versions
```

**Causes**:
- Version in package.json not bumped
- Tag already exists
- NPM_TOKEN expired

**Fixes**:
```bash
# Fix version
npm version patch  # 2.0.54 → 2.0.55

# Delete tag and recreate
git tag -d v2.0.54
git push origin :refs/tags/v2.0.54
git tag v2.0.55
git push origin v2.0.55
```

### RubyGems Publish Failure
**Symptoms**:
```
ERROR:  While executing gem ... (Gem::InvalidSpecificationException)
    "FIXME" or "TODO" is not a valid version
```

**Causes**:
- Invalid version in gemspec
- Missing required gemspec fields
- RUBYGEMS_API_KEY expired

**Fixes**:
```ruby
# Fix gemspec version
Gem::Specification.new do |s|
  s.version = '2.0.54'  # Ensure this matches package.json
end
```

### GitHub Release Failure
**Symptoms**:
```
gh: release not found
```

**Causes**:
- Tag doesn't exist
- Tag not pushed to remote
- Insufficient permissions

**Fixes**:
```bash
# Verify tag exists
git tag -l | grep v2.0.54

# Push tag if missing
git push origin v2.0.54

# Retry release creation
gh release create v2.0.54 --notes-file release.md
```

## Rollback Procedure

### Unpublish NPM Package
```bash
# Unpublish specific version (within 72 hours)
npm unpublish ifsc@2.0.54

# Deprecate version (after 72 hours)
npm deprecate ifsc@2.0.54 "Buggy release, use 2.0.55 instead"
```

### Yank RubyGem
```bash
# Yank gem (makes it unavailable)
gem yank ifsc -v 2.0.54
```

### Delete GitHub Release
```bash
# Delete release
gh release delete v2.0.54 --yes

# Delete tag
git tag -d v2.0.54
git push origin :refs/tags/v2.0.54
```

## Secrets Management

**Required Secrets** (stored in GitHub Settings):

1. **NPM_TOKEN**
   - Obtained from: npmjs.com → Access Tokens
   - Permissions: Automation (publish only)
   - Regenerate: Every 90 days

2. **RUBYGEMS_API_KEY**
   - Obtained from: rubygems.org → API Keys
   - Scope: Push rubygems
   - Regenerate: Annually or on compromise

**Verification**:
```bash
# Test NPM token
curl -H "Authorization: Bearer $NPM_TOKEN" \
  https://registry.npmjs.org/-/whoami

# Test RubyGems key
curl -H "Authorization: $RUBYGEMS_API_KEY" \
  https://rubygems.org/api/v1/api_key.yaml
```

## Deployment Monitoring

### Check Workflow Status
```bash
# View recent workflow runs
gh run list --workflow=NPM_Publish.yml

# View specific run details
gh run view 123456789

# Download logs if failed
gh run download 123456789
```

### Package Download Stats
```bash
# NPM downloads (last 7 days)
npm view ifsc

# RubyGems downloads (all time)
gem info ifsc --remote
```

## Automated vs Manual Steps

### Currently Automated
- ✅ NPM publish (on tag push)
- ✅ RubyGems publish (on tag push)
- ✅ Test runs (on every push)
- ✅ Scraper runs (on workflow_dispatch)

### Currently Manual
- ❌ Tag creation
- ❌ GitHub release creation
- ❌ Tarball attachment
- ❌ Release notes copy

### Proposed Automation (for Claude Agent)
```bash
#!/bin/bash
# deploy.sh - Full automated deployment

VERSION=$(node -p "require('./package.json').version")

# Step 1: Create tag
git tag "v${VERSION}"
git push origin "v${VERSION}"

# Step 2: Wait for publish workflows
echo "Waiting for NPM and RubyGems publish..."
sleep 60

# Step 3: Verify publications
npm view ifsc@${VERSION} || exit 1
gem list -r ifsc | grep ${VERSION} || exit 1

# Step 4: Create GitHub release
gh release create "v${VERSION}" \
  --title "Release ${VERSION}" \
  --notes-file scraper/scripts/release.md \
  releases/ifsc-${VERSION}.tar.gz

echo "✅ Release ${VERSION} deployed successfully"
```

## Success Criteria

- ✅ NPM package published
- ✅ RubyGems gem published
- ✅ GitHub release created
- ✅ Tarball attached to release
- ✅ Release notes populated
- ✅ All workflows passed

## Integration with Workflow

**Deployment Checkpoint** (final step):
```
1. Create release PR ✅
2. Quality review ✅
3. Merge PR ✅
4. Create tag
5. Wait for publish workflows
6. Create GitHub release
7. Verify deployments ← HERE
8. Notify team
```

## Performance Targets

- Tag creation: <5 seconds
- NPM publish: <30 seconds
- RubyGems publish: <45 seconds
- GitHub release: <10 seconds
- Total deployment: <2 minutes

## Related Files

- `.github/workflows/NPM_Publish.yml` - NPM publish workflow
- `.github/workflows/Ruby_Gem_Publish.yml` - RubyGems publish workflow
- `package.json` - NPM package version
- `ifsc.gemspec` - RubyGems version
- `releases/` - Tarball storage directory

## Future Enhancements

### Multi-Platform Publishing
```
Add support for:
- Python PyPI (pip install ifsc)
- Go pkg (go get github.com/razorpay/ifsc)
- Composer (PHP packagist)
```

### Deployment Notifications
```
→ Slack: "🚀 IFSC v2.0.54 deployed to NPM and RubyGems"
→ Email: Notify maintainers
→ GitHub: Auto-close related issues
```

### Canary Releases
```
→ Publish to NPM with 'beta' tag first
→ Monitor for errors (24 hours)
→ Promote to 'latest' tag if stable
```

### Rollback Automation
```bash
# Detect failed release
if deployment_failed():
    rollback_to_previous_version()
    notify_team("Rollback triggered")
```
