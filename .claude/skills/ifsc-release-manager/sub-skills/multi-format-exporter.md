# Multi-Format Exporter Sub-Skill

## Purpose
Export IFSC dataset in 5 different formats: CSV, by-bank JSON, list JSON, code JSON, and compressed tarball for distribution.

## When to Use
- After dataset merging and patch application
- Before creating release commit
- When generating distribution artifacts

## Export Formats

### 1. Full CSV Export
**File**: `data/IFSC.csv`

**Format**:
```csv
BANK,IFSC,BRANCH,CENTRE,DISTRICT,STATE,ADDRESS,CONTACT,IMPS,RTGS,CITY,ISO3166,NEFT,MICR,UPI,SWIFT
State Bank of India,SBIN0000001,Mumbai Main Branch,NA,MUMBAI,MAHARASHTRA,Mumbai Samachar Marg...,+912222631516,true,true,MUMBAI,MH,true,400002002,true,SBININBB001
```

**Column Order** (fixed):
1. BANK
2. IFSC
3. BRANCH
4. CENTRE
5. DISTRICT
6. STATE
7. ADDRESS
8. CONTACT
9. IMPS
10. RTGS
11. CITY
12. ISO3166
13. NEFT
14. MICR
15. UPI
16. SWIFT

**Implementation**:
```ruby
def export_csv(data)
  CSV.open('data/IFSC.csv', 'wb') do |csv|
    keys = ['BANK','IFSC','BRANCH','CENTRE','DISTRICT','STATE','ADDRESS','CONTACT','IMPS','RTGS','CITY','ISO3166','NEFT','MICR','UPI','SWIFT']
    csv << keys
    data.each do |code, ifsc_data|
      sorted_data = []
      keys.each do |key|
        sorted_data << ifsc_data.fetch(key, "NA")
      end
      csv << sorted_data
    end
  end
end
```

**Purpose**: Human-readable, Excel-compatible, easy to query with SQL tools.

### 2. By-Bank JSON Export
**Directory**: `data/by-bank/`
**Files**: One JSON file per bank (e.g., `SBIN.json`, `HDFC.json`)

**Format**:
```json
{
  "SBIN0000001": {
    "BANK": "State Bank of India",
    "IFSC": "SBIN0000001",
    "BRANCH": "Mumbai Main Branch",
    "ADDRESS": "Mumbai Samachar Marg, Fort, Mumbai 400001",
    "CONTACT": "+912222631516",
    "CITY": "MUMBAI",
    "DISTRICT": "MUMBAI",
    "STATE": "MAHARASHTRA",
    "MICR": "400002002",
    "RTGS": true,
    "NEFT": true,
    "IMPS": true,
    "UPI": true,
    "SWIFT": "SBININBB001"
  },
  "SBIN0000002": { ... }
}
```

**Implementation**:
```ruby
def export_json_by_banks(list, ifsc_hash)
  banks = find_bank_codes(list)
  banks.each do |bank|
    hash = {}
    branches = find_bank_branches(bank, list)
    branches.sort.each do |code|
      hash[code] = ifsc_hash[code]
    end
    File.open("data/by-bank/#{bank}.json", 'w') { |f| f.write JSON.pretty_generate(hash) }
  end
end

def find_bank_codes(list)
  banks = Set.new
  list.each do |code|
    banks.add code[0...4] if code
  end
  banks
end

def find_bank_branches(bank, list)
  list.select do |code|
    if code
      bank == code[0...4]
    else
      false
    end
  end
end
```

**Purpose**:
- API can load only specific bank's data (faster)
- Reduces memory usage for bank-specific queries
- ~1,346 files (one per bank)

**Typical File Sizes**:
- SBI: ~8 MB (23,000+ branches)
- HDFC: ~3 MB (6,000+ branches)
- Small banks: <100 KB

### 3. IFSC List JSON
**File**: `data/IFSC-list.json`

