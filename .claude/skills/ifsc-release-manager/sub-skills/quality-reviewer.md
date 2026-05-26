# Quality Reviewer Sub-Skill

## Purpose
Perform comprehensive quality checks on generated dataset and release PR before merging and publishing.

## When to Use
- After creating release PR
- Before merging to master
- As final validation checkpoint
- For manual release reviews

## Review Checklist

### 1. Data Quality Checks

#### IFSC Format Validation
```ruby
def validate_ifsc_format(dataset)
  invalid_ifsc = []

  dataset.each do |ifsc, data|
    # Rule 1: Exactly 11 characters
    if ifsc.length != 11
      invalid_ifsc << {ifsc: ifsc, error: "Length #{ifsc.length}, expected 11"}
    end

    # Rule 2: First 4 chars are uppercase letters
    unless ifsc[0..3].match?(/^[A-Z]{4}$/)
      invalid_ifsc << {ifsc: ifsc, error: "Invalid bank code: #{ifsc[0..3]}"}
    end

    # Rule 3: 5th char is '0'
    unless ifsc[4] == '0'
      invalid_ifsc << {ifsc: ifsc, error: "5th char is '#{ifsc[4]}', expected '0'"}
    end

    # Rule 4: Last 6 chars are alphanumeric
    unless ifsc[5..10].match?(/^[A-Z0-9]{6}$/)
      invalid_ifsc << {ifsc: ifsc, error: "Invalid branch code: #{ifsc[5..10]}"}
    end
  end

  invalid_ifsc
end
```

**Expected Result**: Zero invalid IFSCs

#### Required Field Validation
```ruby
REQUIRED_FIELDS = ['BANK', 'IFSC', 'BRANCH', 'STATE', 'CITY']

def validate_required_fields(dataset)
  missing_fields = []

  dataset.each do |ifsc, data|
    REQUIRED_FIELDS.each do |field|
      if data[field].nil? || data[field].to_s.strip.empty?
        missing_fields << {ifsc: ifsc, field: field}
      end
    end
  end

  missing_fields
end
```

**Acceptable**: <10 entries with missing fields (can be patched)
**Critical**: >100 entries missing fields (data corruption)

#### State Normalization Check
```ruby
def validate_states(dataset)
  unknown_states = Set.new

  dataset.each do |ifsc, data|
    state = data['STATE']
    unless ISO3166_MAP.key?(state)
      unknown_states.add(state)
    end
  end

  unknown_states
end
```

**Expected Result**: Zero unknown states (all normalized)

#### Duplicate Detection
```ruby
def check_duplicates(dataset)
  ifsc_counts = Hash.new(0)

  dataset.each_key do |ifsc|
    ifsc_counts[ifsc] += 1
  end

  duplicates = ifsc_counts.select { |ifsc, count| count > 1 }
  duplicates
end
```

**Expected Result**: Zero duplicates

### 2. Count Validation

#### Total IFSC Count
```ruby
def validate_ifsc_count(current_count, previous_count)
  diff = current_count - previous_count
  percent_change = (diff.to_f / previous_count * 100).round(2)

  # Sanity checks
  if percent_change > 5.0
    {
      status: :critical,
      message: "IFSC count increased by #{percent_change}% (#{diff} new entries). Unusual spike!"
    }
  elsif percent_change < -2.0
    {
      status: :critical,
      message: "IFSC count decreased by #{percent_change.abs}% (#{diff.abs} removed). Data loss suspected!"
    }
  elsif diff.abs < 10
    {
      status: :info,
      message: "Minimal changes (#{diff}). Consider skipping release."
    }
  else
    {
      status: :ok,
      message: "IFSC count: #{current_count} (#{diff >= 0 ? '+' : ''}#{diff})"
    }
  end
end
```

**Expected Range**: -2% to +5% change per release

#### Bank Count
```ruby
def validate_bank_count(dataset)
  bank_codes = dataset.keys.map { |ifsc| ifsc[0..3] }.uniq

  expected_range = 1300..1400

  unless expected_range.include?(bank_codes.count)
    {
      status: :warn,
      message: "Bank count #{bank_codes.count} outside expected range #{expected_range}"
    }
  else
    {
      status: :ok,
      message: "Bank count: #{bank_codes.count}"
    }
  end
end
```

### 3. File Integrity Checks

#### File Existence
```ruby
REQUIRED_FILES = [
  'data/IFSC.csv',
  'data/IFSC.json',
  'data/IFSC-list.json',
  'data/by-bank.tar.gz',
  'CHANGELOG.md',
  'package.json'
]

def validate_file_existence
  missing = REQUIRED_FILES.reject { |f| File.exist?(f) }

  if missing.any?
    {
      status: :critical,
      message: "Missing files: #{missing.join(', ')}"
    }
  else
    {
      status: :ok,
      message: "All required files present"
    }
  end
end
```

