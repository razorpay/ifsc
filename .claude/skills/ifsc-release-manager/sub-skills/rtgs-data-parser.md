# RTGS Data Parser Sub-Skill

## Purpose
Parse RBI RTGS Excel file with 4 sheets and extract RTGS-enabled branch IFSCs.

## When to Use
- After downloading RTGEB0815.xlsx from RBI
- During dataset generation workflow
- When RTGS file format changes and needs intelligent parsing

## Input
- **Excel File**: `sheets/RTGEB0815.xlsx`
- **Expected Sheets**:
  - Sheet 0: "Bankwise branches" (summary - ignored)
  - Sheet 1: "RTGS enabled branches IFSC(A-H)"
  - Sheet 2: "RTGS enabled branhces IFSC(I-R)" (note: typo in RBI file)
  - Sheet 3: "RTG enabled branches IFSC(S-Z)"

## Processing Logic

### 1. Sheet Structure Detection
```
Expected columns:
- Bank Name
- IFSC
- Branch Name
- Address
- Contact (Phone/STD code)
- City
- District
- State
- MICR Code (optional)
```

### 2. AI-Driven Parsing Strategy

**Vision-Based Approach**:
1. Read Excel file as image (for complex layouts)
2. Identify header row (usually row 1-3)
3. Detect column boundaries
4. Handle merged cells intelligently
5. Extract data row by row

**Pandas Fallback**:
```python
import pandas as pd
df = pd.read_excel('RTGEB0815.xlsx', sheet_name='RTGS enabled branches IFSC(A-H)')
```

### 3. Data Validation Rules

For each IFSC entry:
- ✅ IFSC format: 4 letters + 0 + 6 alphanumeric (e.g., SBIN0000001)
- ✅ Bank code matches known banks
- ✅ State is valid Indian state/UT
- ⚠️ Flag if MICR missing (acceptable for new branches)

### 4. Output Format

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
    "NEFT": true
  }
}
```

## Handling Edge Cases

### Typos in Sheet Names
RBI files have inconsistent naming:
- "RTGS enabled **branhces**" (missing 'c')
- "**RTG** enabled branches" (missing 'S')

**Solution**: Use fuzzy matching or vision to detect sheets regardless of name.

### Merged Header Cells
Bank names often span multiple columns.

**Solution**: AI vision can handle this; pandas requires `header=[0,1]`.

### Empty Rows
Sheets contain blank rows between bank sections.

**Solution**: Skip rows where IFSC is null/empty.

### Contact Number Formats
Varied formats:
- "022-22631516"
- "22631516"
- "(022) 22631516"

**Solution**: Extract digits only, prefix with STD code if missing.

## Integration with Main Workflow

```python
# Called after NEFT parsing
rtgs_data = parse_rtgs_excel('sheets/RTGEB0815.xlsx')

# Merge with NEFT data (NEFT takes precedence for duplicates)
combined = merge_datasets(neft_data, rtgs_data)
```

## Error Handling

**File Not Found**:
```
→ Check if download step failed
→ Verify RBI website URL still valid
→ Notify team
```

**Format Changed**:
```
→ Use AI vision to adapt to new layout
→ Compare column count/structure with previous version
→ Generate diff report for human review
```

**IFSC Count Mismatch**:
```
Expected: ~176,000 RTGS IFSCs
If deviation >5%:
  → Flag as anomaly
  → Compare with previous release
  → Request manual verification
```

## Success Criteria

- ✅ All 3 data sheets parsed successfully
- ✅ IFSC count within expected range (170K-180K)
- ✅ No invalid IFSC formats
- ✅ State normalization applied
- ✅ Duplicate detection (same IFSC across sheets)

## Output Files

- `data/rtgs.json` - Temporary intermediate file
- Merged into final `data/IFSC.json`

## Performance Targets

- Parse 176K+ entries in <2 minutes
- Validation confidence >95%
- Zero data loss from source file
