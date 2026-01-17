# IFSC Domain Knowledge

## What is an IFSC Code?

**IFSC** = Indian Financial System Code

A unique 11-character code that identifies every bank branch participating in electronic funds transfer in India.

### Format

```
[BANK][0][BRANCH]
 ^^^^  ^  ^^^^^^
  4    1    6
```

- **Characters 1-4**: Bank code (e.g., `HDFC`, `SBIN`, `ICIC`)
- **Character 5**: Always `0` (reserved for future use)
- **Characters 6-11**: Branch code (alphanumeric, bank-specific)

### Examples

- `HDFC0000001`: HDFC Bank, RTGS-HO branch
- `SBIN0000001`: State Bank of India, main branch
- `ICIC0000001`: ICICI Bank, Fort Mumbai
- `PUNB0026200`: Punjab National Bank, branch code 026200

### Validation Rules

**Format validation**:
```
✓ HDFC0000001  - Valid
✓ SBIN0BRANCH  - Valid (letters in branch code)
✗ HDFC1000001  - Invalid (5th char must be 0)
✗ HDFCBANK001  - Invalid (bank code too long)
✗ HDFC000001   - Invalid (only 10 chars)
```

**Bank code validation**:
- Must be 4 uppercase letters
- Must exist in `banks.json`
- Examples: HDFC, SBIN, ICIC, PUNB, BARB

**Branch code validation**:
- Must be 6 alphanumeric characters
- Can be all numbers: `000001`
- Can be letters: `BRANCH`
- Can be mixed: `00ABC1`

## Related Codes

### MICR Code
**MICR** = Magnetic Ink Character Recognition

9-digit code printed on cheques:
```
400240002
^^^-^^-^^^
 |   |   └─ Branch code
 |   └───── Bank code
 └───────── City code
```

Example: `400240002`
- `400` = Mumbai
- `24` = HDFC Bank
- `002` = Specific branch

### SWIFT Code
**SWIFT** = Society for Worldwide Interbank Financial Telecommunication

8 or 11 character code for international transfers:
```
HDFCINBBXXX
^^^^|||||^^
 |   || ||└─ Branch code (optional, XXX = head office)
 |   || └──── Location code
 |   └────── Country code (IN = India)
 └────────── Bank code
```

Example: `HDFCINBB`
- `HDFC` = HDFC Bank
- `IN` = India
- `BB` = Mumbai

## Bank Types

From `banks.json`:

1. **PSB** = Public Sector Bank
   - Government owned
   - Examples: SBI, PNB, BOB, Canara Bank

2. **PVB** = Private Sector Bank
   - Privately owned
   - Examples: HDFC, ICICI, Axis, Kotak

3. **FBK** = Foreign Bank
   - International banks in India
   - Examples: Citibank, HSBC, Standard Chartered

4. **UCB** = Urban Cooperative Bank
   - Small cooperative banks
   - Examples: Saraswat, TJSB, Cosmos

5. **RRB** = Regional Rural Bank
   - Rural focused banks
   - Examples: Andhra Pradesh Grameena Vikas Bank

6. **DCB** = District Central Cooperative Bank
   - District level cooperative banks

## Payment Systems

### NEFT
**National Electronic Funds Transfer**
- Batch processing (hourly settlements)
- No minimum/maximum amount
- All IFSC codes support NEFT

### RTGS
**Real-Time Gross Settlement**
- Real-time transfers
- Minimum: ₹2 lakhs
- Only larger branches support RTGS
- Indicated by `rtgs: true` in dataset

### IMPS
**Immediate Payment Service**
- 24/7 instant transfers
- Mobile/internet banking
- Most modern branches support IMPS
- Indicated by `imps: true`

### UPI
**Unified Payments Interface**
- Virtual payment addresses
- Requires bank to support UPI
- Indicated by `upi: true`
- Example: `user@hdfcbank`

