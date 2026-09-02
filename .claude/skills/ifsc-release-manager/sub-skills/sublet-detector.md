# Sublet Detector Sub-Skill (Enhanced)

## Purpose
Auto-detect sublet arrangements (smaller banks using larger banks' infrastructure) from NPCI NACH data and merge with custom sublet mappings.

## What is a Sublet Arrangement?

**Definition**: When a small bank uses another bank's payment infrastructure instead of building their own.

**Example**:
```
Bank: Satara Sahakari Bank
IFSC Range: YESB0TSS*
→ Uses YES Bank's infrastructure
→ "Sublet of YES Bank"
```

**Why Important**:
- Affects routing logic for payments
- Determines which bank processes the transaction
- Required for correct settlement

## When to Use
- During NACH HTML parsing (auto-detection)
- After banks.json generation
- Before final dataset export
- When new sublet arrangements are announced

## Detection Sources

### 1. NACH "Sub Member" Column
**Source**: NPCI NACH live members HTML table

**Table Structure**:
```
| S.No | Bank Name | IIN | MICR | IFSC Code | ACH Credit | ACH Debit | Sub Member |
|------|-----------|-----|------|-----------|------------|-----------|------------|
| 245  | Satara Bank | 608 | 415002 | YESB0TSS* | ✓ | ✓ | Sub member of YES Bank |
```

**Detection Patterns**:
1. **Explicit Text**:
   - "Sub member of [Bank Name]"
   - "Sponsored by [Bank Name]"
   - "Associate of [Bank Name]"

2. **Empty But Using Another's IFSC**:
   ```
   Bank: ABC Co-op Bank
   IFSC: HDFC0ABC*
   → Sublet of HDFC (IFSC starts with HDFC, not ABC)
   ```

**Extraction Logic**:
```ruby
def detect_sublets_from_nach(nach_html)
  doc = Nokogiri::HTML(nach_html)
  table = doc.css('table').first
  sublets = {}

  table.css('tbody tr').each do |row|
    cells = row.css('td')
    bank_name = cells[1].text.strip
    ifsc_range = cells[4].text.strip
    sub_member_text = cells[7].text.strip

    # Pattern 1: Explicit sub member text
    if sub_member_text.match(/sub member of (.*)/i)
      sponsor_bank = $1.strip
      sublets[ifsc_range] = {
        'bank' => bank_name,
        'sponsor' => sponsor_bank,
        'type' => 'explicit'
      }
    end

    # Pattern 2: IFSC mismatch (using another bank's code)
    bank_code_from_ifsc = ifsc_range[0..3]
    expected_bank_code = derive_bank_code(bank_name)

    if bank_code_from_ifsc != expected_bank_code
      sponsor_bank = bank_name_from_code(bank_code_from_ifsc)
      sublets[ifsc_range] = {
        'bank' => bank_name,
        'sponsor' => sponsor_bank,
        'type' => 'ifsc_mismatch'
      }
    end
  end

  sublets
end
```

### 2. Shared IIN (Issuer Identification Number)
**Indicator**: Multiple banks sharing the same IIN

**Example**:
```
Bank A: State Bank of India | IIN: 607
Bank B: State Bank of Bikaner | IIN: 607
→ Bank B merged into Bank A (uses same IIN)
```

**Detection**:
```ruby
def detect_shared_iin(banks_data)
  iin_map = Hash.new { |h, k| h[k] = [] }

  banks_data.each do |code, info|
    iin_map[info[:iin]] << code
  end

  shared_iin = iin_map.select { |iin, banks| banks.size > 1 }

  shared_iin.map do |iin, banks|
    # Assume first bank is parent, others are sublets
    parent = banks.first
    banks[1..-1].map { |sublet| [sublet, parent] }
  end.flatten(1).to_h
end
```

### 3. IFSC Range Patterns
**Common Patterns**:

```
YESB0TSS* → Satara Sahakari Bank (sublet of YES Bank)
YESB0CMSK* → Mehsana Nagarik Sahakari Bank (sublet of YES Bank)
HDFC0CNMSBL* → Nutan Mahila Sahakari Bank (sublet of HDFC)
BARB0AIRCEL* → Airtel Payments Bank (sublet of Bank of Baroda)
```

**Detection**:
```ruby
def detect_ifsc_range_sublets(ifsc_list, banks)
  sublets = {}

  ifsc_list.each do |ifsc|
    bank_code = ifsc[0..3]
    branch_code = ifsc[5..10]

    # Check if branch code indicates sublet
    if branch_code.match(/^[A-Z]{3,6}/)  # Non-numeric branch code
      # Likely a sublet with custom prefix
      bank_name = derive_bank_name_from_branch_code(branch_code)
      if bank_name
        sublets[ifsc] = bank_name
      end
    end
  end

  sublets
end
```

## Custom Sublet Mappings

### File: `src/custom-sublets.json`
**Manually maintained** sublet patterns that auto-detection misses:

```json
{
  "BARB0AIRCEL": "Airtel Payments Bank via Bank of Baroda",
  "PYTM0123456": "Paytm Payments Bank",
  "HDFC0CNMSBL": "Mehsana Nagarik Sahakari Bank",
  "YESB0TSS001": "Satara Sahakari Bank",
  "YESB0CMSK01": "Kallappanna Awade Ichalkaranji Janata Sahakari Bank",
  "FINO0000001": "FINO Payments Bank"
}
```

**Why Manual?**:
- Payment banks often have non-obvious arrangements
- Historical sublets not in current NACH table
- RBI announces new sublets before NPCI updates HTML

### Merge Logic
```ruby
def merge_sublets(auto_detected, custom_sublets)
  # Custom sublets take priority (they're verified by humans)
  final_sublets = auto_detected.merge(custom_sublets) do |key, auto, custom|
    log "Overriding auto-detected sublet for #{key}: #{auto} → #{custom}", :info
    custom  # Use custom mapping
  end

  final_sublets
end
```

## Output Format

### File: `data/sublet.json`
```json
{
  "YESB0TSS001": "Satara Sahakari Bank",
  "YESB0TSS002": "Satara Sahakari Bank",
  "YESB0CMSK01": "Kallappanna Awade Bank",
  "HDFC0CNMSBL": "Mehsana Nagarik Sahakari Bank",
  "BARB0AIRCEL": "Airtel Payments Bank",
  "PYTM0123456": "Paytm Payments Bank"
}
```

**Usage**:
```ruby
def bank_name_from_code(ifsc)
  # Check if it's a sublet
  if SUBLETS.key?(ifsc)
    return SUBLETS[ifsc]
  end

  # Otherwise, derive from bank code
  bank_code = ifsc[0..3]
  BANK_NAMES[bank_code]
end
```

## Integration with Dataset Generation

### Applied During Merge
```ruby
def merge_dataset(neft, rtgs, imps)
  # ... merging logic ...

  combined_data['BANK'] = bank_name_from_code(combined_data['IFSC'])
  # ↑ This function uses sublet.json to set correct bank name
end
```

**Effect**: IFSC `YESB0TSS001` gets:
```json
{
  "IFSC": "YESB0TSS001",
  "BANK": "Satara Sahakari Bank",  // NOT "YES Bank"
  ...
}
```

## Validation

### Check for Missing Sublets
```ruby
def validate_sublet_coverage(dataset, sublets)
  non_standard_ifsc = dataset.keys.select do |ifsc|
    branch_code = ifsc[5..10]
    branch_code.match(/^[A-Z]{3,}/)  # Alphabetic branch codes
  end

  non_standard_ifsc.each do |ifsc|
    unless sublets.key?(ifsc)
      log "WARNING: Possible sublet not mapped: #{ifsc}", :warn
    end
  end
end
```

### Cross-Check with NPCI Updates
```ruby
def check_npci_changes(current_sublets, previous_sublets)
  new_sublets = current_sublets.keys - previous_sublets.keys
  removed_sublets = previous_sublets.keys - current_sublets.keys

  if new_sublets.any?
    log "=== New Sublet Arrangements Detected ==="
    new_sublets.each { |ifsc| log "  + #{ifsc}: #{current_sublets[ifsc]}" }
  end

  if removed_sublets.any?
    log "=== Sublets Removed (Bank Closures?) ==="
    removed_sublets.each { |ifsc| log "  - #{ifsc}: #{previous_sublets[ifsc]}" }
  end
end
```

## Edge Cases

### 1. Bank Mergers
**Scenario**: State Bank of Patiala merged into State Bank of India

**Before Merger**:
```
STBP0000001 → State Bank of Patiala
```

**After Merger**:
```
STBP0000001 → State Bank of India (sublet)
```

**Detection**: IIN changes from unique to shared.

### 2. Payment Banks
**Challenge**: Payment banks (Paytm, Airtel, FINO) always use sponsor banks

**Indicators**:
- IFSC range uses sponsor's code
- NACH table explicitly lists sponsor
- Bank type = "Payment Bank"

**Example**:
```
Bank: Paytm Payments Bank
IFSC: PYTM0123456
Sponsor: Listed in NACH as "Sub member of XYZ Bank"
```

### 3. Temporary Sublets
**Scenario**: Bank's systems down, temporarily routing via another bank

**Detection**:
- Not in NACH table permanently
- RBI circular announcement
- Requires manual patch

### 4. White-Label ATMs
**Note**: ATMs are NOT sublets, they're separate entities

**Distinction**:
- Sublet: Uses sponsor's **payment infrastructure**
- White-label ATM: Uses sponsor's **ATM network** only

## Error Handling

### NACH Table Unavailable
```
→ Fall back to previous release's sublet.json
→ Log warning: "Using cached sublet data"
→ Flag for manual review when NACH is accessible
```

### Conflicting Sublet Data
```
Auto-detected: YESB0TSS* → Bank A
Custom mapping: YESB0TSS* → Bank B

→ Use custom mapping (human-verified)
→ Log conflict for review
```

### Missing Sublet Bank Name
```
Detected sublet but can't find sponsor bank name

→ Mark as "UNKNOWN_SUBLET"
→ Add to manual review queue
→ Acceptable: <5 unknown sublets
```

## Success Criteria

- ✅ 500-800 sublet IFSCs detected
- ✅ All payment banks identified as sublets
- ✅ Custom sublets override auto-detected
- ✅ Zero conflicts in final sublet.json
- ✅ All sublet banks have correct BANK field

## Performance

**Detection Time**: <10 seconds
**Merge Time**: <1 second

## Output Statistics

**Report Format**:
```
=== Sublet Detection Summary ===
Auto-detected: 612 sublets
Custom mappings: 45 sublets
Conflicts resolved: 3 (custom took priority)

Top Sponsor Banks:
- YES Bank: 234 sublets
- HDFC Bank: 178 sublets
- Bank of Baroda: 89 sublets
- ICICI Bank: 67 sublets

Total sublets in dataset: 657
```

## Related Files

- `scraper/scripts/methods.rb:358` - `bank_name_from_code()` function
- `.claude/skills/ifsc-release-manager/sub-skills/nach-html-scraper.md:95-127` - Detection logic
- `src/custom-sublets.json` - Manual sublet mappings
- `data/sublet.json` - Generated output

## Future Enhancements

### API Integration
```ruby
# Check NPCI API for real-time sublet updates
def fetch_live_sublets
  response = HTTP.get('https://npci.org.in/api/sublet-members')
  JSON.parse(response.body)
end
```

### Automated Custom Sublet Updates
```ruby
# When new sublet detected, create PR to update custom-sublets.json
if new_sublets.any?
  update_custom_sublets_file(new_sublets)
  create_pr_for_review('Add new sublet arrangements')
end
```

### Historical Tracking
```json
{
  "YESB0TSS001": {
    "current": "Satara Sahakari Bank",
    "sponsor": "YES Bank",
    "since": "2018-03-15",
    "until": null
  }
}
```
