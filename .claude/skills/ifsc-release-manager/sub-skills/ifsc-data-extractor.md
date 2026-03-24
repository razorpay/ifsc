# IFSC Data Extractor Sub-Skill

## Purpose
Extract IFSC codes from Excel/HTML files using AI-powered parsing that adapts to format changes.

## Why AI Instead of Scripts?

### ❌ Old Way (Brittle Parsing)
```ruby
# scraper/scripts/methods.rb
require 'roo'
xlsx = Roo::Spreadsheet.open('neft.xlsx')
sheet = xlsx.sheet('Sheet1')  # Breaks if sheet renamed
headers = sheet.row(1)        # Breaks if headers on row 2
bank_col = headers.index('Bank Name')  # Breaks if column renamed to 'Bank'

(2..sheet.last_row).each do |i|
  ifsc = sheet.row(i)[0]     # Assumes IFSC in column A
  # Fails when layout changes
end
```

**Problems**:
- Hardcoded sheet names
- Hardcoded column positions
- Hardcoded header row
- Can't handle merged cells
- Breaks on format changes

### ✅ New Way (AI Vision Parsing)

I can **see** Excel files visually. I'll:
1. Read the file as an image
2. Identify the table structure
3. Extract data regardless of layout
4. Adapt to changes automatically

## Execution Flow

When invoked with a file path:

### Step 1: Initial Analysis
```
Read the Excel file: /tmp/ifsc-neft-new.xlsx

I see this file visually. Let me analyze:
- File has 3 sheets: "NEFT Members", "RTGS Members", "Metadata"
- The IFSC data is in sheet 1
- Headers start at row 4 (rows 1-3 are title/date)
- Columns: IFSC Code | Bank Name | Branch | City | State | MICR
- Contains merged cells in the "Bank Name" column for grouped entries
- Total rows: ~18,500
```

### Step 2: Structured Extraction
```
I'll extract this data into JSON format:

For each row from 5 to 18,500:
  - Read IFSC code from column A
  - Read Bank name (handling merged cells)
  - Read Branch from column C
  - Extract City, State, MICR codes
  - Validate IFSC format as I go
```

### Step 3: Handle Edge Cases
```
Detected issues:
1. Row 234: IFSC code has trailing space "HDFC0001234 " → trim it
2. Row 1,892: Bank name is merged across 50 rows → propagate value
3. Row 5,431: City field says "BANGALORE / BENGALURU" → normalize to "BANGALORE"
4. Row 8,120: MICR code is "NA" → set to null
5. Row 12,003: Branch name has special chars "BRANCH–A" → clean to "BRANCH-A"

I'm correcting these automatically based on data quality best practices.
```

### Step 4: Cross-Reference with Other Sources
```
I also have the RTGS list. Let me cross-check:
- If an IFSC appears in RTGS but not NEFT → flag it
- If bank name differs between sources → use most recent
- If MICR code conflicts → prefer RBI source over NPCI
```

### Step 5: Return Structured Data
```json
{
  "source": "RBI_NEFT_20250117",
  "extracted_count": 18473,
  "format_version": "2025_v1",
  "metadata": {
    "file_path": "/tmp/ifsc-neft-new.xlsx",
    "sheet_name": "NEFT Members",
    "header_row": 4,
    "data_start_row": 5,
    "columns_detected": ["IFSC", "Bank", "Branch", "City", "State", "MICR"],
    "extraction_method": "ai_vision"
  },
  "data": [
    {
      "ifsc": "HDFC0000001",
      "bank": "HDFC Bank",
      "branch": "RTGS-HO",
      "city": "MUMBAI",
      "state": "MAHARASHTRA",
      "micr": "400240002"
    },
    // ... 18,472 more entries
  ],
  "anomalies_detected": [
    {
      "row": 234,
      "issue": "Trailing whitespace in IFSC",
      "auto_fixed": true
    },
    {
      "row": 5431,
      "issue": "Dual city name format",
      "resolution": "Used primary name"
    }
  ],
  "statistics": {
    "total_banks": 156,
    "total_ifscs": 18473,
    "new_vs_previous": {
      "added": 247,
      "removed": 12,
      "modified": 3
    }
  }
}
```

## AI Vision Capabilities

**I can handle**:

1. **Different Excel formats**:
   - .xlsx, .xls, .xlsm
   - CSV (even with weird encodings)
   - Google Sheets exports

2. **Layout variations**:
   - Headers in any row
   - Columns in any order
   - Merged cells
   - Multi-sheet workbooks
   - Rotated text headers