### NACH
**National Automated Clearing House**
- Bulk/recurring payments (EMIs, subscriptions)
- Debit mandate management
- Indicated by `nach_debit: true`

## Sublet Branches

**Sublet** = IFSC codes belonging to large banks but leased to smaller banks

### Why Sublets Exist
Small cooperative banks don't have their own IFSC ranges. Large banks (like HDFC, YES Bank) lease out IFSC codes to them.

### Example
```
IFSC: HDFC0CKUB01
Actual bank: Khamgaon Urban Co-operative Bank (not HDFC!)

HDFC "sublets" the HDFC0CKUB* range to this bank.
```

### Sublet Patterns

**Range-based sublets**:
```
YESB0TSS001 to YESB0TSS999 → Satara Shakari Bank
HDFC0CKUB01 to HDFC0CKUB99 → Khamgaon Urban Co-op
```

**Individual sublets**:
Some are one-off arrangements in `custom-sublets.json`.

### Data Sources
- `sublet.json`: Auto-generated from NPCI data
- `custom-sublets.json`: Manually maintained patterns

## Bank Mergers

### Recent Mergers
```
2020: 10 PSBs merged into 4
- Oriental Bank → PNB
- United Bank → PNB
- Andhra Bank → Union Bank
- Corporation Bank → Union Bank
- Allahabad Bank → Indian Bank
- Syndicate Bank → Canara Bank
- Vijaya Bank → Bank of Baroda
- Dena Bank → Bank of Baroda

2019: SBI merged with 5 associates
- State Bank of Bikaner & Jaipur → SBI
- State Bank of Hyderabad → SBI
- State Bank of Mysore → SBI
- State Bank of Patiala → SBI
- State Bank of Travancore → SBI
```

### Impact on IFSC
When banks merge:
1. Old IFSCs remain valid (transition period)
2. New branches use new bank code
3. Eventually old codes deprecated
4. We track this in dataset updates

Example:
```
VIJB0000001 (Vijaya Bank) → Still works, routes to BOB
BARB0NEW001 (Bank of Baroda) → New branches
```

## Geographic Data

### State Codes
```
MH = Maharashtra
KA = Karnataka
DL = Delhi
TN = Tamil Nadu
UP = Uttar Pradesh
... (28 states + 8 UTs)
```

### City Names
**Common variations**:
```
Bangalore / Bengaluru (use Bengaluru)
Bombay / Mumbai (use Mumbai)
Calcutta / Kolkata (use Kolkata)
Madras / Chennai (use Chennai)
```

### Geographic Consistency
Branch location data should match:
```
Branch: "Indiranagar"
City: "Bangalore"
District: "Bangalore Urban"
State: "Karnataka"

✓ Consistent geographic hierarchy
```

## Data Quality Rules

### Must-Have Fields
```json
{
  "ifsc": "HDFC0000001",      // Required
  "bank": "HDFC Bank",        // Required
  "branch": "RTGS-HO",        // Required
  "city": "MUMBAI",           // Required
  "state": "MAHARASHTRA"      // Required
}
```

### Optional Fields
```json
{
  "micr": "400240002",        // Optional (not all branches)
  "swift": "HDFCINBB",        // Optional (only int'l branches)
  "contact": "+912265658",    // Optional
  "address": "Full address",  // Optional
  "district": "Mumbai",       // Optional
  "centre": "Mumbai"          // Optional
}
```

### Boolean Flags
```json
{
  "rtgs": true,     // Supports RTGS
  "neft": true,     // Supports NEFT (almost all do)
  "imps": true,     // Supports IMPS
  "upi": true       // Bank supports UPI
}
```

## Common Anomalies

### 1. Duplicate IFSCs
```
Same IFSC appearing twice in source
→ Deduplicate, keep most recent entry
```

### 2. Invalid MICR
```
MICR: "NA" or "000000000"
→ Set to null
```

