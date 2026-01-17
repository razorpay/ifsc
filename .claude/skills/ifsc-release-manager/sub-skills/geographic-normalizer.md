# Geographic Normalizer Sub-Skill

## Purpose
Normalize 100+ variations of Indian state/UT names in RBI data to standardized ISO names and add ISO 3166-2 codes.

## The Problem

### RBI Data Quality Issues
RBI Excel files have **massive inconsistency** in state names:

**Examples**:
- "ANDHRAPRADESH" vs "ANDHRA PRADESH"
- "CHHATTISGARH" vs "CHHATISHGARH" vs "CHATTISGARH"
- "PONDICHERRY" vs "PUDUCHERRY"
- "ORISSA" vs "ODISHA"
- "TELENGANA" vs "TELANGANA"
- City names instead of states: "MUMBAI" → "MAHARASHTRA"
- Abbreviations: "AP", "KA", "TN", "MH"

**Impact**: Without normalization, queries like "Find all branches in Maharashtra" would miss branches marked "MUMBAI" or "PUNE".

## When to Use
- During NEFT/RTGS parsing (before saving to dataset)
- After merging datasets (to catch any missed variations)
- When new state name variations are discovered

## Normalization Strategy

### Step 1: Uppercase and Trim
```ruby
possible_state = row['STATE'].strip.upcase
```

**Fixes**:
- " Tamil Nadu " → "TAMIL NADU"
- "karnataka" → "KARNATAKA"

### Step 2: Handle Abbreviations
```ruby
if possible_state.size == 2
  final_state = {
    "AP" => "ANDHRA PRADESH",
    "KA" => "KARNATAKA",
    "TN" => "TELANGANA",  # Note: TN is Telangana, not Tamil Nadu
    "MH" => "MAHARASHTRA",
    "CG" => "CHHATTISGARH",
    "ML" => "MEGHALAYA",
    "MP" => "MADHYA PRADESH"
  }[possible_state]
end
```

**Why**: RBI uses state abbreviations inconsistently across sheets.

### Step 3: Pattern Matching for Variations

**Implementation**:
```ruby
map = {
  # Misspellings - Andhra Pradesh
  /ANDHRAPRADESH/ => 'ANDHRA PRADESH',

  # City names - Karnataka
  /BANGALORE/ => 'KARNATAKA',
  /SAMBRA/ => 'KARNATAKA',
  /CARMELARAM/ => 'KARNATAKA',
  /BTM/ => 'KARNATAKA',

  # Misspellings - Karnataka
  /KARANATAKA/ => 'KARNATAKA',

  # City names - Maharashtra
  /MUMBAI/ => 'MAHARASHTRA',
  /PUNE/ => 'MAHARASHTRA',
  /NASHIK/ => 'MAHARASHTRA',
  /NASIK/ => 'MAHARASHTRA',
  /BHUSAWAL/ => 'MAHARASHTRA',
  /BULDHANA/ => 'MAHARASHTRA',
  /SANTACRUZ/ => 'MAHARASHTRA',
  /MALEGAON/ => 'MAHARASHTRA',

  # Misspellings - Chhattisgarh (3 variations!)
  /CHHATIS/ => 'CHHATTISGARH',
  /CHHATISHGARH/ => 'CHHATTISGARH',  # Double H, Single T
  /CHATTISGARH/ => 'CHHATTISGARH',   # Single H, Double T

  # Misspellings - Madhya Pradesh
  /MADHYAPRADESH/ => 'MADHYA PRADESH',
  /INDORE/ => 'MADHYA PRADESH',
  /DINDORI/ => 'MADHYA PRADESH',

  # Union Territories - Dadra/Daman/Diu (merged in 2020)
  /DADRA/ => 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU',
  /DIU/ => 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU',
  'DAMAN' => 'DADRA AND NAGAR HAVELI AND DAMAN AND DIU',  # Exact match (avoid clash with ANDAMAN)

  # Renamed states
  /PONDICHERRY/ => 'PUDUCHERRY',
  /ORISSA/ => 'ODISHA',
  /TELENGANA/ => 'TELANGANA',

  # Misspellings - Uttar Pradesh
  /UTTARPRADESH/ => 'UTTAR PRADESH',

  # Misspellings - Uttarakhand
  /UTTARA/ => 'UTTARAKHAND',
  /UTTRAKHAND/ => 'UTTARAKHAND',

  # Misspellings - Himachal Pradesh
  /HIMANCHAL/ => 'HIMACHAL PRADESH',
  /HIMACHAL/ => 'HIMACHAL PRADESH',

  # Misspellings - Jharkhand
  /HARKHAND/ => 'JHARKHAND',
  /JHAGRAKHAND/ => 'JHARKHAND',

  # City names - Gujarat
  /AHMEDABAD/ => 'GUJARAT',
  /DAHEGAM/ => 'GUJARAT',
  /DAHEJ/ => 'GUJARAT',

  # Misspellings - Gujarat
  /GUJRAT/ => 'GUJARAT',

  # City names - Rajasthan
  /BUNDI/ => 'RAJASTHAN',
  /CHURU/ => 'RAJASTHAN',
  /RAJAS/ => 'RAJASTHAN',

  # City names - Tamil Nadu
  /CHENNAI/ => 'TAMIL NADU',
  /MADURAI/ => 'TAMIL NADU',
  /TAMIL/ => 'TAMIL NADU',

  # City names - Andhra Pradesh
  /HYDERABAD/ => 'ANDHRA PRADESH',
  /IDAR/ => 'ANDHRA PRADESH',

  # City names - Goa
  /BARDEZ/ => 'GOA',
  /GOA/ => 'GOA',

  # City names - Jammu & Kashmir
  /JAMMU/ => 'JAMMU AND KASHMIR',

  # City names - West Bengal
  /WEST/ => 'WEST BENGAL',

  # Misspellings - Punjab
  /PANJAB/ => 'PUNJAB',
  /CHEMBUR/ => 'PUNJAB',  # Chembur is in Mumbai, but misclassified in some RBI data

  # Misspellings - Meghalaya
  /MEGHALAY/ => 'MEGHALAYA',

  # City names - Andaman
  /ANDAMAN/ => 'ANDAMAN AND NICOBAR ISLANDS',

  # City names - Delhi
  /DELHI/ => 'DELHI',

  # Chandigarh - Complex case
  /CHANDIGARH UT/ => 'CHANDIGARH'  # Only if explicitly marked as UT
  # Note: Chandigarh branches without "UT" are ambiguous (could be Haryana or Punjab)
}

map.each_pair do |r, state|
  if r.is_a? Regexp and r.match? possible_state
    final_state = state
  elsif r == possible_state
    final_state = state
  end
end
```

