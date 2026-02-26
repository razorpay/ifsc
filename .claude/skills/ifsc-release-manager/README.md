# IFSC Release Manager - AI-Driven SWE Agent

## Overview

This is a **fully autonomous software engineering agent** that maintains and releases the IFSC dataset without manual intervention or brittle scripts.

### Key Innovation: Zero Scripts, 100% AI

Unlike traditional automation (which breaks when websites change), this agent:
- ✅ **Adapts** to RBI/NPCI website layout changes
- ✅ **Understands** data context and business logic
- ✅ **Decides** autonomously when to release
- ✅ **Recovers** from errors intelligently
- ✅ **Explains** all decisions in human language

## Architecture

### 3-Tier Agent Architecture

```
┌─────────────────────────────────────────┐
│   IFSC Release Manager (Orchestrator)   │
│   Main skill that coordinates workflow  │
└───────────────┬─────────────────────────┘
                │
    ┌───────────┴───────────┐
    │                       │
┌───▼────────┐      ┌───────▼──────┐
│ Sub-Skills │      │   Context    │
│  (Tools)   │      │  (Knowledge) │
└────────────┘      └──────────────┘
```

**Layer 1: Orchestrator** (`skill.md`)
- Main agent prompt
- Workflow coordination
- Decision gates

**Layer 2: Sub-Skills** (`sub-skills/*.md`)
- Specialized capabilities
- Domain expertise
- Reusable tools

**Layer 3: Context** (`context/*.md`)
- Domain knowledge
- Business rules
- Historical patterns

## Sub-Skills

| Sub-Skill | Purpose | AI Advantage |
|-----------|---------|--------------|
| `rbi-data-monitor` | Detect RBI/NPCI updates | Adapts to URL/layout changes |
| `ifsc-data-extractor` | Parse Excel/HTML files | Vision-based, format-agnostic |
| `ifsc-validator` | Validate data quality | Contextual anomaly detection |
| `dataset-generator` | Create release artifacts | Intelligent merging |
| `release-decision-maker` | Decide if/when to release | Multi-factor analysis |
| `git-orchestrator` | Manage Git operations | Error recovery, smart commits |
| `changelog-writer` | Generate release notes | Contextual summaries |
| `test-runner` | Execute test suites | Failure diagnosis |
| `quality-reviewer` | Review PR before merge | Holistic quality checks |
| `deployment-manager` | Publish to registries | Multi-platform orchestration |
| `swift-code-fetcher` | Extract SWIFT codes | PDF vision parsing |
| `sublet-detector` | Find sublet arrangements | Pattern recognition |
| `slack-communicator` | Notify team | Context-aware messaging |

## How It Works

### Daily Workflow

```
09:00 - GitHub Action triggers
09:01 - Agent: "Let me check for RBI updates..."
        ↓ Uses rbi-data-monitor
09:02 - Agent: "New data detected! Parsing..."
        ↓ Uses ifsc-data-extractor
09:03 - Agent: "Validating 247 new IFSCs..."
        ↓ Uses ifsc-validator
09:04 - Agent: "Generating release artifacts..."
        ↓ Uses dataset-generator
09:05 - Agent: "Should we release? Analyzing..."
        ↓ Uses release-decision-maker
        → Decision: RELEASE (v2.0.54, confidence 95%)
09:06 - Agent: "Creating release branch..."
        ↓ Uses git-orchestrator
09:08 - Agent: "Writing release notes..."
        ↓ Uses changelog-writer
09:09 - Agent: "Running tests..."
        ↓ Uses test-runner
        → All tests passing ✓
09:10 - Agent: "Reviewing PR quality..."
        ↓ Uses quality-reviewer
        → Approved ✓
09:11 - Agent: "Notifying team for approval..."
        ↓ Uses slack-communicator
        → Awaiting human approval

[Human approves PR]

09:25 - Agent: "Merging and deploying..."
        ↓ Uses git-orchestrator
        ↓ Uses deployment-manager
09:30 - Agent: "Release complete! 🎉"
        ↓ Uses slack-communicator
```

### Manual Invocation

