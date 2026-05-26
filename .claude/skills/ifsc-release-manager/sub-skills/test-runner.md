# Test Runner Sub-Skill

## Purpose
Run comprehensive test suites across 4 languages (PHP, Node.js, Ruby, Go) to validate IFSC dataset integrity and library functionality.

## When to Use
- After dataset generation (before release)
- During development (pre-commit)
- In CI/CD pipeline (every push)
- Before creating release tags

## Test Categories

### 1. Dataset Validation Tests
**Purpose**: Verify data integrity

**Checks**:
- ✅ All IFSCs are exactly 11 characters
- ✅ Bank codes are 4 uppercase letters
- ✅ State names match ISO3166 map
- ✅ MICR codes are 9 digits (when present)
- ✅ Contact numbers are valid format
- ✅ No duplicate IFSCs
- ✅ Required fields not null (BANK, IFSC, BRANCH)

### 2. Library Functionality Tests
**Purpose**: Ensure SDK works correctly

**Checks**:
- ✅ IFSC validation logic
- ✅ Bank name lookup
- ✅ Sublet detection
- ✅ API client functionality
- ✅ Code coverage >80%

### 3. Regression Tests
**Purpose**: Prevent known issues from reoccurring

**Checks**:
- ✅ Specific IFSC codes still valid
- ✅ Edge cases handled (Chandigarh, Hyderabad)
- ✅ Special characters in addresses
- ✅ Merged bank IFSCs

## Test Suites by Language

### PHP Tests
**Location**: `tests/php/`

**Run Command**:
```bash
composer install --no-interaction
phpunit --migrate-configuration -d memory_limit=-1
```

**Test Files**:
1. **ValidatorTest.php** - IFSC validation logic
   ```php
   testValidIFSC('SBIN0000001')  // → true
   testInvalidIFSC('INVALID')    // → false
   ```

2. **BankNameTest.php** - Bank name lookup
   ```php
   testGetBankName('SBIN') // → "State Bank of India"
   ```

3. **SubletTest.php** - Sublet detection
   ```php
   testSubletDetection('YESB0TSS001') // → "Satara Sahakari Bank"
   ```

4. **DatasetTest.php** - Dataset integrity (requires `RUN_DATASET_TESTS=true`)
   ```php
   testAllIFSCsAre11Chars()
   testNoDuplicates()
   testRequiredFieldsPresent()
   ```

5. **ClientTest.php** - API client functionality
   ```php
   testAPIFetch('SBIN0000001') // Fetch from razorpay.com API
   ```

6. **CoverageTest.php** - Code coverage metrics
   ```php
   testCoverageAbove80Percent()
   ```

**Matrix**: PHP 8.1

**Typical Output**:
```
PHPUnit 10.5.0 by Sebastian Bergmann and contributors.

Runtime:       PHP 8.1.27
Configuration: phpunit.xml

............................................................  60 / 100 ( 60%)
............................................              100 / 100 (100%)

Time: 00:02.456, Memory: 256.00 MB

OK (100 tests, 450 assertions)
```

### Node.js Tests
**Location**: `tests/node/`

**Run Command**:
```bash
npm install
npm test
```

**Script** (from package.json):
```json
{
  "scripts": {
    "test": "node tests/node/validator_test.js && node tests/node/client_test.js && node tests/node/bank_test.js"
  }
}
```

**Test Files**:
1. **validator_test.js** - IFSC validation
   ```javascript
   assert.equal(validate('SBIN0000001'), true)
   assert.equal(validate('INVALID'), false)
   ```

2. **client_test.js** - API client
   ```javascript
   client.get('SBIN0000001', (err, data) => {
     assert.equal(data.BANK, 'State Bank of India')
   })
   ```

3. **bank_test.js** - Bank code utilities
   ```javascript
   assert.equal(getBankName('SBIN'), 'State Bank of India')
   ```

**Matrix**: Node.js 12, 14, 16, 18

**Typical Output**:
```
✓ Validator tests passed (45 assertions)
✓ Client tests passed (23 assertions)
✓ Bank tests passed (18 assertions)

All tests passed! (86 total assertions)
```

### Ruby Tests
**Location**: `tests/ruby/`

**Run Command**:
```bash
bundle install
bundle exec rake
```

**Test Files** (RSpec):
1. **validate_spec.rb** - Validation logic
   ```ruby
   describe 'IFSC validation' do
     it 'validates correct IFSC' do
       expect(Razorpay::IFSC::IFSC.valid?('SBIN0000001')).to be true
     end
   end
   ```