### Step 4: Log Changes
```ruby
if final_state != row['STATE']
  log "#{row['IFSC']}: Setting State=(#{final_state}) instead of (#{row['STATE']})"
  row['STATE'] = final_state
end
```

**Purpose**: Track what was normalized for debugging and validation.

## ISO 3166-2 Code Mapping

### Adding ISO Codes
After state normalization, add ISO 3166-2:IN codes:

```ruby
ISO3166_MAP = {
  'ANDHRA PRADESH' => 'AP',
  'ARUNACHAL PRADESH' => 'AR',
  'ASSAM' => 'AS',
  'BIHAR' => 'BR',
  'CHHATTISGARH' => 'CT',
  'GOA' => 'GA',
  'GUJARAT' => 'GJ',
  'HARYANA' => 'HR',
  'HIMACHAL PRADESH' => 'HP',
  'JHARKHAND' => 'JH',
  'KARNATAKA' => 'KA',
  'KERALA' => 'KL',
  'MADHYA PRADESH' => 'MP',
  'MAHARASHTRA' => 'MH',
  'MANIPUR' => 'MN',
  'MEGHALAYA' => 'ML',
  'MIZORAM' => 'MZ',
  'NAGALAND' => 'NL',
  'ODISHA' => 'OR',
  'PUNJAB' => 'PB',
  'RAJASTHAN' => 'RJ',
  'SIKKIM' => 'SK',
  'TAMIL NADU' => 'TN',
  'TELANGANA' => 'TG',
  'TRIPURA' => 'TR',
  'UTTAR PRADESH' => 'UP',
  'UTTARAKHAND' => 'UT',
  'WEST BENGAL' => 'WB',
  'ANDAMAN AND NICOBAR ISLANDS' => 'AN',
  'CHANDIGARH' => 'CH',
  'DADRA AND NAGAR HAVELI AND DAMAN AND DIU' => 'DH',
  'LAKSHADWEEP' => 'LD',
  'DELHI' => 'DL',
  'PUDUCHERRY' => 'PY',
  'LADAKH' => 'LA',
  'JAMMU AND KASHMIR' => 'JK'
}

combined_data['ISO3166'] = ISO3166_MAP[combined_data['STATE']]
```

**Use Cases**:
- Geographic queries by ISO code
- Integration with international systems
- CSV column for state abbreviations

## Edge Cases