From Claude Code CLI:
```bash
claude skill ifsc-release-manager
# Then: "Check for IFSC updates and release if needed"
```

From GitHub Actions:
```yaml
- name: IFSC Release Check
  run: |
    claude-agent invoke ifsc-release-manager \
      --task "Check for updates and create release"
```

From Slack:
```
/ifsc-release check
```

## AI vs Scripts Comparison

### Example: Parsing RBI Excel File

#### ❌ Old Way (Scripts)
```ruby
# scraper/scripts/methods.rb (500 lines)
xlsx = Roo::Spreadsheet.open('neft.xlsx')
sheet = xlsx.sheet('Sheet1')  # Hardcoded
headers = sheet.row(1)        # Assumes row 1
bank_col = headers.index('Bank Name')  # Exact match required

# Breaks when:
# - Sheet renamed
# - Headers moved to row 2
# - Column renamed to "Bank"
# - File format changes to CSV
```

#### ✅ New Way (AI-Driven)
```
Agent prompt:
"Parse this Excel file and extract all IFSC codes.
Find the table (it might be on any sheet, any row).
Return JSON with: ifsc, bank, branch, city, state."

Claude:
- Reads file visually (multimodal)
- Identifies table structure
- Handles merged cells
- Adapts to any layout
- Never breaks on format changes
```

**Result**: Same parsing task, but AI-driven approach works for ANY format change RBI makes.

## Key Advantages

### 1. Antifragile to Changes
**Scripts break, AI adapts**

```
RBI changes:
- URL changes → AI finds new URL via search
- Excel → CSV → AI parses both
- Column reorder → AI identifies columns by content
- Sheet rename → AI finds data sheet
```

### 2. Intelligent Decision Making
**Scripts follow rules, AI understands context**

```
Scenario: 5,000 IFSCs deleted

Script: "Changes detected, releasing v2.0.54"

AI: "Wait, 5,000 deletions is suspicious.
     Let me verify:
     - Is file corrupted?
     - Did RBI make a mistake?
     - Is this a bank merger?
     Decision: INVESTIGATE, not RELEASE"
```

### 3. Self-Healing
**Scripts fail, AI recovers**

```
Error: RBI website timeout

Script: [FAILS]

AI: "RBI unreachable. Let me:
     1. Wait 5 minutes, retry
     2. Check if it's a known outage
     3. Try archive.org mirror
     4. Notify team if still failing
     5. Schedule retry in 1 hour"
```

### 4. Contextual Communication
**Scripts log errors, AI explains**

```
Script: "ERROR: version mismatch"

AI: "I detected an issue while preparing release v2.0.54:
     - package.json says 2.0.53
     - ifsc.gemspec says 2.0.52

     This inconsistency needs manual fix before release.
     Would you like me to:
     1. Update both to 2.0.54
     2. Investigate why gemspec is behind"
```

## Setting Up Triggers

### Option 1: GitHub Actions (Recommended)

Create `.github/workflows/ifsc-auto-release.yml`:

```yaml
name: IFSC Auto Release

on:
  schedule:
    - cron: '0 9 * * *'  # Daily at 9 AM IST
  workflow_dispatch:      # Manual trigger

jobs:
  release-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Claude Code
        run: |
          npm install -g @anthropic/claude-code

      - name: Run IFSC Release Manager
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          claude skill ifsc-release-manager <<EOF
          Check for IFSC updates from RBI/NPCI.
          If updates found, create a release PR.
          Follow the complete workflow autonomously.
          EOF
```

### Option 2: Slack Integration

Setup webhook that triggers agent:
```
/ifsc-release check → Triggers GitHub Action
/ifsc-release status → Shows current release state
```

### Option 3: Email Trigger

When "RBI Updates" email arrives:
```
Email → Zapier/n8n → GitHub Actions dispatch → Agent runs
```

## Configuration

### Environment Variables

```bash
# Required
ANTHROPIC_API_KEY=sk-ant-...
GITHUB_TOKEN=ghp_...

# Optional
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
DRY_RUN=true  # Test mode, don't actually create PRs
```

