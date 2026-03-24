# Patch Applier Sub-Skill

## Purpose
Apply 20+ YAML patch files to override/enhance extracted IFSC data with manually curated corrections and metadata.

## Why Patches Are Needed

RBI/NPCI data is incomplete or incorrect. Patches fix:
1. **UPI support** - RBI doesn't track UPI, we maintain manually
2. **SWIFT codes** - Downloaded from bank PDFs, not in RBI data
3. **Bank types** - PSB/PVB/RRB classification missing from NPCI
4. **Disabled features** - Some branches have IMPS disabled
5. **State corrections** - RBI has typos/inconsistencies
6. **Invalid codes** - Known fraudulent/test IFSCs to filter

## Patch Categories

### Bank-Level Patches (`src/patches/banks/`)

**1. `upi-enabled-banks.yml`**
```yaml
banks:
  - HDFC  # HDFC Bank supports UPI
  - ICIC  # ICICI Bank supports UPI
  - SBIN  # State Bank of India supports UPI
  ...
```
**Effect**: Sets `upi: true` for these bank codes in `banks.json`

**2. `nach-debit-banks.yml`**
```yaml
banks:
  - PUNB  # Punjab National Bank supports NACH debit
  - BARB  # Bank of Baroda supports NACH debit
  ...
```
**Effect**: Sets `nach_debit: true` in `banks.json`

**3. `type-psb.yml`** (Public Sector Banks)
```yaml
banks:
  - SBIN  # State Bank of India
  - PUNB  # Punjab National Bank
  - CNRB  # Canara Bank
  ...
```
**Effect**: Sets `type: 'PSB'` in `banks.json`

**4. `type-private.yml`** (Private Banks)
```yaml
banks:
  - HDFC  # HDFC Bank
  - ICIC  # ICICI Bank
  - UTIB  # Axis Bank
  ...
```
**Effect**: Sets `type: 'PVB'` in `banks.json`

**5. `type-rrb.yml`** (Regional Rural Banks)
**6. `type-sfb.yml`** (Small Finance Banks)
**7. `type-scb.yml`** (Scheduled Commercial Banks)
**8. `type-lab.yml`** (Local Area Banks)

### IFSC-Level Patches (`src/patches/ifsc/`)

**1. `sbi-swift.yml`**
```yaml
SBIN0000001:
  swift: SBININBB  # State Bank SWIFT code
SBIN0000002:
  swift: SBININBB123
...
```
**Effect**: Adds SWIFT codes to specific SBI branches

**2. `hdfc-swift.yml`**, **`pnb-swift.yml`** - Same for other banks

**3. `upi-enabled-branches.yml`**
```yaml
ifsc:
  - HDFC0001234  # This specific branch supports UPI
  - ICIC0005678  # (even if bank doesn't fully support UPI)
```
**Effect**: Branch-level UPI override

**4. `disabled-imps.yml`**
```yaml
ifsc:
  - PUNB0023400  # IMPS disabled on this branch
  - SBIN0009876
```
**Effect**: Sets `imps: false` for these IFSCs

**5. `invalid-ifsc.yml`**
```yaml
ifsc:
  - TEST0000001  # Test code, not real
  - FAKE0001234  # Fraudulent code
```
**Effect**: Removes these from final dataset

**6. `neft-block.yml`**
```yaml
ifsc:
  - RBIS0000001  # RBI itself, NEFT disabled
```
**Effect**: Sets `neft: false`

**7. `state-mh.yml`**
```yaml
HDFC0001234:
  state: MAHARASHTRA  # Override incorrect state from RBI
```

**8. `SBIN0005181.yml`**, **`iccl.yml`**, **`xnse.yml`** - Special case corrections

**9. `no-imps-for-rbi.yml`** - RBI branches don't support IMPS

## AI-Driven Patch Application

### ❌ Old Way (Script)
```ruby
def apply_patches(dataset)
  patches = Dir['../../src/patches/ifsc/*.yml']
  patches.each do |file|
    data = YAML.safe_load(File.read(file))
    data['ifsc'].each do |ifsc|
      dataset[ifsc].merge!(data[ifsc]) if dataset[ifsc]
    end
  end
end
```

**Problems**:
- Hardcoded glob pattern
- No validation if patch makes sense
- No conflict detection between patches
- Silent failures if IFSC doesn't exist

### ✅ New Way (AI-Driven)

## Execution Flow

### Step 1: Discover Patches

