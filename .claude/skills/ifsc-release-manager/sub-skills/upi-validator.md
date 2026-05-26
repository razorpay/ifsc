# UPI Validator Sub-Skill

## Purpose
**CRITICAL VALIDATION**: Verify that UPI-enabled banks count matches NPCI website. Fails the build if mismatch detected.

## Why This is Critical

From `methods_nach.rb:60-64`:
```ruby
if (data['banks'].size + branch_data['ifsc'].size) != count
  log "Number of UPI-enabled banks in code does not match NPCI website", :critical
  log "Please check NPCI and update src/patches/banks/upi-enabled-banks.yml", :debug
  exit 1  # ← BUILD FAILS
end
```

**This is a safety check**: Prevents releasing with stale UPI data.

## AI-Driven Approach

### ❌ Old Way (HTML Scraping Script)
```ruby
doc = Nokogiri::HTML(open('upi.html'))
valid_banks = doc.css('table>tbody')[0].css('tr').map { ... }
# Breaks when NPCI changes HTML structure
```

### ✅ New Way (AI Vision + Validation)

## Execution Flow

### Step 1: Fetch NPCI UPI Page

```
WebFetch: https://www.npci.org.in/what-we-do/upi/live-members

Extract:
- List of all UPI-enabled banks
- Exclude PPI (Prepaid Payment Instrument) issuers
- Count unique banks

If page has bot protection:
  - Use browser automation
  - Or read cached HTML (nach.html, upi.html)
```

### Step 2: Parse Using AI Vision

```
I see this HTML table visually:

| S.No | Bank Name | Type | Launch Date |
|------|-----------|------|-------------|
| 1    | HDFC Bank | Bank | 01-Jan-2016 |
| 2    | ICICI Bank | Bank | 01-Jan-2016 |
| 3    | Paytm Payments Bank | PPI Issuer | ... |
| ...  | ...       | ...  | ...         |

Filter out:
- Rows where Type = "PPI Issuer"
- Duplicate bank names

Count: 156 unique banks
```

### Step 3: Load Patch Files

```
Read: src/patches/banks/upi-enabled-banks.yml

Content:
banks:
  - HDFC
  - ICIC
  - SBIN
  - PUNB
  ... (total: 140 banks)

Read: src/patches/ifsc/upi-enabled-branches.yml

Content:
ifsc:
  - HDFC0001234  # Specific branch has UPI
  - ICIC0005678  # Another branch-level UPI
  ... (total: 16 branches)

Our count: 140 banks + 16 branches = 156
```

### Step 4: Cross-Validate

```
NPCI website count: 156
Our patch files count: 140 + 16 = 156

✅ Match! Validation passed.
```

### Step 5: If Mismatch Detected

```
NPCI website count: 158
Our patch files count: 156

❌ MISMATCH!

Analysis:
- NPCI has 2 more banks than our patches
- Let me identify which banks are missing...

Compare bank names:
NPCI banks: [HDFC, ICIC, ... AU Small Finance, Bandhan Bank]
Our banks: [HDFC, ICIC, ... AU Small Finance]

Missing: Bandhan Bank, Jana Small Finance Bank

Decision: FAIL BUILD
Reason: UPI data is stale. Need manual review.

Actions:
1. Create GitHub issue:
   Title: "UPI validation failed: 2 new banks detected"
   Body: "NPCI added: Bandhan Bank, Jana Small Finance Bank
          Please verify and update:
          - src/patches/banks/upi-enabled-banks.yml"

2. Notify team on Slack:
   "🚨 UPI Validation Failed
    NPCI website shows 158 UPI banks, we have 156
    Missing: Bandhan Bank, Jana Small Finance Bank
    Build stopped. Manual review required."

3. Exit with error code 1
```

## AI Advantages

### 1. Intelligent Bank Name Matching

```
NPCI says: "HDFC Bank Limited"
Our patch says: "HDFC"

AI understands these are the same bank.

Script would require exact string match → false negative
```

### 2. Detect Bank Mergers