2. **bank_spec.rb** - Bank utilities
   ```ruby
   describe 'Bank lookup' do
     it 'returns bank name' do
       expect(Razorpay::IFSC::Bank.get_name('SBIN')).to eq('State Bank of India')
     end
   end
   ```

3. **ifsc_spec.rb** - IFSC utilities
   ```ruby
   describe 'IFSC parsing' do
     it 'extracts bank code' do
       expect(Razorpay::IFSC::IFSC.bank_code('SBIN0000001')).to eq('SBIN')
     end
   end
   ```

**Matrix**: Ruby 2.6, 2.7, 3.0, 3.1

**Typical Output**:
```
Razorpay::IFSC
  IFSC validation
    ✓ validates correct IFSC
    ✓ rejects invalid IFSC
  Bank lookup
    ✓ returns bank name
    ✓ handles unknown bank codes

Finished in 1.23 seconds (files took 0.5 seconds to load)
34 examples, 0 failures
```

### Go Tests
**Location**: `tests/` and `src/go/`

**Run Command**:
```bash
./tests/constants.sh
make go-test
```

**Test Files**:
1. **constants.sh** - Validate generated constants
   ```bash
   #!/bin/bash
   # Ensure bank constants are up-to-date
   make generate-constants
   git diff --exit-code src/go/constants.go || exit 1
   ```

2. **Go unit tests** (with `go test`)
   ```go
   func TestValidateIFSC(t *testing.T) {
       assert.True(t, ValidateIFSC("SBIN0000001"))
       assert.False(t, ValidateIFSC("INVALID"))
   }
   ```

**Matrix**: Go 1.17, 1.18, 1.19

**Typical Output**:
```
=== RUN   TestValidateIFSC
--- PASS: TestValidateIFSC (0.00s)
=== RUN   TestGetBankName
--- PASS: TestGetBankName (0.00s)
PASS
coverage: 82.5% of statements
ok      github.com/razorpay/ifsc/go     0.234s
```

## Test Execution Order

### Local Development
```bash
# 1. Run individual suites for quick feedback
npm test                     # Node.js (fastest)
bundle exec rake             # Ruby
make go-test                 # Go
composer test                # PHP

# 2. Run dataset tests (slow, only if data changed)
RUN_DATASET_TESTS=true phpunit
```

### CI Pipeline (GitHub Actions)
**Parallel Execution**:
```
┌─────────────────────────────────────┐
│  Data Generation (scraper job)     │
│  - Download RBI files               │
│  - Run scraper                      │
│  - Upload artifacts                 │
└─────────────────┬───────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
┌────────▼────────┐ ┌─────▼──────────┐
│ Dataset Tests   │ │ Unit Tests     │
│ (PHP)           │ │ (All languages)│
│ - Download data │ │ - Node.js      │
│ - Run DatasetTest│ │ - PHP         │
└─────────────────┘ │ - Ruby         │
                    │ - Go           │
                    └────────────────┘
```

**Why Parallel?**
- Dataset tests need generated artifacts
- Unit tests don't depend on data (use fixtures)
- Total CI time: ~3 minutes (vs 8 minutes serial)

## Dataset Tests (Special Handling)

### Environment Variable Control
```bash
# Skip dataset tests (default - fast)
phpunit

# Run dataset tests (requires data/ directory)
RUN_DATASET_TESTS=true phpunit
```

**Why Skip by Default?**
- Dataset tests are **slow** (2-5 minutes)
- They need 120MB+ of data files
- Only needed when data changes
- Unit tests cover library logic

### Dataset Test Workflow (CI)
```yaml
- name: Download artifacts
  uses: actions/download-artifact@v4
  with:
    name: release-artifact
    path: scraper/scripts/data

- name: Extract artifact
  run: gunzip by-bank.tar.gz
  working-directory: scraper/scripts/data

- run: phpunit -d memory_limit=-1
  env:
    RUN_DATASET_TESTS: true
```

## Error Handling

### Test Failures
```ruby
if test_suite.failed?
  log "Tests failed: #{test_suite.failures.count} failures", :critical
  log test_suite.failure_messages.join("\n"), :debug
  exit 1  # STOP RELEASE
end
```

### Missing Dependencies
```
Node tests fail: "Cannot find module 'request'"
→ Run: npm install
→ Check: package.json dependencies

PHP tests fail: "Class 'PHPUnit\Framework\TestCase' not found"
→ Run: composer install
→ Check: composer.json devDependencies
```