### 3. Mixed Case
```
Bank: "hdfc bank" or "HDFC BANK"
→ Normalize to "HDFC Bank" (title case)
```

### 4. Special Characters
```
Branch: "Branch–A" (en dash)
→ Replace with "Branch-A" (hyphen)
```

### 5. Trailing Spaces
```
IFSC: "HDFC0000001 "
→ Trim whitespace
```

### 6. Geographic Mismatch
```
Branch: "Delhi Connaught Place"
City: "Mumbai"
→ Flag as suspicious, likely data error
```

## Versioning Strategy

### What Triggers a Release?

**Patch (2.0.X)**:
- 50-500 new IFSCs
- <50 deletions
- Branch name typos
- MICR corrections
- No structural changes

**Minor (2.X.0)**:
- >500 IFSCs added
- New data fields
- Bank mergers
- Sublet range additions
- Breaking changes with compatibility

**Major (X.0.0)**:
- Dataset structure change
- Field removals
- SDK API breaking changes

## Historical Context

### Dataset Growth
```
2015: ~8,000 IFSCs
2018: ~12,000 IFSCs
2020: ~15,000 IFSCs (post-merger dip)
2023: ~18,000 IFSCs
2025: ~18,500 IFSCs (current)
```

### Update Frequency
- RBI updates: Quarterly (Jan, Apr, Jul, Oct)
- NPCI updates: Monthly
- Our releases: As needed (typically monthly)

### Data Sources Priority
```
1. RBI official lists (highest authority)
2. NPCI NACH members (for cooperative banks)
3. Individual bank websites (for SWIFT codes)
4. Community contributions (validated manually)
```

## Business Rules

### Release Timing
- Avoid weekends (less support coverage)
- Avoid banking holidays
- Prefer Tuesday-Thursday (Tue is best)
- Never Friday afternoon (too risky)

### Breaking Changes
Always communicate:
- What changed
- Why it changed
- Migration path for users
- Deprecation timeline (if applicable)

### Emergency Releases
Criteria for immediate release:
- Security issue (fraudulent IFSC)
- Major bank merger announcement
- Data corruption in current release
- Critical bug in SDK

Process:
- Skip normal approval (notify after)
- Use hotfix version (2.0.54-hotfix.1)
- Deploy within 2 hours
- Postmortem after

## Patch System

### Patch File Locations
**IFSC-level patches**: `src/patches/ifsc/*.yml`
**Bank-level patches**: `src/patches/banks/*.yml`

### Patch Types

#### 1. Action: `patch`
Apply same changes to multiple IFSCs:
```yaml
action: patch
ifsc:
  - HDFC0000001
  - HDFC0000002
patch:
  SWIFT: HDFCINBB
  UPI: true
```

#### 2. Action: `patch_multiple`
Apply different changes to different IFSCs:
```yaml
action: patch_multiple
ifsc:
  SBIN0000001:
    SWIFT: SBININBB001
  SBIN0000002:
    SWIFT: SBININBB002
```

#### 3. Action: `add_multiple`
Add new IFSCs not in RBI data:
```yaml
action: add_multiple
ifsc:
  HDFC0CUSTOM:
    BANK: HDFC Bank
    BRANCH: Special Branch
    CITY: MUMBAI
    STATE: MAHARASHTRA
```

#### 4. Action: `patch_bank`
Apply patch to all branches of specific banks:
```yaml
action: patch_bank
banks:
  - HDFC
  - ICIC
patch:
  UPI: true
```

#### 5. Action: `delete`
Remove specific IFSCs from dataset:
```yaml
action: delete
ifsc:
  - OLDBANK001
  - CLOSED0001
```

### Common Patch Files

**sbi-swift.yml** (~600 entries)
```yaml
action: patch_multiple
ifsc:
  SBIN0000001: {SWIFT: SBININBB001, BRANCH: Mumbai Main Branch}
  SBIN0000002: {SWIFT: SBININBB002, BRANCH: Delhi Main Branch}
  # ... 600+ SBI branches with SWIFT codes
```