```
Scenario:
NPCI count: 155 (down from 156)
Our count: 156

AI analysis:
"I notice NPCI removed 'Lakshmi Vilas Bank'
 but added 'DBS Bank India'

 Cross-checking news:
 Lakshmi Vilas Bank merged with DBS in 2020

 This is expected, not a mismatch.

 Recommendation:
 - Remove LVCB from upi-enabled-banks.yml
 - Verify DBS is added

 Confidence: 95%"
```

### 3. Handle Page Format Changes

```
Scenario: NPCI changes from HTML table to JSON API

Old script: FAILS (Nokogiri can't parse JSON)

AI: "I see the page now returns JSON instead of HTML.
     Let me parse the JSON...

     {
       "upi_banks": [
         {"name": "HDFC Bank", "type": "bank"},
         ...
       ]
     }

     Extracted 156 banks. ✓"
```

### 4. Suggest Patch Updates

```
If mismatch detected:

AI: "I found 2 missing banks. Let me draft the YAML update:

     --- src/patches/banks/upi-enabled-banks.yml
     +++ src/patches/banks/upi-enabled-banks.yml
     @@ -138,6 +138,8 @@
      - AIRP  # Airtel Payments Bank
      - AUBL  # AU Small Finance Bank
     +- BDBL  # Bandhan Bank
     +- JSFB  # Jana Small Finance Bank

     Should I create a PR with this change? (Requires human approval)"
```

## Workflow Integration

### Success Path
```
1. upi-validator runs FIRST (before any data extraction)
2. Validation passes ✓
3. Proceed to nach-html-scraper
4. Apply UPI flags during dataset merge
```

### Failure Path
```
1. upi-validator detects mismatch
2. Create GitHub issue with details
3. Notify team on Slack
4. EXIT BUILD (do not proceed)
5. Wait for human to update patch files
6. Human updates upi-enabled-banks.yml
7. Human re-triggers build
8. Validation passes ✓
9. Continue workflow
```

## Return Format

### Success
```json
{
  "status": "PASS",
  "npci_count": 156,
  "our_count": 156,
  "banks_count": 140,
  "branches_count": 16,
  "validated_at": "2025-01-17T09:01:30Z",
  "source_url": "https://www.npci.org.in/what-we-do/upi/live-members"
}
```

### Failure
```json
{
  "status": "FAIL",
  "npci_count": 158,
  "our_count": 156,
  "difference": 2,
  "missing_banks": ["Bandhan Bank", "Jana Small Finance Bank"],
  "suggested_codes": ["BDBL", "JSFB"],
  "patch_file": "src/patches/banks/upi-enabled-banks.yml",
  "issue_created": "#448",
  "slack_notified": true,
  "build_aborted": true
}
```

## Safety Features

1. **Mandatory first step**: UPI validation runs before data extraction
2. **Fail-fast**: Exit immediately on mismatch (don't waste time on rest of pipeline)
3. **Human-in-loop**: Require manual patch update (prevents auto-accepting wrong data)
4. **Audit trail**: Create issue + Slack notification (team knows why build failed)
5. **Rollback safe**: Old release still works if new build fails

## Usage

**Agent invokes**:
```
Starting IFSC release workflow...

Step 1 (CRITICAL): Validate UPI banks using upi-validator

[Executes AI-driven validation]

Result: ✅ PASS
NPCI: 156 banks
Our patches: 156 banks (140 + 16 branches)
Validation successful.

Proceeding to data extraction...
```

**Or on failure**:
```
Step 1 (CRITICAL): Validate UPI banks using upi-validator

[Executes AI-driven validation]

Result: ❌ FAIL
NPCI: 158 banks (+2 from last check)
Our patches: 156 banks
Missing: Bandhan Bank, Jana Small Finance Bank

Actions taken:
- Created issue #448
- Notified #tech_ifsc on Slack
- Build aborted

WORKFLOW STOPPED. Manual intervention required.
```

## Why AI is Superior

| Aspect | Script | AI |
|--------|--------|---|
| HTML changes | Breaks | Adapts |
| Bank name variations | Exact match only | Fuzzy matching |
| Merger detection | Manual investigation | Automatic analysis |
| Suggested fixes | None | Draft YAML updates |
| Error messages | Generic | Contextual with reasoning |

This validation ensures we NEVER release with stale UPI data—a critical requirement for payment systems.
