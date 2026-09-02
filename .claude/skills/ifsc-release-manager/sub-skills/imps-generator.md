# IMPS Generator Sub-Skill

## Purpose
Generate virtual IMPS branch entries for banks that support Immediate Payment Service (IMPS).

## What is IMPS?

**IMPS** = Immediate Payment Service
- 24x7 instant fund transfer system
- Mobile-first payment method
- Each bank has ONE virtual IMPS branch (not physical)
- Uses special IFSC code format

## When to Use
- After `banks.json` is generated from NACH scraper
- Before merging NEFT/RTGS data
- When adding new IMPS-enabled banks

## Input

**Required**: `banks.json` with IMPS capability flags

```json
{
  "SBIN": {
    "name": "State Bank of India",
    "imps": true,
    "upi": true
  },
  "HDFC": {
    "name": "HDFC Bank",
    "imps": true,
    "upi": true
  }
}
```

## Generation Logic

### Step 1: Filter IMPS-Enabled Banks

```ruby
imps_banks = banks.select { |code, info| info[:imps] == true }
```

### Step 2: Generate Virtual IFSC Code

**Format**: `BANK0XXXXXX` where last 6 digits form special pattern

**Examples**:
- SBI: `SBIN0IMPS01` or similar
- HDFC: `HDFC0IMPS01`

**Current Implementation**: Uses actual IFSC from banks.json
```ruby
banks.each do |code, row|
  next unless row[:ifsc] && row[:ifsc].strip.to_s.length == 11
  # row[:ifsc] is the IMPS virtual branch IFSC
end
```

### Step 3: Create Virtual Branch Entry

**Standard Template**:
```json
{
  "SBIN0IMPS01": {
    "BANK": "State Bank of India",
    "IFSC": "SBIN0IMPS01",
    "BRANCH": "State Bank of India IMPS",
    "CENTRE": "NA",
    "DISTRICT": "NA",
    "STATE": "MAHARASHTRA",
    "ADDRESS": "NA",
    "CONTACT": null,
    "IMPS": true,
    "UPI": true,
    "CITY": "MUMBAI",
    "MICR": null,
    "RTGS": false,
    "NEFT": false
  }
}
```

**Key Fields**:
- **BANK**: From banknames.json
- **BRANCH**: "{Bank Name} IMPS"
- **CITY**: "MUMBAI" (NPCI HQ)
- **STATE**: "MAHARASHTRA"
- **ADDRESS/CENTRE/DISTRICT**: "NA" (virtual branch)
- **CONTACT**: null
- **IMPS**: true
- **UPI**: Copy from banks.json
- **RTGS/NEFT**: false (IMPS-only branch)

## Handling UPI Flag

**Logic**: If bank supports both IMPS and UPI, mark UPI=true

```ruby
'UPI' => banks[code][:upi] ? true : false
```

**Why**: IMPS and UPI often go together (mobile payments).

## Disabled IMPS Banks

**Patch File**: `src/patches/ifsc/disabled-imps.yml`

Some banks have IMPS disabled due to:
- Regulatory issues
- Technical problems
- Merger/closure

**Example**:
```yaml
# Banks with IMPS disabled
ifsc:
  UBINORRBKGS:
    IMPS: false
  BARBOBRGBXX:
    IMPS: false
```

**Application**:
```ruby
disabled_banks = load_patch('disabled-imps.yml')
imps_banks.reject! { |ifsc, _| disabled_banks.include?(ifsc) }
```

## Merge Priority

**IMPS data has LOWEST priority** in merge:

```
NEFT > RTGS > IMPS
```

**Why**: If a physical branch exists in NEFT/RTGS, use that instead of virtual IMPS branch.

**Example**:
```
NEFT has: SBIN0001234 (physical branch in Delhi)
IMPS generates: SBIN0001234 (virtual IMPS branch)
→ Keep NEFT entry, discard IMPS
```

## Output Format

**File**: Merged into final `data/IFSC.json`

**Count**: ~1,300 IMPS entries (one per bank)

**Statistics Tracking**:
```
Total banks: 1,346
IMPS-enabled: 1,298
Disabled via patch: 45
Final IMPS entries: 1,253
```

## Edge Cases

### 1. Bank Without IMPS Flag

```ruby
if row[:imps].nil?
  # Skip - not IMPS-enabled
  next
end
```

### 2. Invalid IFSC Length

```ruby
next unless row[:ifsc] && row[:ifsc].strip.to_s.length == 11
```

**Why**: IMPS IFSC must be exactly 11 characters.

### 3. Duplicate IFSC

If IMPS IFSC conflicts with real branch:
```
→ Skip IMPS entry
→ Log warning
→ Real branch takes precedence
```

### 4. Closed/Merged Banks

Banks in transition:
```yaml
# Example: State Bank of Hyderabad merged into SBI
SBBJ:
  merged_into: SBIN
  imps: false
```

**Solution**: Exclude from IMPS generation.

## Validation Rules

**Before Adding IMPS Entry**:
- ✅ Bank code is 4 uppercase letters
- ✅ IFSC is exactly 11 characters
- ✅ IFSC format: `BANK0XXXXXX`
- ✅ Bank exists in banknames.json
- ✅ IMPS flag is explicitly true
- ✅ Not in disabled-imps.yml

## Integration with Main Workflow

```ruby
# Workflow order:
1. nach-html-scraper → banks.json
2. imps-generator → imps_data
3. rtgs-data-parser → rtgs_data
4. ifsc-data-extractor → neft_data
5. merge_dataset(neft_data, rtgs_data, imps_data)
   # NEFT overwrites RTGS/IMPS
   # RTGS overwrites IMPS
```

## Error Handling

**Missing banks.json**:
```
→ Error: "banks.json not found"
→ Exit with code 1
→ Requires NACH scraper to run first
```

**Empty IMPS List**:
```
if imps_banks.empty?
  → Warning: "No IMPS-enabled banks found"
  → Check NACH scraper output
  → Verify banks.json format
end
```

**IFSC Conflicts**:
```
→ Log all conflicts
→ Count total conflicts
→ If >10 conflicts, flag for review
```

## Success Criteria

- ✅ 1,200-1,300 IMPS entries generated
- ✅ All IFSCs are valid format
- ✅ All cities are "MUMBAI"
- ✅ All states are "MAHARASHTRA"
- ✅ No duplicates in final merged dataset

## Performance Targets

- Generate 1,300 entries in <1 second
- Minimal memory overhead (virtual branches)
- Zero data loss from banks.json

## Output Files

**Direct**: `data/imps.json` (temporary)
**Final**: Merged into `data/IFSC.json`

## Why Virtual Branches?

**Physical Branches**: Have address, phone, MICR, physical location

**Virtual Branches**:
- No physical location
- Used for online/mobile banking only
- Centralized at NPCI HQ (Mumbai)
- Simplifies routing for IMPS transactions