#### File Size Validation
```ruby
FILE_SIZE_RANGES = {
  'data/IFSC.csv' => 40_000_000..60_000_000,        # 40-60 MB
  'data/IFSC.json' => 1_000_000..3_000_000,         # 1-3 MB
  'data/IFSC-list.json' => 2_500_000..5_000_000,    # 2.5-5 MB
  'data/by-bank.tar.gz' => 10_000_000..20_000_000   # 10-20 MB
}

def validate_file_sizes
  issues = []

  FILE_SIZE_RANGES.each do |file, expected_range|
    actual_size = File.size(file)

    unless expected_range.include?(actual_size)
      issues << {
        file: file,
        actual: (actual_size / 1_000_000.0).round(2),
        expected: "#{expected_range.min / 1_000_000}-#{expected_range.max / 1_000_000} MB"
      }
    end
  end

  issues
end
```

#### JSON Validity
```ruby
def validate_json_files
  json_files = [
    'data/IFSC.json',
    'data/IFSC-list.json',
    'data/banks.json',
    'data/sublet.json'
  ]

  json_files.each do |file|
    begin
      JSON.parse(File.read(file))
    rescue JSON::ParserError => e
      return {
        status: :critical,
        file: file,
        error: e.message
      }
    end
  end

  {status: :ok, message: "All JSON files valid"}
end
```

### 4. Regression Checks

#### Known IFSC Codes Still Valid
```ruby
CRITICAL_IFSC_CODES = [
  'SBIN0000001',  # SBI Mumbai Main
  'HDFC0000001',  # HDFC Mumbai
  'ICIC0000001',  # ICICI Mumbai
  'PUNB0000100',  # PNB Delhi
  'BARB0000001'   # Bank of Baroda
]

def validate_critical_ifsc(dataset)
  missing = CRITICAL_IFSC_CODES.reject { |ifsc| dataset.key?(ifsc) }

  if missing.any?
    {
      status: :critical,
      message: "Critical IFSCs missing: #{missing.join(', ')}"
    }
  else
    {
      status: :ok,
      message: "All critical IFSCs present"
    }
  end
end
```

#### Bank Code Stability
```ruby
def validate_bank_codes(current_banks, previous_banks)
  removed_banks = previous_banks - current_banks

  if removed_banks.size > 5
    {
      status: :critical,
      message: "#{removed_banks.size} banks removed: #{removed_banks.to_a.join(', ')}"
    }
  elsif removed_banks.any?
    {
      status: :warn,
      message: "Banks removed: #{removed_banks.to_a.join(', ')} (bank mergers?)"
    }
  else
    {
      status: :ok,
      message: "No banks removed"
    }
  end
end
```

### 5. Changelog Review

#### Version Bump Validation
```ruby
def validate_version_bump(old_version, new_version, change_count)
  old_major, old_minor, old_patch = old_version.split('.').map(&:to_i)
  new_major, new_minor, new_patch = new_version.split('.').map(&:to_i)

  # Determine expected bump
  if change_count < 50
    expected_bump = :none
  elsif change_count < 500
    expected_bump = :patch
  elsif change_count < 5000
    expected_bump = :minor
  else
    expected_bump = :major
  end

  # Determine actual bump
  if new_major > old_major
    actual_bump = :major
  elsif new_minor > old_minor
    actual_bump = :minor
  elsif new_patch > old_patch
    actual_bump = :patch
  else
    actual_bump = :none
  end

  if actual_bump != expected_bump
    {
      status: :warn,
      message: "Version bump mismatch. Expected #{expected_bump}, got #{actual_bump}. (#{change_count} changes)"
    }
  else
    {
      status: :ok,
      message: "Version bump (#{actual_bump}) matches change magnitude"
    }
  end
end
```

#### Changelog Entry Validation
```ruby
def validate_changelog_entry(version)
  changelog = File.read('CHANGELOG.md')

  # Check if version exists in changelog
  unless changelog.include?("## [#{version}][#{version}]")
    return {
      status: :critical,
      message: "Version #{version} not found in CHANGELOG.md"
    }
  end

  # Check if entry is not just "UNRELEASED"
  if changelog.lines.grep(/## \[#{version}\]/).first.include?('UNRELEASED')
    return {
      status: :warn,
      message: "Changelog entry still marked as UNRELEASED"
    }
  end

  {status: :ok, message: "Changelog entry present for #{version}"}
end
```

### 6. Git Commit Review

