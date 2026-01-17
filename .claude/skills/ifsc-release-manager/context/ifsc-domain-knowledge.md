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

This knowledge base is used by all sub-skills for intelligent decision-making.
