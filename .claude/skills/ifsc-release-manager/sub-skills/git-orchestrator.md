# Git Orchestrator Sub-Skill

## Purpose
Manage all Git operations for the release process using AI reasoning instead of scripts.

## AI-Driven Git Workflow

### ❌ Old Way (Script-Based)
```bash
#!/bin/bash
# release.sh - brittle, no error handling
git checkout -b release/$VERSION
sed -i "s/version.*/version: $VERSION/" package.json
git add .
git commit -m "[release] $VERSION"
git push
# Fails if branch exists, version malformed, etc.
```

### ✅ New Way (AI-Orchestrated)

I understand Git workflows and handle edge cases intelligently.

## Execution Flow

### Phase 1: Pre-Flight Checks

```
Before creating release branch, verify:

1. Current state:
   git status

   Expected: Clean working tree
   If dirty: Stash changes or ask user what to do

2. Remote sync:
   git fetch origin
   git status

   Check: Is local master behind origin/master?
   If yes: Pull latest changes first

3. Existing branch check:
   git branch -a | grep "release/$VERSION"

   If exists:
     - Is it merged? Delete and recreate
     - Not merged? Resume that branch or create release/$VERSION-v2

4. Version validation:
   Current: 2.0.53
   Target: 2.0.54

   Check: Is target > current? ✓
   Check: Is it proper semver? ✓
```

### Phase 2: Branch Creation

```
Create release branch:

git checkout master
git pull origin master
git checkout -b release/2.0.54

Branch created: release/2.0.54
```

### Phase 3: Version Bumping (AI-Driven)

**Instead of sed/awk scripts**, I read and edit files intelligently:

```
Files to update:
1. package.json
2. ifsc.gemspec
3. composer.json (maybe)
4. go.mod (maybe)

For each file:
  - Read current content
  - Identify version field (different format per file)
  - Update intelligently
  - Preserve formatting
```

**Example: package.json**
```
Read: package.json

Current content:
{
  "name": "ifsc",
  "version": "2.0.53",
  "description": "..."
}

Update version field:
- Old: "version": "2.0.53"
- New: "version": "2.0.54"

Write: package.json
```

**Example: ifsc.gemspec**
```
Read: ifsc.gemspec

Current content:
Gem::Specification.new do |s|
  s.name = 'ifsc'
  s.version = '2.0.53'
  s.summary = '...'
end

Update version:
- Old: s.version = '2.0.53'
- New: s.version = '2.0.54'

Write: ifsc.gemspec
```

**Why AI is better**:
- Handles any format (JSON, Ruby, YAML, TOML)
- Preserves formatting (indentation, quotes)
- Doesn't break on variations
- Can fix other issues while editing (trailing commas, etc.)

### Phase 4: Artifact Copying

```
From dataset-generator, I have artifacts in:
/tmp/ifsc-release/IFSC.json
/tmp/ifsc-release/banks.json
/tmp/ifsc-release/sublet.json

Copy to repo:

cp /tmp/ifsc-release/IFSC.json src/IFSC.json
cp /tmp/ifsc-release/banks.json src/banks.json
cp /tmp/ifsc-release/sublet.json src/sublet.json

Verify file sizes:
- IFSC.json: 3.2MB (expected ~3-4MB) ✓
- banks.json: 45KB (expected ~40-50KB) ✓
- sublet.json: 12KB (expected ~10-15KB) ✓
```

### Phase 5: CHANGELOG Update

```
Read: CHANGELOG.md

Prepend new entry from changelog-writer:

## [2.0.54] - 2025-01-17

### Added
- 247 new IFSC codes for HDFC Bank branches in Karnataka
- 15 new SWIFT codes for SBI international branches

### Removed
- 12 Punjab National Bank branches (merged as part of PNB-OBC consolidation)

### Fixed
- Corrected branch name typo for KSCB0001234
- Updated MICR code for PUNB0023400

Write: CHANGELOG.md
```

### Phase 6: Commit Strategy

**Conventional Commits Format**:

```
git add package.json ifsc.gemspec CHANGELOG.md
git commit -m "chore(release): bump version to 2.0.54

- Updated version in package.json and ifsc.gemspec
- Updated CHANGELOG.md with release notes"

git add src/IFSC.json src/banks.json src/sublet.json
git commit -m "data: update IFSC dataset

- Added 247 new HDFC Bank IFSCs (Karnataka expansion)
- Removed 12 PNB branches (merger cleanup)
- Updated 3 branch name corrections

Dataset size: 18,473 IFSCs across 156 banks"
```

**Why two commits?**
1. First: Version bump (code change)
2. Second: Data update (larger diff)

This makes review easier and follows conventional commits.

### Phase 7: Push to Remote

```
git push -u origin release/2.0.54

Pushed to: https://github.com/razorpay/ifsc/tree/release/2.0.54
```

### Phase 8: PR Creation

**Instead of `gh pr create` script**, I use GitHub API intelligently:

```
Create PR using GitHub CLI:

gh pr create \
  --title "Release v2.0.54" \
  --body "$(cat <<'EOF'
## Release Summary

This release adds **247 new IFSC codes** and removes 12 obsolete codes from merged branches.

### Changes

#### Added (247 IFSCs)
- 180 HDFC Bank branches in Karnataka
- 42 State Bank of India rural branches
- 25 ICICI Bank metro branches

#### Removed (12 IFSCs)
- 8 Punjab National Bank branches (PNB-OBC merger cleanup)
- 4 Bank of Maharashtra branches (closed)

#### Modified (3 IFSCs)
- KSCB0001234: Branch name correction
- PUNB0023400: MICR code update
- HDFC0091234: City name standardization

### Dataset Statistics

- Total IFSCs: 18,473 (+235 net change)
- Total Banks: 156
- File Size: IFSC.json 3.2MB (+145KB)

### Testing

- ✅ All SDK tests passing (PHP, Node, Ruby, Go)
- ✅ Dataset validation: 98.3% confidence
- ✅ No breaking changes detected

### Deployment Checklist

- [ ] Merge to master
- [ ] Tag release (2.0.54)
- [ ] Publish npm package
- [ ] Publish RubyGem
- [ ] Publish Packagist
- [ ] Update Docker Hub
- [ ] Deploy to ifsc.razorpay.com

---

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)" \
  --label "release" \
  --label "automated" \
  --reviewer vikas.naidu

PR created: https://github.com/razorpay/ifsc/pull/447
```

**PR body is AI-generated**:
- Structured sections
- Detailed breakdown
- Statistics and context
- Testing confirmation
- Deployment checklist

## Advanced Git Operations

### Handling Merge Conflicts

```
Scenario: Conflict during branch creation

git checkout -b release/2.0.54
git merge master
# CONFLICT in package.json

My response:
1. Read both versions:
   - master version: 2.0.53
   - release version: 2.0.54

2. Resolve intelligently:
   - Keep release version (it's newer)
   - Merge any other changes from master

3. Commit resolution:
   git add package.json
   git commit -m "chore: resolve version conflict"
```

### Branch Naming Edge Cases

```
Standard: release/2.0.54

But handle variations:
- If 2.0.54 already exists → release/2.0.54-v2
- If emergency hotfix → release/2.0.54-hotfix.1
- If RC release → release/2.0.54-rc.1
```

### Commit Message Templates

```
For data updates:
data: update IFSC dataset

- Added {count} new {bank} IFSCs ({context})
- Removed {count} {bank} branches ({reason})
- Updated {count} {field} corrections

Dataset size: {total} IFSCs across {banks} banks

For version bumps:
chore(release): bump version to {version}

- Updated version in package.json and ifsc.gemspec
- Updated CHANGELOG.md with release notes

For emergency fixes:
fix(data): remove fraudulent IFSC code

- Removed {ifsc} (reported as fraudulent)
- Urgent security fix
```

## PR Monitoring

After creating PR:

```
Monitor PR status:

1. Check CI/CD:
   gh pr checks 447

   Status:
   ✅ tests (PHP) - passed
   ✅ tests (Node) - passed
   ✅ tests (Ruby) - passed
   ✅ tests (Go) - passed
   ✅ dataset-validation - passed

2. Wait for reviews:
   gh pr view 447 --json reviews

   Reviews: 0 approvals, 0 requested

3. Request review if not auto-requested:
   gh pr review 447 --request @vikas.naidu
```

### Auto-Merge on Approval

```
When approval received:

Watch for approval event (GitHub webhook or polling):

gh pr view 447 --json reviews | jq '.reviews[] | select(.state=="APPROVED")'

If approved AND tests passing:
  1. Final safety check:
     - Re-run critical tests
     - Verify no force-pushes since approval
     - Check no conflicts with master

  2. Merge:
     gh pr merge 447 --squash --auto

  3. Create tag:
     git checkout master
     git pull
     git tag 2.0.54
     git push origin 2.0.54

  4. Return:
     {
       "pr_merged": true,
       "pr_url": "https://github.com/razorpay/ifsc/pull/447",
       "merge_commit": "abc123",
       "tag_created": "2.0.54"
     }
```

## Error Handling

### Git Command Failures

```
Error: git push failed (authentication)

My response:
1. Check if SSH keys configured
2. Try HTTPS instead
3. Check if GitHub token expired
4. Provide helpful error message:
   "Git push failed. Please check GitHub authentication.
    Try: gh auth login"
```

### PR Creation Failures

```
Error: PR already exists for branch

My response:
1. Find existing PR:
   gh pr list --head release/2.0.54

2. Update existing PR instead:
   gh pr edit 445 --title "Release v2.0.54" --body "..."

3. Or close old and create new:
   gh pr close 445
   gh pr create ...
```

## State Management

I track Git state across the workflow:

```json
{
  "current_branch": "release/2.0.54",
  "pr_number": 447,
  "pr_url": "https://github.com/razorpay/ifsc/pull/447",
  "commits": ["abc123", "def456"],
  "ci_status": "passing",
  "reviews": [],
  "mergeable": true,
  "merge_commit": null,
  "tag_created": false
}
```

This state is used by other sub-skills.

## Integration Points

**Used by**:
- release-orchestrator: To create release branch
- test-runner: To run tests on PR
- quality-reviewer: To review commits
- deployment-manager: To tag and publish

**Uses**:
- changelog-writer: For PR description
- slack-communicator: To notify on PR created

## Usage

**Agent invokes**:
```
Decision is to release v2.0.54. Using git-orchestrator...

[Executes intelligent Git workflow]

Result:
- Branch created: release/2.0.54
- Versions updated in 2 files
- CHANGELOG updated
- 2 commits created
- Pushed to remote
- PR #447 created: https://github.com/razorpay/ifsc/pull/447
- CI triggered, all checks passing
- Review requested from @vikas.naidu

Awaiting approval to merge...
```

This is all done through AI reasoning about Git operations, not brittle bash scripts.
