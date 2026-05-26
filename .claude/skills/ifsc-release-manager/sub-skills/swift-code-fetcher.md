# SWIFT Code Fetcher Sub-Skill

## Purpose
Extract SWIFT/BIC codes from bank PDFs and websites, validate against patch files, and map to IFSC codes.

## What are SWIFT Codes?

**SWIFT** = Society for Worldwide Interbank Financial Telecommunication
- Used for international wire transfers
- Format: 8 or 11 characters (e.g., SBININBB123)
- Not all Indian branches have SWIFT codes (only international branches)

## Supported Banks

### 1. State Bank of India (SBI)
**Source**: https://sbi.co.in/web/nri/quick-links/swift-codes
**Patch**: `src/patches/ifsc/sbi-swift.yml`
**Branches**: ~600 SBI branches with SWIFT codes

### 2. Punjab National Bank (PNB)
**Source**: PNB website branch locator
**Patch**: `src/patches/ifsc/pnb-swift.yml`
**Branches**: ~200 PNB branches with SWIFT codes

### 3. HDFC Bank
**Source**: HDFC branch locator API
**Patch**: `src/patches/ifsc/hdfc-swift.yml`
**Branches**: ~150 HDFC branches with SWIFT codes

## Workflow

### Step 1: Fetch SWIFT Data

**Option A: Web Scraping**
```python
from playwright import sync_api

page = browser.new_page()
page.goto('https://sbi.co.in/web/nri/quick-links/swift-codes')
table = page.query_selector('table.swift-codes')
rows = table.query_selector_all('tr')

swift_data = []
for row in rows:
    cells = row.query_selector_all('td')
    swift_data.append({
        'branch': cells[0].text_content(),
        'city': cells[1].text_content(),
        'swift': cells[2].text_content()
    })
```

**Option B: AI Vision** (for PDFs)
```
Prompt: "Extract all SWIFT codes from this SBI PDF.
Return as JSON with: branch name, city, SWIFT code, IFSC (if mentioned)."
```

**Option C: Use Cached Data** (Current)
```ruby
# Use existing patch files
sbi_swift = YAML.load('src/patches/ifsc/sbi-swift.yml')
```

### Step 2: Validate SWIFT Code Format

**Format Rules**:
- Length: 8 or 11 characters
- Structure: `BBBBCCLLBBB`
  - BBBB: Bank code (4 letters)
  - CC: Country code (2 letters, "IN" for India)
  - LL: Location code (2 characters)
  - BBB: Branch code (3 characters, optional)

**Examples**:
- `SBININBB` (8 chars - head office)
- `SBININBB123` (11 chars - specific branch)

**Validation**:
```python
import re

def validate_swift(code):
    pattern = r'^[A-Z]{4}IN[A-Z0-9]{2}([A-Z0-9]{3})?$'
    return bool(re.match(pattern, code))
```

### Step 3: Map SWIFT to IFSC

**Challenge**: SWIFT doesn't directly map to IFSC

**Matching Strategies**:

1. **Exact Match (if IFSC in source)**
   ```yaml
   SBIN0000001:
     SWIFT: SBININBB001
   ```

2. **Branch Name + City Matching**
   ```
   SWIFT: Branch="Mumbai Main", City="Mumbai"
   → Search IFSC for: SBIN + "Mumbai Main"
   → Match: SBIN0000001
   ```

3. **MICR Code Matching**
   ```
   SWIFT: MICR=400002002
   IFSC: SBIN0000001 has MICR=400002002
   → Map: SBIN0000001 → SBININBB001
   ```

4. **Manual Mapping** (patch file)
   ```yaml
   # src/patches/ifsc/sbi-swift.yml
   ifsc:
     SBIN0000001:
       SWIFT: SBININBB001
     SBIN0000002:
       SWIFT: SBININBB002
   ```

### Step 4: Cross-Validate with Patch Files

**Critical Validation** (like `validate_sbi_swift()`):

```ruby
def validate_sbi_swift
  # Get SWIFT codes from website
  website_bics = scrape_sbi_swift_codes()

  # Get SWIFT codes from patch file
  patch_bics = YAML.load('src/patches/ifsc/sbi-swift.yml')['ifsc']
                   .values
                   .map { |x| x['SWIFT'] }
                   .to_set

  # Check for missing codes
  missing = website_bics - patch_bics

  if missing.any?
    puts "WARNING: #{missing.size} SWIFT codes missing from patch:"
    puts missing.inspect
    # Exit or flag for review
  end
end
```

