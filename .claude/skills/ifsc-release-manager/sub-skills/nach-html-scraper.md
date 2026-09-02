# NACH HTML Scraper Sub-Skill

## Purpose
Scrape NPCI NACH live members HTML page to extract bank metadata, detect sublet arrangements, and generate `banks.json` and `sublet.json`.

## When to Use
- At the start of every release workflow (before IFSC parsing)
- When NPCI updates member bank list
- To validate UPI-enabled banks count

## Data Sources

### 1. NACH Live Members
**URL**: https://www.npci.org.in/what-we-do/nach/live-members/live-banks

**Table Structure**:
```
| S.No | Bank Name | IIN | MICR | IFSC Code | ACH Credit | ACH Debit | Sub Member |
|------|-----------|-----|------|-----------|------------|-----------|------------|
| 1    | SBI       | 607 | 400002 | SBIN0XXXXXX | ✓ | ✓ | - |
```

### 2. UPI Live Members (for cross-validation)
**URL**: https://www.npci.org.in/what-we-do/upi/live-members

## ⚠️ Bot Protection Challenge

### Current Status
```bash
# Downloads are disabled for now, since NPCI setup Bot protection at their end.
# - bootstrap.sh line 8
```

### Workaround Strategies

**Option 1: Use Cached HTML** (Current)
- Keep `nach.html` and `upi.html` in repository
- Update manually when NPCI changes

**Option 2: Browser Automation**
```python
from playwright import sync_api

browser = sync_api.sync_playwright().start().chromium.launch()
page = browser.new_page()
page.goto('https://www.npci.org.in/what-we-do/nach/live-members/live-banks')
page.wait_for_selector('table')
html = page.content()
```

**Option 3: Jina AI Reader**
```bash
curl "https://r.jina.ai/https://www.npci.org.in/what-we-do/nach/live-members/live-banks" \
  -H "Authorization: Bearer YOUR_JINA_KEY"
```

**Option 4: Human-in-Loop**
- Notify team when bot protection detected
- Request manual HTML download
- Continue with cached version

## Parsing Logic

### Step 1: Extract Table Data

**Using Nokogiri** (Current Ruby approach):
```ruby
doc = Nokogiri::HTML(File.read('nach.html'))
table = doc.css('table').first
rows = table.css('tbody tr')

banks = {}
rows.each do |row|
  cells = row.css('td')
  bank_code = extract_bank_code(cells[4].text) # IFSC
  banks[bank_code] = {
    name: cells[1].text.strip,
    iin: cells[2].text.strip,
    micr: cells[3].text.strip,
    ifsc: cells[4].text.strip,
    ach_credit: cells[5].text.include?('✓'),
    ach_debit: cells[6].text.include?('✓'),
    sub_member: cells[7].text.strip
  }
end
```

**Using AI Vision** (Fallback for dynamic tables):
```
Prompt: "Extract all rows from this NPCI NACH table as JSON.
Include: Bank Name, IIN, MICR, IFSC, ACH Credit, ACH Debit, Sub Member.
Return as array of objects."
```

### Step 2: Detect Sublet Arrangements

**Definition**: Banks that use another bank's infrastructure.

**Detection Patterns**:

1. **Explicit Sub-Member Column**
   - "Sub member of Bank of Baroda"
   - "Sponsored by HDFC Bank"

2. **IFSC Range Patterns**
   ```
   Bank: Satara Sahakari Bank
   IFSC Range: YESB0TSS*
   → Sublet of YES Bank (YESB)
   ```

3. **Shared IIN**
   ```
   Bank A: IIN 607
   Bank B: IIN 607
   → Bank B is sublet of Bank A
   ```

**Output**: `data/sublet.json`
```json
{
  "YESB0TSS001": "SATARA SAHAKARI BANK",
  "YESB0TSS002": "SATARA SAHAKARI BANK",
  "HDFC0CNMSBL": "MEHSANA NAGARIK SAHAKARI BANK"
}
```

### Step 3: Generate banks.json

**Format**:
```json
{
  "SBIN": {
    "name": "State Bank of India",
    "iin": "607",
    "micr": "400002",
    "type": "PSB",
    "ifsc": "SBIN0XXXXXX",
    "upi": true,
    "ach_credit": true,
    "ach_debit": true,
    "imps": true,
    "nach": true
  }
}
```

**Bank Type Classification** (from patches):
- PSB: Public Sector Banks
- Private: Private Banks
- RRB: Regional Rural Banks
- SCB: Scheduled Commercial Banks
- UCB: Urban Co-operative Banks
- Foreign: Foreign Banks
- SFB: Small Finance Banks
- PB: Payment Banks

## Cross-Validation with UPI List

### Step 4: Validate UPI Count

**Critical Validation**:
```ruby
upi_banks_from_html = parse_upi_html('upi.html')
upi_banks_from_patch = YAML.load('src/patches/banks/upi-enabled-banks.yml')

if upi_banks_from_html.count != upi_banks_from_patch.count
  puts "ERROR: UPI bank count mismatch!"
  puts "HTML: #{upi_banks_from_html.count}"
  puts "Patch: #{upi_banks_from_patch.count}"
  exit 1  # FAIL BUILD
end
```

**Why Critical**: UPI is a live payment system; incorrect bank list can cause transaction failures.

## Handling HTML Changes

### Common Failures

**1. Table Structure Changed**
```
Old: <table class="data-table">
New: <div class="table-responsive"><table>
```

**Solution**: Use multiple selectors or AI vision.

**2. JavaScript-Rendered Table**
```
HTML contains: <div id="react-root"></div>
Table loads via React
```

**Solution**: Use browser automation (Playwright/Puppeteer).

**3. Pagination Added**
```
Banks split across multiple pages
```

**Solution**: Detect "Next" button, scrape all pages.

## Merge with Custom Sublets

**File**: `src/custom-sublets.json`

Contains manually maintained sublet patterns:
```json
{
  "BARB0AIRCEL": "Airtel Payments Bank via Bank of Baroda",
  "PYTM0123456": "Paytm Payments Bank"
}
```

**Merge Logic**:
```python
final_sublets = {
  **auto_detected_sublets,  # From NPCI
  **custom_sublets          # Manual overrides
}
```

## Output Files

1. **`data/banks.json`** (300KB)
   - 1,346 banks with metadata
   - Bank type classification
   - Payment system capabilities

2. **`data/sublet.json`** (28KB)
   - IFSC → Sublet bank mapping
   - ~500-800 sublet IFSCs

## Error Handling

**NPCI Website Down**:
```
→ Use cached HTML from previous run
→ Log warning: "Using cached NACH data from [date]"
→ Continue with stale data (better than failure)
```

**Parsing Failure**:
```
→ Fall back to AI vision
→ If AI fails, use previous release banks.json
→ Flag for manual review
```

**UPI Count Mismatch**:
```
→ Exit with error (DO NOT CONTINUE)
→ Notify team immediately
→ Requires manual investigation
```

## Success Criteria

- ✅ 1,300-1,400 banks parsed
- ✅ UPI bank count matches patch file
- ✅ All bank codes are 4 letters
- ✅ Sublet detection finds 500+ entries
- ✅ No duplicate bank codes

## Performance Targets

- Parse HTML in <10 seconds
- Detect sublets in <5 seconds
- Generate banks.json in <2 seconds

## Integration Point

**Called First** in the workflow:
```
1. nach-html-scraper → banks.json, sublet.json
2. imps-generator (needs banks.json)
3. rtgs-data-parser
4. ifsc-data-extractor (NEFT)
```
