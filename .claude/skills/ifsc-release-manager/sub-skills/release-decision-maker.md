# Release Decision Maker Sub-Skill

## Purpose
Autonomously decide if a release is warranted and determine the appropriate version bump using business logic and impact analysis.

## Decision Framework

### Inputs
- Extracted dataset diff (added/removed/modified IFSCs)
- Validation confidence score
- Historical release patterns
- Current version
- Time since last release

### Outputs
- Decision: RELEASE / SKIP / INVESTIGATE
- Version bump: PATCH / MINOR / MAJOR
- Rationale: Human-readable explanation
- Risk level: LOW / MEDIUM / HIGH

## AI-Driven Decision Logic

### ❌ Old Way (Rigid Rules)
```ruby
# Hard-coded thresholds
if changes > 100
  release = true
  version = 'patch'
end
```

### ✅ New Way (Contextual Intelligence)

I analyze multiple dimensions:

#### 1. **Quantitative Analysis**
```
Change magnitude:
- Added: 247 IFSCs
- Removed: 12 IFSCs
- Modified: 3 IFSCs
- Net change: +235 (+1.27%)

Assessment: Moderate change volume
```

#### 2. **Qualitative Analysis**
```
What changed:
- 180/247 additions are HDFC Bank in Karnataka
  → Likely planned expansion, low risk

- 12 deletions are PNB branches
  → Cross-check: These branches merged into others (PNB-OBC merger)
  → This is expected cleanup, not data loss

- 3 modifications are name/MICR corrections
  → Minor data quality improvements

Assessment: Changes are organic and expected
```

#### 3. **Business Impact Analysis**
```
Affected stakeholders:
- Merchants with Karnataka customers: Will benefit from new HDFC codes
- Users with old PNB codes: Might face issues if hardcoded

Breaking change check:
- Are any deleted IFSCs still used in production?
  → Check GitHub API usage stats
  → Search for deleted codes in public repos
  → Check npm download patterns

Finding: Deleted codes have <10 API calls/month
Assessment: Minimal breaking impact
```

#### 4. **Timing Analysis**
```
Last release: v2.0.53 on 2025-01-10 (7 days ago)
RBI update date: 2025-01-17
Industry context: Mid-month, no major banking holidays

Assessment: Good timing for release
```

#### 5. **Validation Confidence**
```
Data quality score: 98.3%
- IFSC format validation: 100%
- Bank code validation: 100%
- Geographic consistency: 96.5% (some city name variations)
- Cross-source agreement: 98%

Assessment: High confidence, safe to release
```

## Decision Matrix

### Decision: RELEASE

**Criteria met**:
- ✅ Change magnitude significant (>50 IFSCs)
- ✅ Validation confidence high (>95%)
- ✅ No breaking changes detected
- ✅ Business impact positive
- ✅ Timing appropriate

**Version bump: PATCH (2.0.53 → 2.0.54)**

**Reasoning**:
- Additions are non-breaking (backward compatible)
- Deletions are expected cleanup (PNB merger)
- No API changes
- No format changes
- Follows semantic versioning

**Risk level: LOW**

### Decision: SKIP

**Example scenario**:
```
Change magnitude:
- Added: 15 IFSCs
- Removed: 3 IFSCs
- Modified: 0 IFSCs

Analysis:
- Too few changes (<50 threshold)
- Last release was 3 days ago
- Let changes accumulate for next week

Decision: SKIP
Rationale: "Insufficient changes for release. Will batch with next RBI update."
```

### Decision: INVESTIGATE

**Example scenario**:
```
Change magnitude:
- Added: 2,450 IFSCs
- Removed: 3,200 IFSCs
- Modified: 500 IFSCs

Analysis:
- Massive change (>10% of dataset)
- High deletion rate (unusual)
- Validation confidence: 87% (below threshold)

Red flags:
- Are we seeing a bank merger we don't know about?
- Did RBI change their data format?
- Is this a partial file download?

Decision: INVESTIGATE
Rationale: "Unusual change pattern. Manual review required before release."
Actions:
  1. Cross-check with NPCI data
  2. Search news for bank mergers
  3. Verify file integrity
  4. Notify team for investigation
```

## Advanced Decision Logic

### Bank Merger Detection
```
Pattern detected:
- 1,200 IFSCs removed (all starting with "VIJB")
- 0 IFSCs added with "VIJB"
- News search: "Vijaya Bank merged with Bank of Baroda in 2019"

Inference: This is historical cleanup, not new data.

Decision: RELEASE as MINOR (not PATCH)
Rationale: "Significant structural change (bank removal) warrants minor bump"
```

### Format Change Detection
```
Pattern detected:
- New field added: "UPI_ID" in dataset
- All existing IFSCs now have upi: true/false flag

Breaking change assessment:
- Existing code using IFSC.json won't break (additive change)
- But consumers need to update for new field

Decision: RELEASE as MINOR
Rationale: "New feature added (UPI flag), backward compatible but notable"
```