**Format**:
```json
[
  "SBIN0000001",
  "SBIN0000002",
  "HDFC0000001",
  ...
]
```

**Implementation**:
```ruby
def export_json_list(list)
  File.open('data/IFSC-list.json', 'w') { |f| JSON.dump(list, f) }
end
```

**Purpose**:
- Fast validation: "Is this IFSC valid?"
- Autocomplete dropdowns
- Minimal size (~3 MB for 177K codes)

### 4. Code JSON (Compact Format)
**File**: `data/IFSC.json`

**Format**:
```json
{
  "SBIN": [1, 2, 3, 4, 5, "ABC123", ...],
  "HDFC": [1, 2, 3, ...]
}
```

**Key Feature**: Drops leading zeros from branch codes
```
SBIN0000001 → SBIN + 1
SBIN0000002 → SBIN + 2
SBIN0ABC123 → SBIN + "ABC123"
```

**Implementation**:
```ruby
def export_to_code_json(list)
  banks = find_bank_codes(list)
  banks_hash = {}

  banks.each do |bank|
    banks_hash[bank] = find_bank_branches(bank, list).map do |code|
      # Drop leading zeros to save space
      branch_code = code.strip[-6, 6]
      if branch_code =~ /^(\d)+$/
        branch_code.to_i  # "000001" → 1
      else
        branch_code       # "ABC123" → "ABC123"
      end
    end
  end

  File.open('data/IFSC.json', 'w') do |file|
    file.puts banks_hash.to_json
  end
end
```

**Purpose**:
- Smallest JSON format (~1.5 MB vs ~50 MB)
- Used by validation libraries
- Fast IFSC existence checks

**Trade-off**: Loses branch details, only tracks valid codes.

### 5. Compressed Tarball
**File**: `releases/ifsc-{version}.tar.gz`

**Contents**:
```
ifsc-2.0.53/
├── IFSC.csv
├── IFSC.json
├── IFSC-list.json
├── by-bank/
│   ├── SBIN.json
│   ├── HDFC.json
│   ├── ICIC.json
│   └── ... (1,346 files)
├── README.md
└── CHANGELOG.md
```

**Implementation**:
```bash
cd data
tar -czf ../releases/ifsc-${VERSION}.tar.gz \
  IFSC.csv \
  IFSC.json \
  IFSC-list.json \
  by-bank/*.json \
  ../README.md \
  ../CHANGELOG.md
```

**Purpose**:
- GitHub release artifact
- Offline usage
- Complete dataset snapshot

**Typical Size**: ~15 MB compressed (from ~120 MB uncompressed)

## Export Workflow

### Step 1: Prepare Output Directories
```bash
mkdir -p data/by-bank
rm -f data/by-bank/*.json  # Clean old files
mkdir -p releases
```

### Step 2: Export in Order
```ruby
log 'Exporting CSV'
export_csv(dataset)

log 'Exporting JSON by Banks'
export_json_by_banks(ifsc_codes_list, dataset)

log 'Exporting JSON List'
export_json_list(ifsc_codes_list)

log 'Exporting to validation JSON'
export_to_code_json(ifsc_codes_list)

log 'Export done'
```

**Why This Order?**
- CSV first (largest, most complete)
- By-bank JSON (1,346 file writes - takes time)
- List JSON (fast)
- Code JSON (fast)

### Step 3: Validate Exports
```ruby
# Check file existence
required_files = [
  'data/IFSC.csv',
  'data/IFSC.json',
  'data/IFSC-list.json'
]

required_files.each do |file|
  unless File.exist?(file)
    log "ERROR: #{file} not created", :critical
    exit 1
  end
end

# Check by-bank directory
bank_count = Dir.glob('data/by-bank/*.json').count
expected_banks = 1300..1400

unless expected_banks.include?(bank_count)
  log "WARNING: Expected 1300-1400 bank files, got #{bank_count}", :warn
end
```