3. **Format changes**:
   ```
   Old format:
   | IFSC | Bank | Branch |

   New format (after RBI redesign):
   | S.No | Bank Name | IFSC Code | Branch Address |

   → I'll adapt and extract correctly
   ```

4. **Data quality issues**:
   - Extra spaces
   - Inconsistent casing
   - Special characters
   - Missing values
   - Duplicate rows

## Intelligent Parsing Examples

### Example 1: Merged Cell Handling
```
Excel looks like this visually:

| Bank Name  | IFSC       | Branch        |
|------------|------------|---------------|
| HDFC Bank  | HDFC000001 | Delhi Main    |
|            | HDFC000002 | Delhi Connaught|  ← Bank name merged
|            | HDFC000003 | Delhi Rohini  |
| ICICI Bank | ICIC000001 | Mumbai Fort   |

My extraction:
- Row 2: Bank = "HDFC Bank" (read from merged cell)
- Row 3: Bank = "HDFC Bank" (propagated from merged cell)
- Row 4: Bank = "HDFC Bank" (propagated from merged cell)
- Row 5: Bank = "ICICI Bank" (new merged cell starts)

No script can handle this generically. I understand the visual structure.
```

### Example 2: HTML Table Parsing
```
If RBI switches to HTML format:

<table class="rbi-ifsc-table">
  <thead>
    <tr><th colspan="6">NEFT Member Banks - January 2025</th></tr>
    <tr><th>IFSC</th><th>Bank</th><th>Branch</th></tr>
  </thead>
  <tbody>
    <tr><td>HDFC0000001</td><td>HDFC Bank</td><td>RTGS-HO</td></tr>
    ...
  </tbody>
</table>

I'll:
1. Identify the table (even if class name changes)
2. Find the actual header row (row 2, not row 1)
3. Extract data from tbody
4. Handle colspan/rowspan

No CSS selector hardcoding needed—I see the structure.
```

### Example 3: PDF Parsing
```
If source is a PDF:

Use Read tool to view the PDF visually.

I see:
- Page 1: Title page, no data
- Pages 2-87: IFSC table in 3-column format
- Each page has header/footer to ignore

I'll:
1. Read each page
2. Identify table boundaries
3. Extract text
4. Reconstruct table structure
5. Return JSON
```

## Comparison with Previous Data

```
After extraction, I compare with previous dataset:

Old dataset (v2.0.53): 18,238 IFSCs
New dataset (extracted): 18,473 IFSCs

Changes:
- Added: 247 IFSCs
  - 180 HDFC Bank (Karnataka expansion)
  - 42 SBI (new rural branches)
  - 25 ICICI (metro branches)

- Removed: 12 IFSCs
  - 8 Punjab National Bank (merged branches)
  - 4 Bank of Maharashtra (closed)

- Modified: 3 IFSCs
  - KSCB0001234: Branch name "Tumkur Main" → "Tumkur Urban"
  - PUNB0023400: MICR code corrected
  - HDFC0091234: City "Bangalore" → "Bengaluru"

Impact analysis: Low risk. Mostly additions, few deletions.
```

## Error Recovery

**Scenario: Corrupt Excel File**
```
Error: Excel file appears corrupted (unzip error)

My response:
1. Try alternate Excel libraries (openpyxl, xlrd)
2. If still failing, try LibreOffice conversion:
   soffice --headless --convert-to csv file.xlsx
3. If CSV works, parse CSV instead
4. If all fails, ask user to re-download from source
```

**Scenario: Unexpected Format**
```
Warning: File has 20 columns, expected 6

My response:
1. Read first 10 rows to understand new structure
2. Identify which columns contain IFSC data (by pattern matching)
3. Map new column positions to expected fields
4. Continue extraction with new mapping
5. Log: "RBI added 14 new columns, adapted automatically"
```

## No Scripts, Just Intelligence

**Key point**: I'm not running `generate.rb` or `methods.rb`. I'm:
- Reading files visually
- Understanding structure contextually
- Extracting data intelligently
- Adapting to changes automatically

This makes the system **antifragile**—it gets better when things break.

## Usage

**Agent invokes**:
```
I have a new NEFT file from RBI. Using ifsc-data-extractor...

[Executes vision-based extraction]

Result: Extracted 18,473 IFSCs with 99.8% confidence.
247 new entries, 12 removed. Ready for validation.
```

This data now flows to `ifsc-validator` for quality checks.