```
Find all patch files:

Bank patches:
  src/patches/banks/upi-enabled-banks.yml
  src/patches/banks/nach-debit-banks.yml
  src/patches/banks/type-psb.yml
  src/patches/banks/type-private.yml
  src/patches/banks/type-rrb.yml
  src/patches/banks/type-sfb.yml
  src/patches/banks/type-scb.yml
  src/patches/banks/type-lab.yml

IFSC patches:
  src/patches/ifsc/sbi-swift.yml
  src/patches/ifsc/hdfc-swift.yml
  src/patches/ifsc/pnb-swift.yml
  src/patches/ifsc/upi-enabled-branches.yml
  src/patches/ifsc/disabled-imps.yml
  src/patches/ifsc/invalid-ifsc.yml
  src/patches/ifsc/neft-block.yml
  src/patches/ifsc/state-mh.yml
  src/patches/ifsc/no-imps-for-rbi.yml
  src/patches/ifsc/SBIN0005181.yml
  src/patches/ifsc/iccl.yml
  src/patches/ifsc/xnse.yml

Total: 20 patch files
```

### Step 2: Apply Bank Patches

```
Processing: upi-enabled-banks.yml

Read YAML:
banks:
  - HDFC
  - ICIC
  - SBIN
  ... (140 banks)

For each bank code:
  If bank_code exists in banks.json:
    Set upi: true
  Else:
    Warning: "Bank code XXXX in patch but not in banks.json"

Applied to 140 banks ✓

---

Processing: type-psb.yml

Read YAML:
banks:
  - SBIN
  - PUNB
  - CNRB
  ... (12 banks)

For each bank code:
  Set type: 'PSB'

Applied to 12 banks ✓

---

... (continue for all bank patches)
```

### Step 3: Apply IFSC Patches

```
Processing: sbi-swift.yml

Read YAML:
SBIN0000001:
  swift: SBININBB
SBIN0000002:
  swift: SBININBB123
... (500 entries)

For each IFSC:
  If IFSC exists in dataset:
    Merge: { swift: "SBININBB" }
  Else:
    Warning: "IFSC SBIN0000001 in patch but not in dataset"
    Decision: Skip (might be deleted branch)

Applied: 495 IFSCs ✓
Skipped: 5 IFSCs (not in dataset)

---

Processing: invalid-ifsc.yml

Read YAML:
ifsc:
  - TEST0000001
  - FAKE0001234
  - FRAUD000123

For each IFSC:
  If IFSC exists in dataset:
    Remove from dataset
    Log: "Removed fraudulent IFSC: {ifsc}"

Removed: 3 IFSCs ✓

---

... (continue for all IFSC patches)
```

### Step 4: Validate Patch Results

```
Post-patch validation:

1. Check UPI consistency:
   - Banks with upi: true should have >0 branches
   - ✓ All UPI banks have branches

2. Check SWIFT code format:
   - All SWIFT codes should be 8 or 11 chars
   - ✓ All SWIFT codes valid

3. Check state corrections:
   - States should match ISO 3166 list
   - ✓ All states valid

4. Detect conflicts:
   - Did any patch override another?
   - Warning: "SBIN0000001 has SWIFT from 2 patches"
   - Resolution: Last patch wins (document this)

Validation complete ✓
```

### Step 5: Report Patch Statistics

```json
{
  "patches_applied": 20,
  "bank_patches": {
    "upi_enabled": 140,
    "nach_debit": 89,
    "type_psb": 12,
    "type_private": 21,
    "type_rrb": 43,
    "type_sfb": 10,
    "type_scb": 34,
    "type_lab": 6
  },
  "ifsc_patches": {
    "sbi_swift": 495,
    "hdfc_swift": 287,
    "pnb_swift": 156,
    "upi_branches": 16,
    "disabled_imps": 8,
    "invalid_removed": 3,
    "neft_blocked": 2,
    "state_corrections": 42,
    "special_cases": 5
  },
  "total_ifscs_patched": 1014,
  "total_banks_patched": 155,
  "warnings": 5,
  "errors": 0
}
```

## AI Intelligence

### 1. Detect Conflicting Patches

```
Scenario:
Patch A (disabled-imps.yml): HDFC0001234 → imps: false
Patch B (upi-enabled-branches.yml): HDFC0001234 → upi: true

AI analysis:
"Conflict detected: Branch has UPI enabled but IMPS disabled.

Context check:
- UPI requires IMPS infrastructure
- This combination is technically invalid

Recommendation:
- Either remove from upi-enabled-branches.yml
- Or remove from disabled-imps.yml

Confidence: 90%
Action: Flag for human review"
```

### 2. Suggest New Patches