### Step 4: Generate Tarball
```bash
VERSION=$(node -p "require('./package.json').version")
cd data
tar -czf ../releases/ifsc-${VERSION}.tar.gz \
  IFSC.csv IFSC.json IFSC-list.json by-bank/ \
  ../README.md ../CHANGELOG.md
cd ..
```

## File Size Validation

**Expected Sizes** (for ~177K IFSCs):
- `IFSC.csv`: 40-50 MB
- `IFSC.json`: 1-2 MB (compact)
- `IFSC-list.json`: 3-4 MB
- `by-bank/*.json`: 100-120 MB total
- `ifsc-{version}.tar.gz`: 12-18 MB

**Validation**:
```ruby
def validate_export_sizes
  sizes = {
    'data/IFSC.csv' => 40_000_000..60_000_000,
    'data/IFSC.json' => 1_000_000..3_000_000,
    'data/IFSC-list.json' => 2_500_000..5_000_000
  }

  sizes.each do |file, expected_range|
    actual_size = File.size(file)
    unless expected_range.include?(actual_size)
      log "WARNING: #{file} size #{actual_size} outside expected range", :warn
    end
  end
end
```

## Handling Export Failures

### CSV Export Failure
```
Error: Permission denied writing data/IFSC.csv
→ Check directory permissions
→ Ensure data/ directory exists
→ Check disk space
```

### By-Bank Export Partial Failure
```
→ If some bank files missing, identify which banks failed
→ Log missing banks for manual investigation
→ Acceptable: <5 missing banks (very small banks)
→ Unacceptable: >10 missing banks (critical failure)
```

### JSON Parse Errors
```
→ Ensure dataset contains valid Ruby hashes
→ Check for nil/undefined values in data
→ Validate all IFSCs are strings
```

## Performance Optimization

### Parallel By-Bank Export
```ruby
require 'parallel'

Parallel.each(banks, in_threads: 8) do |bank|
  hash = {}
  branches = find_bank_branches(bank, list)
  branches.sort.each do |code|
    hash[code] = ifsc_hash[code]
  end
  File.open("data/by-bank/#{bank}.json", 'w') { |f| f.write JSON.pretty_generate(hash) }
end
```

**Speedup**: 8x faster on multi-core systems

### Streaming CSV Export
For very large datasets:
```ruby
File.open('data/IFSC.csv', 'w') do |file|
  file.puts keys.to_csv
  data.each_slice(1000) do |batch|
    batch.each do |code, ifsc_data|
      file.puts sorted_data.to_csv
    end
  end
end
```

## Integration with Release Workflow

**Called Near End** of workflow:
```
1. Data extraction (NEFT, RTGS, IMPS)
2. Data merging
3. Patch application
4. State normalization
5. Export to all formats ← HERE
6. Run tests
7. Create commit
8. Create release
```

## Success Criteria

- ✅ All 5 export formats generated
- ✅ File sizes within expected ranges
- ✅ 1,300-1,400 by-bank JSON files created
- ✅ Zero file corruption (valid JSON/CSV)
- ✅ Tarball created successfully
- ✅ Export completes in <2 minutes

## Output Statistics

**Report Format**:
```
=== Export Summary ===
CSV: 45.2 MB (177,569 entries)
By-Bank JSON: 1,346 files (115 MB total)
List JSON: 3.1 MB (177,569 codes)
Code JSON: 1.8 MB (1,346 banks)
Tarball: 14.5 MB

Export time: 87 seconds
✅ All exports successful
```

## Related Files

- `scraper/scripts/methods.rb:277` - `export_csv()`
- `scraper/scripts/methods.rb:310` - `export_json_by_banks()`
- `scraper/scripts/methods.rb:433` - `export_json_list()`
- `scraper/scripts/methods.rb:437` - `export_to_code_json()`
- `scraper/scripts/generate.rb:34-46` - Export orchestration