**Why Important**:
- SWIFT codes change when branches close/merge
- Missing SWIFT = failed international transfers
- Must keep patch files up-to-date

## Handling Website Changes

### SBI Website Archive Workaround

**Current Code**:
```ruby
doc = Nokogiri::HTML(
  URI.open("https://web.archive.org/https://sbi.co.in/hi/web/nri/quick-links/swift-codes")
)
```

**Why Web Archive?**
- SBI website may have SSL issues
- Archive provides stable snapshot
- Avoids bot protection

**Fallback Strategy**:
1. Try live website
2. If fails, try web.archive.org
3. If both fail, use patch file (stale data acceptable)

### PNB/HDFC APIs

**PNB Branch Locator**:
```
GET https://www.pnbindia.in/branch-locator?city=Mumbai
Response: JSON with IFSC, SWIFT, address
```

**HDFC Branch Locator**:
```
GET https://www.hdfcbank.com/branch-atm-locator/
Response: JSON with branch details including SWIFT
```

## Patch File Format

### Example: `sbi-swift.yml`

```yaml
# SBI SWIFT Code Mapping
ifsc:
  SBIN0000001:
    SWIFT: SBININBB001
    BRANCH: Mumbai Main Branch
    CITY: Mumbai
  SBIN0000002:
    SWIFT: SBININBB002
    BRANCH: New Delhi Main Branch
    CITY: New Delhi
  # ... ~600 entries
```

### Example: `hdfc-swift.yml`

```yaml
# HDFC SWIFT Code Mapping (bank-level, not branch-level)
bank:
  HDFC:
    SWIFT: HDFCINBB
    NOTE: "All HDFC branches use HDFCINBB for SWIFT transfers"
```

**Why Different?**
- SBI: Branch-specific SWIFT codes
- HDFC: Single SWIFT code for all branches

## Error Handling

### Website Unreachable
```
→ Retry 3 times with exponential backoff
→ Try web.archive.org
→ Fall back to existing patch file
→ Log warning: "Using cached SWIFT data"
```

### SSL Certificate Issues
```
→ Use web.archive.org
→ Or use `curl -k` (insecure, but acceptable for public data)
```

### Format Changed
```
→ AI vision can adapt to new table layouts
→ Compare column count with expected
→ Flag for manual review if major changes
```

### Validation Failures
```
if missing_swift_codes.size > 10
  → Exit with error
  → Notify team
  → Requires manual investigation
end
```

## Integration with Main Workflow

**Called Early** (before IFSC parsing):

```
1. nach-html-scraper
2. swift-code-fetcher ← Validates SWIFT data
3. imps-generator
4. rtgs-data-parser
5. ifsc-data-extractor
```

**Why Early**: Validation can fail the build if critical SWIFT codes missing.

## Output

**Primary**: Validation report
**Secondary**: Updated patch files (if new SWIFT codes found)

**Report Format**:
```
=== SBI SWIFT Validation ===
Website: 612 codes
Patch: 608 codes
Missing: 4 codes
  - SBININBB789 (Mumbai Fort Branch)
  - SBININBB790 (Delhi Connaught Place)
  - ...

Action Required: Update sbi-swift.yml
```

## Success Criteria

- ✅ All banks validated (SBI, PNB, HDFC)
- ✅ Zero missing SWIFT codes (or <5 acceptable)
- ✅ All SWIFT codes match format
- ✅ Patch files are current

## Performance Targets

- Scrape SBI website in <30 seconds
- Validate 600+ codes in <5 seconds
- Exit fast on validation failure

## Future Enhancements

### More Banks
- ICICI Bank
- Axis Bank
- Bank of Baroda
- Canara Bank

### Automated Patch Updates
```
if new_swift_codes.any?
  → Update patch YAML automatically
  → Create PR with changes
  → Request human review
end
```

### International Branch Detection
```
Using AI, identify:
- "NRI Branch"
- "Foreign Exchange Branch"
- "International Banking Branch"
→ These likely have SWIFT codes
```

## Related Files

- `src/patches/ifsc/sbi-swift.yml` - SBI SWIFT mappings
- `src/patches/ifsc/pnb-swift.yml` - PNB SWIFT mappings
- `src/patches/ifsc/hdfc-swift.yml` - HDFC SWIFT mappings
- `scraper/scripts/methods.rb:472` - `validate_sbi_swift()` function