**disabled-imps.yml** (~45 entries)
```yaml
action: patch
ifsc:
  - UBINORRBKGS
  - BARBOBRGBXX
patch:
  IMPS: false
```

**bank-types.yml**
```yaml
action: patch_bank
banks: [HDFC, ICIC, AXIS, YESB]
patch: {type: Private}
---
action: patch_bank
banks: [SBIN, PUNB, BARB, CNRB]
patch: {type: PSB}
```

**upi-enabled-banks.yml**
```yaml
action: patch_bank
banks: [HDFC, ICIC, SBIN, PUNB, AXIS, YESB, # ... 90+ banks]
patch: {UPI: true}
```

### Patch Application Order
1. **Load dataset** (NEFT, RTGS, IMPS merged)
2. **Apply bank-level patches** (`src/patches/banks/*.yml`)
3. **Apply IFSC-level patches** (`src/patches/ifsc/*.yml`)
4. **Export dataset**

Why this order? Bank-level first sets defaults, IFSC-level overrides specific cases.

## Dataset Merge Strategy

### Priority Hierarchy
```
NEFT > RTGS > IMPS
(Higher overwrites lower)
```

**Why?**
- **NEFT**: Most comprehensive (177K+ IFSCs)
- **RTGS**: Subset of NEFT (~176K IFSCs)
- **IMPS**: Virtual branches only (~1,300 IFSCs)

### Merge Logic (from methods.rb:323)

```ruby
combined_data = data_from_imps.merge(
  data_from_rtgs.merge(data_from_neft) do |key, rtgs_val, neft_val|
    # NEFT overwrites RTGS (unless NEFT has "NA")
    if rtgs_val and rtgs_val != 'NA'
      rtgs_val
    else
      neft_val
    end
  end
) do |key, imps_val, rtgs_neft_val|
  # RTGS/NEFT overwrites IMPS (unless "NA")
  if imps_val and imps_val != 'NA'
    imps_val
  else
    rtgs_neft_val
  end
end
```

**Field-level logic**:
- `NEFT` flag: Set from NEFT dataset
- `RTGS` flag: Set from RTGS dataset
- `IMPS` flag: Default true (all banks support IMPS unless disabled via patch)
- `UPI` flag: Set from banks.json
- `MICR` code: Prefer NEFT, fallback to RTGS
- `SWIFT` code: Set via patches only (not in RBI data)
- `BANK` name: Use sublet mapping if applicable, else bank code lookup

### Conflict Resolution

**Example: SBIN0000001 exists in all three sources**
```
IMPS: {BANK: "SBI", IMPS: true, CITY: "MUMBAI"}
RTGS: {BANK: "State Bank of India", RTGS: true, MICR: "400002002", ADDRESS: "Mumbai Samachar Marg"}
NEFT: {BANK: "State Bank of India", NEFT: true, CONTACT: "+912222631516", ADDRESS: "Mumbai Samachar Marg, Fort"}

Final merged:
{
  BANK: "State Bank of India",  # From NEFT
  NEFT: true,                    # From NEFT
  RTGS: true,                    # From RTGS
  IMPS: true,                    # From IMPS
  MICR: "400002002",            # From RTGS (NEFT had "NA")
  ADDRESS: "Mumbai Samachar Marg, Fort",  # From NEFT (most complete)
  CONTACT: "+912222631516"      # From NEFT
}
```

## Export Formats

### 1. IFSC.csv (Full CSV)
**Size**: 45 MB | **Rows**: 177,569

**Column Order** (fixed):
```
BANK,IFSC,BRANCH,CENTRE,DISTRICT,STATE,ADDRESS,CONTACT,IMPS,RTGS,CITY,ISO3166,NEFT,MICR,UPI,SWIFT
```

**Use Cases**: Excel analysis, SQL imports, data warehousing