```
Scenario: AI notices pattern during data extraction

"I extracted 50 new HDFC branches in Karnataka.
 All have SWIFT code HDFCINBB.

 Current patch: sbi-swift.yml has 495 entries
 But hdfc-swift.yml only has 287 entries

 Suggestion:
 Should I add these 50 Karnataka branches to hdfc-swift.yml
 with SWIFT code HDFCINBB?

 Draft patch:
 HDFC0091234:
   swift: HDFCINBB
 HDFC0091235:
   swift: HDFCINBB
 ...

 Approve to create PR with this patch?"
```

### 3. Clean Stale Patches

```
Scenario: IFSC in patch no longer exists

"Warning: Patch sbi-swift.yml references SBIN0099999
 but this IFSC was removed from RBI dataset.

 Investigation:
 - Last seen: 2023-01-15 release
 - Reason: Branch merged into SBIN0088888
 - Stale patch entry

 Recommendation:
 Remove SBIN0099999 from sbi-swift.yml
 Add SBIN0088888 to sbi-swift.yml (if it has SWIFT)

 Auto-cleanup? (Y/N)"
```

### 4. Validate Patch Logic

```
Scenario: Nonsensical patch

"Error: Patch disabled-imps.yml sets imps: false for SBIN0000001

 But dataset already has:
 SBIN0000001:
   neft: true
   rtgs: true
   imps: true  ← From RBI data

 Conflict resolution:
 - RBI says IMPS enabled
 - Our patch says IMPS disabled

 Which is correct?

 Context: Patch added 2 years ago for 'RBI branches'
 But RBI branch SBIN0000001 might have enabled IMPS since

 Recommendation:
 - Verify with RBI website
 - If RBI website says enabled, remove from patch
 - If truly disabled, document reason in patch comment

 Flagging for manual review..."
```

## Patch Precedence Rules

```
Order of application (AI enforces this):

1. Extract base data from RBI/NPCI
2. Apply bank-level patches (adds metadata)
3. Apply IFSC-level patches (overrides specific fields)
4. Remove invalid IFSCs (deletion patches last)

Within IFSC patches:
1. Data additions (SWIFT codes, UPI flags) first
2. Corrections (state fixes) second
3. Deletions (invalid-ifsc.yml) last

If conflict:
  Last patch wins (but AI flags the conflict)
```

## Return Format

```json
{
  "status": "SUCCESS",
  "patches_applied": 20,
  "total_changes": 1169,
  "breakdown": {
    "banks_modified": 155,
    "ifscs_modified": 1014,
    "ifscs_removed": 3
  },
  "warnings": [
    {
      "patch": "sbi-swift.yml",
      "ifsc": "SBIN0099999",
      "issue": "IFSC not in dataset (likely deleted branch)",
      "action": "Skipped"
    }
  ],
  "conflicts": [
    {
      "ifsc": "HDFC0001234",
      "patch1": "disabled-imps.yml (imps: false)",
      "patch2": "upi-enabled-branches.yml (upi: true)",
      "resolution": "Last patch wins",
      "flagged_for_review": true
    }
  ],
  "suggestions": [
    {
      "type": "new_patch",
      "description": "Add 50 Karnataka HDFC branches to hdfc-swift.yml",
      "pr_draft_ready": true
    }
  ]
}
```

## Integration with Workflow

```
After dataset generation:
1. Dataset has ~18,500 IFSCs (raw from RBI/NPCI)
2. patch-applier runs
3. Adds UPI flags to 140 banks
4. Adds SWIFT codes to 938 IFSCs
5. Fixes 42 state name errors
6. Removes 3 invalid IFSCs
7. Final dataset: 18,497 IFSCs (clean, enhanced)

Then proceed to validation...
```

## Usage

**Agent invokes**:
```
Dataset merged (NEFT + RTGS + IMPS): 18,500 IFSCs

Now applying patches using patch-applier...

[Executes intelligent patch application]

Result:
- 20 patch files processed
- 155 banks enhanced with metadata
- 1,014 IFSCs patched
- 3 invalid IFSCs removed
- 5 warnings (stale patch references)
- 1 conflict detected (flagged for review)

Final dataset: 18,497 IFSCs ✓

Proceeding to validation...
```

## Why AI is Better

| Aspect | Script | AI |
|--------|--------|---|
| Conflict detection | None | Automatic |
| Stale patch cleanup | Manual | Suggested |
| New patch suggestions | None | AI-generated |
| Validation logic | Hardcoded | Contextual |
| Error messages | Generic | Explains why + suggests fix |

This ensures our manually curated corrections are applied reliably while catching inconsistencies.