### 1. Invalid State = "0"
**Issue**: Some RTGS entries have `STATE = "0"` (data corruption)

**Fix**:
```ruby
if row['STATE'] == '0'
  row['STATE'] = nil
end
```

**Action**: Mark as nil, let it fail validation or be patched later.

### 2. Chandigarh Ambiguity
**Problem**: Chandigarh is a city in both Punjab and Haryana, and also a Union Territory.

**Solution**:
- Only normalize "CHANDIGARH UT" → "CHANDIGARH"
- Leave "CHANDIGARH" alone (could be Haryana or Punjab)
- Requires manual patch for specific branches

### 3. Hyderabad After Telangana Split
**Before 2014**: Hyderabad was in Andhra Pradesh
**After 2014**: Hyderabad is capital of Telangana

**Current Logic**: Maps "HYDERABAD" → "ANDHRA PRADESH" (historical data)

**Improvement**: Could use IFSC date to determine:
```ruby
if row['STATE'] == 'HYDERABAD'
  if branch_created_after_2014?(row['IFSC'])
    row['STATE'] = 'TELANGANA'
  else
    row['STATE'] = 'ANDHRA PRADESH'
  end
end
```

### 4. Missing State
**Issue**: Some branches have `STATE = nil` or `STATE = ""`

**Solution**:
```ruby
return unless row['STATE']  # Skip normalization if no state
```

**Action**: Flag for manual review or apply patch.

### 5. State in Wrong Column
**Issue**: Sometimes ADDRESS column contains state due to column misalignment

**Detection**:
```ruby
if row['STATE'].to_s.strip.match('\d')  # State contains digits
  fix_row_alignment!(row)
end
```

**Fix**: Shift columns to correct alignment.

## Validation

### Check for Unmapped States
```ruby
def validate_states(dataset)
  unknown_states = Set.new

  dataset.each do |ifsc, data|
    state = data['STATE']
    unless ISO3166_MAP.key?(state)
      unknown_states.add(state)
    end
  end

  if unknown_states.any?
    log "WARNING: Unknown states found:", :warn
    unknown_states.each { |s| log "  - #{s}", :warn }
  end
end
```

### Count Distribution
```ruby
def state_distribution(dataset)
  counts = Hash.new(0)
  dataset.each do |ifsc, data|
    counts[data['STATE']] += 1
  end

  log "=== State Distribution ==="
  counts.sort_by { |k, v| -v }.each do |state, count|
    log "#{state}: #{count} branches"
  end
end
```

**Expected Top States**:
- MAHARASHTRA: ~25,000 branches
- UTTAR PRADESH: ~20,000 branches
- KARNATAKA: ~15,000 branches
- TAMIL NADU: ~15,000 branches

## Performance

**Normalization Time**: <5 seconds for 177K entries

**Strategy**: Pattern matching is fast, runs during CSV parsing (single pass).

## Success Criteria

- ✅ All state names match ISO3166_MAP keys
- ✅ Zero "MUMBAI", "BANGALORE", "CHENNAI" in final STATE column
- ✅ All ISO3166 codes populated
- ✅ <10 branches with nil/unknown states

## Integration with Workflow

**Called During CSV Parsing**:
```ruby
def parse_csv(files, banks, additional_attributes)
  files.each do |file|
    csv.each do |row|
      # ... other processing ...

      row['STATE'].strip! if row['STATE']
      fix_state!(row)  # ← Normalization happens here

      # ... ISO code added during merge ...
      combined_data['ISO3166'] = ISO3166_MAP[combined_data['STATE']]
    end
  end
end
```

## Related Files

- `scraper/scripts/methods.rb:48-141` - `fix_state!()` function
- `scraper/scripts/methods.rb:360` - ISO3166 code assignment

## Future Enhancements

### Machine Learning Approach
```python
# Train classifier on city → state mappings
from sklearn.ensemble import RandomForestClassifier

# Features: city name, district, IFSC prefix
# Label: state

# Can handle new city names automatically
```

### Address-Based Inference
```ruby
# Extract state from address field
if row['STATE'].nil? and row['ADDRESS']
  STATE_PATTERNS.each do |state, pattern|
    if row['ADDRESS'].match?(pattern)
      row['STATE'] = state
    end
  end
end
```

### Pincode-Based Lookup
```ruby
# First 2 digits of pincode → state
PINCODE_TO_STATE = {
  '40' => 'MAHARASHTRA',  # 400xxx = Mumbai
  '11' => 'DELHI',        # 110xxx = Delhi
  '56' => 'KARNATAKA',    # 560xxx = Bangalore
  # ...
}
```