### Emergency Release
```
Scenario:
- Security issue reported: IFSC code XXXX0001234 is fraudulent
- Needs immediate removal from dataset

Analysis:
- Only 1 IFSC affected
- But high severity (fraud prevention)

Decision: RELEASE as PATCH (emergency)
Version: 2.0.54-hotfix.1
Rationale: "Emergency release to remove fraudulent IFSC code"
Timeline: Expedited (no normal approval wait)
```

## Versioning Logic (Semantic Versioning)

### PATCH (2.0.53 → 2.0.54)
**When**:
- Only IFSC additions (backward compatible)
- Minor deletions (<50 codes)
- Data quality fixes (typos, MICR corrections)
- No structural changes

**Example**:
```
Changes:
- 247 new HDFC branches
- 12 merged PNB branches removed
- 3 branch name typos corrected

→ PATCH release
```

### MINOR (2.0.53 → 2.1.0)
**When**:
- New fields added to dataset
- Significant bank mergers (>500 IFSCs affected)
- New data sources integrated (e.g., SWIFT codes added)
- API behavior changes (but backward compatible)

**Example**:
```
Changes:
- Added "swift_code" field to 3,000 IFSCs
- Existing consumers not broken, but new data available

→ MINOR release
```

### MAJOR (2.0.53 → 3.0.0)
**When**:
- Breaking format changes (JSON structure change)
- Removed fields from dataset
- Complete bank code overhaul
- SDK API breaking changes

**Example**:
```
Changes:
- IFSC.json structure changed from flat to nested
- Old parsers will break

→ MAJOR release (with migration guide)
```

## Confidence Scoring

I assign a confidence score to my decision:

```json
{
  "decision": "RELEASE",
  "version": "2.0.54",
  "confidence": 0.95,
  "confidence_breakdown": {
    "data_quality": 0.98,
    "change_analysis": 0.96,
    "impact_assessment": 0.92,
    "timing": 1.0
  },
  "recommendation": "Proceed with release",
  "human_review_required": false
}
```

If confidence < 0.8 → `human_review_required: true`

## Real-World Examples

### Example 1: Routine Update
```
Input:
- 247 new IFSCs (HDFC Karnataka expansion)
- 12 removed IFSCs (PNB merger cleanup)
- Validation: 98.3%

Decision Process:
1. Change magnitude: Moderate (1.3% of dataset)
2. Business context: HDFC expanding in Karnataka (normal)
3. Deletions: Expected from known merger
4. Timing: 7 days since last release (good cadence)
5. Risk: Low

Output:
Decision: RELEASE
Version: PATCH (2.0.54)
Confidence: 95%
Rationale: "Routine quarterly expansion, no breaking changes"
```

### Example 2: Suspicious Pattern
```
Input:
- 5,000 IFSCs removed (10% of dataset)
- 0 new IFSCs added
- Validation: 75% (file seems incomplete)

Decision Process:
1. Change magnitude: MASSIVE deletion
2. Red flag: No additions (unusual)
3. Validation: Below threshold
4. Hypothesis: Partial file download? RBI error?
5. Risk: HIGH

Output:
Decision: INVESTIGATE
Version: N/A
Confidence: 60%
Rationale: "Suspicious mass deletion. File may be corrupted. Requires manual verification."
Actions:
  - Re-download file
  - Check RBI website for notices
  - Cross-verify with NPCI data
  - Wait 24 hours for RBI correction
```

### Example 3: New Feature Addition
```
Input:
- 0 IFSCs added/removed
- New field: "branch_timings" extracted from bank websites
- Validation: 100%

Decision Process:
1. Change magnitude: Zero IFSC changes
2. Structural change: New data field added
3. Backward compatibility: Old consumers won't break
4. Value add: Useful new data
5. Risk: Low (additive change)

Output:
Decision: RELEASE
Version: MINOR (2.1.0)
Confidence: 92%
Rationale: "New feature: branch operating hours added. Backward compatible."
```

## Integration with Other Sub-Skills

After making a decision:

```
If decision == RELEASE:
  → Invoke changelog-writer to document changes
  → Invoke git-orchestrator to create release branch
  → Invoke test-runner to verify quality

If decision == SKIP:
  → Log reason
  → Schedule next check
  → Update team: "No release needed, batching changes"

If decision == INVESTIGATE:
  → Invoke slack-communicator to alert team
  → Provide investigation checklist
  → Wait for human decision
```

## Learning Over Time

I track historical decisions:

```
Release history:
- v2.0.50: 150 changes → PATCH (correct)
- v2.0.51: 800 changes → PATCH (should've been MINOR in retrospect)
- v2.0.52: 45 changes → SKIPPED (good call)
- v2.0.53: 300 changes + new field → MINOR (correct)

Learning:
- Threshold for MINOR should be >500 IFSCs OR structural change
- Adjust confidence scoring based on past accuracy
```

## Usage

**Agent invokes**:
```
Dataset generated. Using release-decision-maker to analyze...

[Executes multi-factor analysis]

Result: RELEASE recommended
Version: 2.0.54 (PATCH)
Confidence: 95%
Rationale: "247 new Karnataka branches, 12 expected PNB cleanup, low risk"

Proceeding to create release branch...
```

This decision then drives the entire release workflow.