### 2. By-Bank JSON Files
**Location**: `data/by-bank/*.json`
**Count**: 1,346 files
**Total Size**: 115 MB

**Format**:
```json
// data/by-bank/SBIN.json
{
  "SBIN0000001": { /* full IFSC data */ },
  "SBIN0000002": { /* full IFSC data */ },
  // ... 23,000+ SBI branches
}
```

**Use Cases**: API lookups (load only needed bank), reduced memory usage

### 3. IFSC-list.json (Validation List)
**Size**: 3.1 MB | **Format**: Array of strings

```json
["SBIN0000001", "SBIN0000002", "HDFC0000001", ...]
```

**Use Cases**: Fast validation ("Is this IFSC valid?"), autocomplete

### 4. IFSC.json (Compact Code Format)
**Size**: 1.8 MB | **Format**: Compressed by bank

```json
{
  "SBIN": [1, 2, 3, 4, 5, "ABC123"],  // SBIN0000001, SBIN0000002, ...
  "HDFC": [1, 2, 3],                  // HDFC0000001, HDFC0000002, ...
}
```

**How compression works**:
- Branch code `000001` → Integer `1`
- Branch code `ABC123` → String `"ABC123"`
- Drops leading zeros for numeric codes

**Use Cases**: Validation libraries, minimal bandwidth