#### Commit Message Format
```ruby
def validate_commit_message(message)
  # Expected format: "[release] 2.0.54\n\n..."

  unless message.start_with?('[release]')
    return {
      status: :warn,
      message: "Commit message doesn't start with [release]"
    }
  end

  unless message.include?('Generated with Claude Code')
    return {
      status: :info,
      message: "Commit not marked as AI-generated"
    }
  end

  {status: :ok, message: "Commit message format correct"}
end
```

#### Changed Files Validation
```ruby
EXPECTED_CHANGED_FILES = [
  'data/IFSC.csv',
  'data/IFSC.json',
  'data/IFSC-list.json',
  'data/by-bank.tar.gz',
  'CHANGELOG.md',
  'package.json'
]

def validate_changed_files(git_status)
  staged_files = git_status.split("\n").map(&:strip)

  # Check if all expected files are staged
  missing_files = EXPECTED_CHANGED_FILES.reject do |file|
    staged_files.any? { |staged| staged.include?(file) }
  end

  if missing_files.any?
    {
      status: :warn,
      message: "Expected files not staged: #{missing_files.join(', ')}"
    }
  else
    {
      status: :ok,
      message: "All expected files staged for commit"
    }
  end
end
```

## Review Report Format

### Console Output
```
=== IFSC Release Quality Review ===

Data Quality:
✅ IFSC format validation: 177,569 entries, 0 errors
✅ Required fields: 0 missing
✅ State normalization: 0 unknown states
✅ Duplicates: 0 found

Counts:
✅ IFSC count: 177,569 (+234 from previous)
✅ Bank count: 1,346 (within expected range)

File Integrity:
✅ All required files present
✅ File sizes within expected ranges
✅ JSON validation: All files valid

Regression:
✅ Critical IFSCs: All present
⚠️  Bank codes: 2 banks removed (BKDN, CSBK - mergers)

Changelog:
✅ Version bump: patch (matches change magnitude)
✅ Changelog entry: Present for 2.0.54

Git:
✅ Commit message: Correct format
✅ Changed files: All expected files staged

Overall Status: ✅ READY TO MERGE
Warnings: 1 (bank removals - expected)
```

### Failed Review Example
```
=== IFSC Release Quality Review ===

Data Quality:
❌ IFSC format validation: 12 invalid entries
   - INVALID001: Length 8, expected 11
   - SBIN000000: Length 10, expected 11
   ...

✅ Required fields: 0 missing
⚠️  State normalization: 3 unknown states (KARNATKA, DELLHI, GUJRAT)
✅ Duplicates: 0 found

File Integrity:
❌ File 'data/by-bank.tar.gz' missing
✅ JSON validation: All files valid

Overall Status: ❌ BLOCKED - Fix errors before merging
```

## Integration with Workflow

**Review Checkpoint** (before PR merge):
```
1. Create release branch
2. Generate dataset
3. Run tests ✅
4. Create commit ✅
5. Create PR ✅
6. Quality review ← HERE
7. If passed → Merge PR
8. If failed → Fix issues and re-run
```

## Automated vs Manual Review

### Automated (Always Run)
- IFSC format validation
- File existence checks
- JSON validity
- Count ranges
- Version bump logic

### Manual (Human Review Required)
- Bank mergers (need confirmation)
- Large deletions (>100 IFSCs)
- Major version bumps
- Breaking changes

## Error Thresholds

**Block Merge** (Critical):
- Any invalid IFSC format
- Missing required files
- Invalid JSON
- >10% IFSC count change
- Critical IFSCs missing

**Warning** (Review Recommended):
- Bank removals
- Unusual file sizes
- Version bump mismatch
- >5% IFSC count change

**Info** (Acceptable):
- <50 changes (consider skip)
- Minor file size differences
- Non-critical IFSCs missing

## Success Criteria

- ✅ All critical checks pass
- ✅ Zero data integrity errors
- ✅ File integrity validated
- ✅ Changelog complete
- ✅ Commit ready for merge

## Related Files

- `scraper/scripts/methods.rb` - Data validation functions
- `.github/workflows/scraper.yml` - CI quality gates
- `tests/php/DatasetTest.php` - Dataset validation tests

## Future Enhancements

### AI-Powered Anomaly Detection
```python
# Detect unusual patterns using ML
anomalies = detect_anomalies(current_dataset, historical_datasets)

if anomalies:
    log_warning(f"Unusual patterns detected: {anomalies}")
    request_human_review()
```

### Automated Fix Suggestions
```
Error: 3 IFSCs have invalid state names
  - SBIN0012345: "KARNATKA" → Suggested fix: "KARNATAKA"
  - HDFC0067890: "DELLHI" → Suggested fix: "DELHI"

Apply fixes automatically? (y/n)
```

### Diff Visualization
```
Generate visual diff report:
- Map view: New branches (green), Removed (red)
- State distribution changes (bar chart)
- Bank growth trends (line graph)
```
