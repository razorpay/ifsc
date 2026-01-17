# IFSC Release Manager - Test Suite

Automated tests to validate the IFSC Release Manager skill functionality.

## Running Tests

### Quick Test
```bash
cd /Users/vikas.naidu/code/rzp/ifsc
./.claude/skills/ifsc-release-manager/tests/skill-test.sh
```

### What Gets Tested

The test suite validates 12 critical areas:

1. **Skill File Structure** ✓
   - Main skill file exists
   - All 18 sub-skills present
   - Context files available

2. **Data Source Files** ✓
   - RBI NEFT file (68774.xlsx)
   - RBI RTGS file (RTGEB0815.xlsx)
   - CSV conversion files (5 files)

3. **Python Excel Converter** ✓
   - convert_excel.py exists
   - pandas and openpyxl dependencies

4. **Generated Dataset Files** ✓
   - IFSC.csv (34 MB, 177K+ entries)
   - IFSC.json (1 MB, compact format)
   - IFSC-list.json (2.4 MB, validation list)
   - banks.json (293 KB, 1,346 banks)
   - sublet.json (28 KB, sublet mappings)
   - by-bank/*.json (1,300+ files)

5. **IFSC Format Validation** ✓
   - Count within range (170K-180K)
   - Format: `[A-Z]{4}0[A-Z0-9]{6}`
   - Sample validation (1000 entries)

6. **Bank Count Validation** ✓
   - Range: 1,300-1,400 banks
   - All bank codes valid

7. **Patch Files** ✓
   - IFSC patches: 20+ YAML files
   - Bank patches: 10+ YAML files

8. **Git Repository State** ✓
   - Version readable from package.json
   - Uncommitted changes detection

9. **Release Decision Logic** ✓
   - < 50 changes → skip
   - 50-500 changes → patch
   - > 500 changes → minor

10. **Export Format Validation** ✓
    - JSON syntax valid
    - All formats parseable

11. **Checksum Comparison** ✓
    - src/IFSC.json vs generated
    - Detects data changes

12. **Ruby Scraper Environment** ✓
    - Ruby installed
    - Bundler available
    - Gemfile present

## Test Output

### Success
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Test Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Tests Run:    65
Tests Passed: 65
Tests Failed: 0

✓ All tests passed!

IFSC Release Manager skill is operational and ready.
```

### Failure
```
Tests Run:    65
Tests Passed: 62
Tests Failed: 3

✗ Some tests failed.

Please review failures above and fix issues.
```

## Running Specific Test Sections

You can comment out sections in `skill-test.sh` to run specific tests:

```bash
# Comment out tests you don't need
# TEST 1: Skill File Structure
# TEST 2: Data Source Files
# ... etc
```

## When to Run Tests

### Regular Schedule
- **Weekly**: Validate skill files are intact
- **Before releases**: Ensure all components working
- **After updates**: Verify changes didn't break anything

### Manual Triggers
- After modifying sub-skills
- After updating domain knowledge
- When troubleshooting issues
- Before creating PRs with skill changes

## Interpreting Results

### ✓ PASS (Green)
Test passed successfully. Component is working as expected.

### ✗ FAIL (Red)
Test failed. Fix the issue before proceeding.
**Example:** Missing file, invalid format, incorrect count.

### ⚠ WARN (Yellow)
Non-critical issue. Skill can work but some data may be missing.
**Example:** Data files not generated (run scraper), CSV files missing.

### ℹ INFO (Blue)
Informational message. No action needed.
**Example:** Current version number, file sizes, change detected.

## Exit Codes

- **0**: All tests passed
- **1**: One or more tests failed

Use in CI/CD:
```bash
if ./.claude/skills/ifsc-release-manager/tests/skill-test.sh; then
    echo "Tests passed, proceeding with release"
else
    echo "Tests failed, aborting"
    exit 1
fi
```

## Troubleshooting

### "Data directory not found"
**Solution:** Run the scraper first to generate data:
```bash
cd scraper/scripts
bash bootstrap.sh
```

### "Python dependencies missing"
**Solution:** Install required packages:
```bash
pip install pandas openpyxl
```

### "Ruby not installed"
**Solution:** Install Ruby 3.1+:
```bash
# macOS
brew install ruby

# Ubuntu
sudo apt-get install ruby-full
```

### "Bank count out of range"
**Possible causes:**
- NACH data outdated
- Scraper parsing errors
- Bank mergers/closures

**Solution:** Re-run NACH scraper or check NPCI website.

## Test Maintenance

Update tests when:
- Adding new sub-skills
- Changing file formats
- Modifying expected data ranges
- Adding new validation rules

Edit `skill-test.sh` to add new test cases.

## Integration with CI/CD

Add to GitHub Actions:
```yaml
- name: Test IFSC Release Manager Skill
  run: ./.claude/skills/ifsc-release-manager/tests/skill-test.sh
```

Add to pre-commit hook:
```bash
# .git/hooks/pre-commit
./.claude/skills/ifsc-release-manager/tests/skill-test.sh
```

## Manual Test Cases

Beyond automated tests, manually verify:

1. **Skill invocation**: `claude skill ifsc-release-manager`
2. **Sub-skill execution**: Test each sub-skill individually
3. **Error handling**: Introduce errors, verify graceful failures
4. **Release workflow**: End-to-end test with mock data

## Questions or Issues?

- Check test output for specific failures
- Review sub-skill documentation
- Examine domain knowledge context
- Run `bash -x skill-test.sh` for debug mode