### 5. by-bank.tar.gz (Compressed Tarball)
**Size**: 14.5 MB compressed (from 115 MB)
**Contents**: All by-bank/*.json files

**Use Cases**: GitHub release artifacts, offline distribution

## Test Infrastructure

### Test Matrix (4 languages × multiple versions)

**Node.js** (4 versions: 12, 14, 16, 18)
```bash
npm test
# Runs: validator_test.js + client_test.js + bank_test.js
# ~86 assertions
```

**PHP** (1 version: 8.1)
```bash
phpunit -d memory_limit=-1
# Tests: 100 tests, 450 assertions
# With RUN_DATASET_TESTS=true: validates all 177K IFSCs
```

**Ruby** (4 versions: 2.6, 2.7, 3.0, 3.1)
```bash
bundle exec rake
# RSpec: 34 examples, ~100 assertions
```

**Go** (3 versions: 1.17, 1.18, 1.19)
```bash
./tests/constants.sh && make go-test
# Coverage: 82.5%
```

### Dataset Test Types

**Format Validation**:
- All IFSCs exactly 11 characters
- Bank code is 4 uppercase letters
- 5th character is '0'
- Branch code is 6 alphanumeric

**Integrity Checks**:
- No duplicate IFSCs
- All required fields present (BANK, IFSC, BRANCH, CITY, STATE)
- State names match ISO3166 map
- MICR codes are 9 digits (when present)

**Regression Tests**:
- Known critical IFSCs still present (SBIN0000001, HDFC0000001, etc.)
- Bank counts within expected range (1,300-1,400)
- File sizes within expected ranges

## Python Excel Converter

### Purpose
Replaces `ssconvert` (gnumeric) which has installation issues on many systems.

**File**: `scraper/scripts/convert_excel.py`

**Usage**:
```bash
python3 convert_excel.py
# Converts:
# - sheets/68774.xlsx → NEFT-0.csv, NEFT-1.csv
# - sheets/RTGEB0815.xlsx → RTGS-0.csv, RTGS-1.csv, RTGS-2.csv, RTGS-3.csv
```

**Dependencies**:
```python
import pandas as pd
import openpyxl  # Excel engine
```

**Advantages**:
- ✅ Cross-platform (Windows, Mac, Linux)
- ✅ No external binaries needed
- ✅ Handles multi-sheet workbooks
- ✅ Preserves data types
- ✅ Works in CI/CD without apt-get

**Implementation**:
```python
def convert_excel_to_csv(excel_file, output_prefix):
    excel_data = pd.read_excel(excel_file, sheet_name=None, engine='openpyxl')
    sheets_converted = 0
    for sheet_name, df in excel_data.items():
        output_file = f"{output_prefix}-{sheets_converted}.csv"
        df.to_csv(output_file, index=False, encoding='utf-8')
        sheets_converted += 1
    return sheets_converted
```

## State Normalization Patterns

### Common Misspellings
```
ANDHRAPRADESH → ANDHRA PRADESH
KARNATKA → KARNATAKA
DELLHI → DELHI
CHHATTISHGARH → CHHATTISGARH
CHATTISGARH → CHHATTISGARH
ORISSA → ODISHA
TELENGANA → TELANGANA
```

### City → State Mappings
```
MUMBAI → MAHARASHTRA
BANGALORE → KARNATAKA
CHENNAI → TAMIL NADU
HYDERABAD → ANDHRA PRADESH
PUNE → MAHARASHTRA
AHMEDABAD → GUJARAT
```

### Abbreviations
```
AP → ANDHRA PRADESH
KA → KARNATAKA
TN → TELANGANA (not Tamil Nadu!)
MH → MAHARASHTRA
MP → MADHYA PRADESH
```

### Special Cases

**Chandigarh**: Can be Punjab, Haryana, or Union Territory
```
"CHANDIGARH UT" → CHANDIGARH (explicit UT marking)
"CHANDIGARH" → Ambiguous (requires manual patch)
```

**Hyderabad**: Was in Andhra Pradesh, now capital of Telangana
```
Currently mapped to: ANDHRA PRADESH (historical data)
Future enhancement: Use IFSC creation date to determine state
```

**Union Territory Mergers** (2020):
```
Dadra and Nagar Haveli + Daman and Diu → DADRA AND NAGAR HAVELI AND DAMAN AND DIU
```

## Release Workflow Details

### Exact File Flow
```
1. Download RBI files
   ├─ sheets/68774.xlsx (NEFT)
   └─ sheets/RTGEB0815.xlsx (RTGS)

2. Convert to CSV
   ├─ NEFT-0.csv (Total IFSC part 1)
   ├─ NEFT-1.csv (Total IFSC part 2)
   ├─ RTGS-1.csv (RTGS A-H)
   ├─ RTGS-2.csv (RTGS I-R)
   └─ RTGS-3.csv (RTGS S-Z)

3. Generate datasets
   ├─ data/banks.json (from NACH)
   ├─ data/sublet.json (from NACH)
   ├─ data/imps.json (generated)
   ├─ data/rtgs.json (parsed)
   └─ data/neft.json (parsed)

4. Merge → data/IFSC.json (temporary)

5. Apply patches from src/patches/

6. Export final formats
   ├─ data/IFSC.csv
   ├─ data/IFSC.json
   ├─ data/IFSC-list.json
   ├─ data/by-bank/*.json (1,346 files)
   └─ data/by-bank.tar.gz

7. Generate release notes
   ├─ Clone ifsc-api repo
   ├─ Copy by-bank/ files
   ├─ Git diff to find changes
   └─ Generate release.md

8. Create release
   ├─ Update CHANGELOG.md
   ├─ Update package.json version
   ├─ Commit + tag
   └─ Push
```

### Critical Checkpoints

**Checkpoint 1: UPI Validation** (Exit on failure)
```ruby
if upi_banks_from_html.count != upi_banks_from_patch.count
  exit 1  # CRITICAL FAILURE
end
```

**Checkpoint 2: SWIFT Validation** (Exit on failure)
```ruby
if missing_swift_codes.size != 0
  exit 1  # SBI SWIFT codes missing
end
```

**Checkpoint 3: Dataset Tests** (Exit on failure)
```bash
RUN_DATASET_TESTS=true phpunit
# If fails: DO NOT PROCEED
```

**Checkpoint 4: Quality Review** (Manual approval required)
```
Human must approve PR before merge
```

This knowledge base is used by all sub-skills for intelligent decision-making.
