# RBI Data Monitor Sub-Skill

## Purpose
Detect when RBI or NPCI publishes new IFSC data by monitoring official sources.

## Approach: AI-Driven, Not Script-Driven

### ❌ Old Way (Brittle Scripts)
```ruby
# Hardcoded URL, breaks when RBI changes page structure
response = HTTParty.get('https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xlsx')
checksum = Digest::MD5.hexdigest(response.body)
# Fails silently if URL changes
```

### ✅ New Way (AI-Driven)

**Step 1: Discover Current URLs**
```
Use WebSearch to find:
"RBI NEFT member list Excel 2025"

Then WebFetch the RBI page to extract download links.
If the URL structure changed, adapt dynamically.
```

**Step 2: Intelligent Download**
```
Download the file from discovered URL.
If download fails:
  - Try alternate mirrors
  - Check if page structure changed
  - Use vision AI to find download button on page screenshot
```

**Step 3: Change Detection**
```
Compare with previous version:
  - File size difference
  - Checksum comparison
  - If file format changed, use AI to parse both and compare data
```

## Execution Flow

When invoked:

1. **Locate Data Sources**
   ```
   I'll find the current NEFT/RTGS download URLs.
   Using WebSearch: "RBI NEFT member list site:rbi.org.in"
   ```

2. **Fetch Landing Pages**
   ```
   WebFetch: https://www.rbi.org.in/Scripts/bs_viewcontent.aspx?Id=2009
   Extract: All Excel/XLSX download links
   ```

3. **Download Files**
   ```
   For each source:
     - NEFT list: https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xlsx
     - RTGS list: https://rbidocs.rbi.org.in/rdocs/RTGS/DOCs/RTGEB0815.xlsx
     - NPCI NACH: https://www.npci.org.in/what-we-do/nach/live-members/live-banks

   Use Bash to download:
   curl -L -o /tmp/ifsc-neft-new.xlsx "URL"
   ```

4. **Compute Checksums**
   ```
   md5sum /tmp/ifsc-neft-new.xlsx
   Compare with stored checksum from last run
   ```

5. **Detect Changes**
   ```
   If checksum differs:
     - Quick check: File size ±10% → likely significant update
     - Deep check: Use ifsc-data-extractor to parse both, count differences
   ```

6. **Vision-Based Verification** (if file format unexpected)
   ```
   If file won't parse with normal tools:
     - Read the Excel file (I can see images/PDFs/Excel visually)
     - Describe the layout: "Table starts at row 5, headers in row 4"
     - Extract data using vision understanding
   ```

7. **Return Results**
   ```json
   {
     "change_detected": true,
     "sources_checked": ["RBI_NEFT", "RBI_RTGS", "NPCI_NACH"],
     "files_changed": ["RBI_NEFT"],
     "metadata": {
       "rbi_neft": {
         "url": "https://rbidocs.rbi.org.in/rdocs/content/docs/68774.xlsx",
         "size_kb": 2847,
         "checksum": "a3f7c2d9e1b8f4a2c5d8e9f1a2b3c4d5",
         "modified_date": "2025-01-17",
         "previous_checksum": "b4e8d3a0f2c9g5b3d6e0f2a3b4c5d6e7"
       }
     },
     "summary": "RBI NEFT list updated: new file is 145KB larger, suggesting ~200-300 new entries"
   }
   ```

## AI Advantages

1. **Adapts to URL changes**: If RBI changes doc ID from 68774 to 68900, I'll find it via search
2. **Handles format changes**: If they switch from .xlsx to .csv, I'll parse it anyway
3. **Intelligent comparison**: Not just checksum—I understand if it's a trivial update or major change
4. **Self-healing**: If a source is down, I'll check mirrors or wait and retry

## Usage Example

**Agent invokes**:
```
I need to check if there's new IFSC data. Using rbi-data-monitor...

[Internally executes above flow]

Result: New data detected on RBI NEFT list.
File: 247 rows added, 12 rows removed.
Proceed to ifsc-data-extractor.
```

## Error Handling

**If RBI website is down**:
```
Error: Connection timeout to rbi.org.in

My response:
1. Check if it's a temporary outage (retry in 5 min)
2. Look for cached versions on Archive.org
3. Notify team: "RBI website unreachable, will retry"
4. Don't fail the entire workflow—schedule retry
```

**If file format completely changed**:
```
Warning: Expected Excel file, got HTML page

My response:
1. Read HTML visually to see what happened
2. Maybe RBI now embeds table in HTML instead of Excel
3. Extract data from HTML using vision AI
4. Update context file: "RBI changed format to HTML on 2025-01-17"
```

## No Hardcoded Scripts

Notice: **Zero Ruby/Python scripts**. Everything is AI reasoning:
- URLs discovered dynamically
- File formats handled adaptively
- Changes analyzed intelligently
- Errors resolved contextually

This is resilient to changes RBI/NPCI make without our knowledge.