### Settings

Edit `skill.md` to customize:

```markdown
## Your Mission

[Customize agent behavior here]

## Decision-Making Guidelines

[Adjust release criteria]
```

## Monitoring & Observability

### Agent Logs

All agent actions are logged:
```
[2025-01-17 09:01:23] Starting daily check
[2025-01-17 09:01:45] rbi-data-monitor: Change detected
[2025-01-17 09:02:10] ifsc-data-extractor: Extracted 247 new IFSCs
[2025-01-17 09:03:05] release-decision-maker: RELEASE (95% confidence)
[2025-01-17 09:10:30] git-orchestrator: PR #447 created
[2025-01-17 09:11:00] Awaiting human approval
```

### Success Metrics

Track in GitHub Actions:
- Time to release (goal: <2 hours)
- Automation rate (goal: >90% zero-touch)
- Accuracy (goal: >99% no rollbacks)
- False positives (goal: <5%)

### Slack Notifications

Agent posts to #tech_ifsc:
```
🤖 IFSC Release Manager

✅ New release PR created: #447
📊 Changes: +247 new, -12 removed
🏦 Banks: HDFC (180), SBI (42), ICICI (25)
⏱️ Time: 9 minutes
🎯 Confidence: 95%

👉 Review here: https://github.com/razorpay/ifsc/pull/447
```

## Safety & Rollback

### Human Approval Gates

Agent ALWAYS waits for human approval before:
- Merging PR to master
- Publishing to production
- Making breaking changes

### Dry Run Mode

Test without side effects:
```bash
DRY_RUN=true claude skill ifsc-release-manager
# Agent simulates workflow, doesn't create actual PRs
```

### Rollback Procedure

If release has issues:
```bash
# Agent can roll back
claude skill ifsc-release-manager <<EOF
Rollback release v2.0.54
Reason: Data corruption detected in HDFC branches
EOF

# Agent will:
# 1. Revert Git commits
# 2. Unpublish packages (where possible)
# 3. Restore previous version
# 4. Notify team
```

## Extending the Agent

### Adding New Sub-Skills

Create `sub-skills/my-new-skill.md`:
```markdown
# My New Sub-Skill

## Purpose
[What it does]

## Execution Flow
[How it works]

## Usage
[When agent should use this]
```

Then update `skill.md`:
```markdown
### 14. `my-new-skill`
**Purpose**: [Brief description]
```

### Adding Domain Knowledge

Edit `context/ifsc-domain-knowledge.md`:
```markdown
## New Section

[Add new rules, patterns, or business logic]
```

Agent will use this knowledge in future runs.

## Troubleshooting

### Agent Not Detecting Changes

Check:
1. RBI website accessible?
2. File format changed?
3. Agent has correct URLs?

Debug:
```bash
claude skill ifsc-release-manager <<EOF
Debug mode: Show me what URLs you're checking and what you find.
EOF
```

### Agent Making Wrong Decisions

Adjust decision thresholds in `sub-skills/release-decision-maker.md`:
```markdown
## Decision Matrix

- <50 changes → skip (was 50, now 30)
- >500 changes → minor (was 500, now 750)
```

### Tests Failing

Agent will diagnose:
```
Test failure detected in PHP suite.

Analysis:
- New IFSC HDFC9999999 has invalid bank code
- Bank code should be 4 letters, got 8

Root cause: Extractor bug, needs fix.
Creating issue: #448
```

## Future Enhancements

Planned improvements:
- [ ] Multi-agent coordination (one agent per SDK)
- [ ] Predictive release scheduling
- [ ] Auto-fix common test failures
- [ ] Learn from past releases
- [ ] Integration with Razorpay production API

## Support

For issues:
1. Check agent logs
2. Run in dry-run mode
3. Ask agent to explain its reasoning
4. File GitHub issue

## License

MIT License (same as main IFSC repo)

---

**This is the future of repository maintenance**: AI agents that understand your domain, make intelligent decisions, and adapt to changes without breaking.

No more brittle scripts. No more manual releases. Just smart, autonomous software engineering.