### Memory Limits (PHP)
```
PHP Fatal error: Allowed memory size of 134217728 bytes exhausted

→ Solution: phpunit -d memory_limit=-1
→ Dataset tests load 177K IFSCs into memory
```

### Missing Data Files
```
DatasetTest error: "File 'data/IFSC.json' not found"

→ Ensure scraper ran successfully
→ Check: data/ directory exists
→ Verify: by-bank.tar.gz extracted
```

## Success Criteria

- ✅ All 4 language test suites pass
- ✅ Code coverage >80% (Go, PHP)
- ✅ Dataset tests pass (if enabled)
- ✅ Zero test failures
- ✅ Zero segfaults or crashes

## Performance Targets

**Local Machine**:
- Node.js tests: <10 seconds
- Ruby tests: <15 seconds
- Go tests: <5 seconds
- PHP tests (no dataset): <20 seconds
- PHP tests (with dataset): <3 minutes

**CI Pipeline** (parallel):
- Total time: <4 minutes
- Dataset tests: <3 minutes
- Unit tests: <2 minutes

## Output Statistics

**Test Report Summary**:
```
=== Test Suite Results ===

Node.js (4 versions):
✅ v12: 86 tests passed
✅ v14: 86 tests passed
✅ v16: 86 tests passed
✅ v18: 86 tests passed

PHP 8.1:
✅ Unit tests: 100 tests, 450 assertions
✅ Dataset tests: 15 tests, 177,569 validations

Ruby (4 versions):
✅ v2.6: 34 examples, 0 failures
✅ v2.7: 34 examples, 0 failures
✅ v3.0: 34 examples, 0 failures
✅ v3.1: 34 examples, 0 failures

Go (3 versions):
✅ v1.17: coverage 82.5%
✅ v1.18: coverage 82.5%
✅ v1.19: coverage 82.5%

Overall: ✅ ALL TESTS PASSED
```

## Integration with Release Workflow

**Test Checkpoint** (must pass before release):
```
1. Data generation
2. Data validation (dataset tests) ← CRITICAL
3. Export to all formats
4. Test runner ← HERE (exit if failed)
5. Changelog generation
6. Git commit
7. Create release
```

**Failure Behavior**:
```ruby
unless all_tests_passed?
  log "Cannot proceed with release - tests failed", :critical
  log "Fix the errors and re-run the workflow", :info
  exit 1
end
```

## Test Fixtures

### Sample IFSC Codes (for unit tests)
```json
{
  "valid": [
    "SBIN0000001",
    "HDFC0000001",
    "ICIC0000001",
    "YESB0TSS001"
  ],
  "invalid": [
    "INVALID",
    "SBIN000000",  // Too short
    "SBIN00000012", // Too long
    "sbin0000001",  // Lowercase
    "1234567890A"   // Starts with number
  ]
}
```

### Mock API Responses (for client tests)
```json
{
  "SBIN0000001": {
    "BANK": "State Bank of India",
    "BRANCH": "Mumbai Main Branch",
    "IFSC": "SBIN0000001",
    "CITY": "MUMBAI",
    "STATE": "MAHARASHTRA",
    "RTGS": true,
    "NEFT": true,
    "IMPS": true,
    "UPI": true
  }
}
```

## Related Files

- `.github/workflows/tests.yml` - CI test matrix
- `.github/workflows/scraper.yml:34-55` - Dataset tests
- `tests/php/DatasetTest.php` - Dataset integrity tests
- `tests/node/validator_test.js` - Node.js validation tests
- `tests/ruby/validate_spec.rb` - Ruby validation tests
- `Makefile:1-2` - Go test target
- `package.json:13-14` - Node.js test script

## Future Enhancements

### Parallel Local Tests
```bash
# Run all test suites in parallel
npm test & \
bundle exec rake & \
make go-test & \
composer test &
wait

echo "All tests completed!"
```

### Test Coverage Reporting
```
→ Upload coverage to Codecov
→ Fail if coverage drops below 80%
→ Track coverage trends over releases
```

### Performance Benchmarks
```go
func BenchmarkValidateIFSC(b *testing.B) {
    for i := 0; i < b.N; i++ {
        ValidateIFSC("SBIN0000001")
    }
}
// Ensure validation <1μs per call
```

### Snapshot Testing
```ruby
# Ensure dataset structure doesn't change unexpectedly
expect(dataset.keys.sort).to match_snapshot
```
