# Slack Communicator Sub-Skill

## Purpose
Send automated notifications to team Slack channels about IFSC release progress, failures, and completions.

## When to Use
- When release process starts
- After successful release
- On critical errors or failures
- For major changes requiring attention
- Daily/weekly status updates

## Notification Types

### 1. Release Start Notification
**Trigger**: When release workflow begins

**Message**:
```
🔄 *IFSC Release Started*

Version: 2.0.54
Triggered by: @vikas.naidu
Branch: release/2.0.54

Data Sources:
• RBI NEFT: Updated Jan 17, 2026
• RBI RTGS: Updated Jan 17, 2026
• NPCI NACH: Cached (bot protection)

Estimated completion: ~5 minutes
Track progress: https://github.com/razorpay/ifsc/actions/runs/123456
```

**Slack API Call**:
```python
import requests

def notify_release_start(version, user, run_url):
    webhook_url = os.environ['SLACK_WEBHOOK_IFSC_RELEASES']

    payload = {
        "text": f"🔄 *IFSC Release Started*\nVersion: {version}",
        "blocks": [
            {
                "type": "header",
                "text": {"type": "plain_text", "text": "🔄 IFSC Release Started"}
            },
            {
                "type": "section",
                "fields": [
                    {"type": "mrkdwn", "text": f"*Version:*\n{version}"},
                    {"type": "mrkdwn", "text": f"*Triggered by:*\n@{user}"}
                ]
            },
            {
                "type": "actions",
                "elements": [
                    {
                        "type": "button",
                        "text": {"type": "plain_text", "text": "View Workflow"},
                        "url": run_url
                    }
                ]
            }
        ]
    }

    requests.post(webhook_url, json=payload)
```

### 2. Success Notification
**Trigger**: After successful release and deployment

**Message**:
```
✅ *IFSC Release v2.0.54 Deployed Successfully*

📊 Summary:
• Total IFSCs: 177,569 (+234)
• Added: 234 new branches
• Removed: 12 closed branches
• Modified: 1,023 updates

📦 Published:
• NPM: ifsc@2.0.54
• RubyGems: ifsc-2.0.54
• GitHub Release: v2.0.54

⏱️ Duration: 4 min 32 sec

🔗 Links:
• <https://github.com/razorpay/ifsc/releases/tag/v2.0.54|GitHub Release>
• <https://www.npmjs.com/package/ifsc|NPM Package>
• <https://rubygems.org/gems/ifsc|RubyGems>
```

**Implementation**:
```python
def notify_success(version, stats, duration, urls):
    payload = {
        "blocks": [
            {
                "type": "header",
                "text": {"type": "plain_text", "text": f"✅ IFSC Release v{version} Deployed"}
            },
            {
                "type": "section",
                "fields": [
                    {"type": "mrkdwn", "text": f"*Total IFSCs:*\n{stats['total']} (+{stats['added']})"},
                    {"type": "mrkdwn", "text": f"*Modified:*\n{stats['modified']} updates"},
                    {"type": "mrkdwn", "text": f"*Duration:*\n{duration}"},
                    {"type": "mrkdwn", "text": f"*Status:*\n:white_check_mark: All checks passed"}
                ]
            },
            {
                "type": "section",
                "text": {"type": "mrkdwn", "text": "*Published Packages:*\n• NPM: `ifsc@{version}`\n• RubyGems: `ifsc-{version}`\n• GitHub Release: `v{version}`"}
            },
            {
                "type": "actions",
                "elements": [
                    {"type": "button", "text": {"type": "plain_text", "text": "GitHub"}, "url": urls['github']},
                    {"type": "button", "text": {"type": "plain_text", "text": "NPM"}, "url": urls['npm']},
                    {"type": "button", "text": {"type": "plain_text", "text": "RubyGems"}, "url": urls['rubygems']}
                ]
            }
        ]
    }

    requests.post(SLACK_WEBHOOK, json=payload)
```

### 3. Failure Notification
**Trigger**: On critical errors during release

**Message**:
```
❌ *IFSC Release v2.0.54 Failed*

Error: Dataset validation failed
Stage: Quality Review

Details:
• 12 IFSCs have invalid format
• 234 entries missing required STATE field
• File 'data/by-bank.tar.gz' not generated

Action Required:
Review logs and fix errors before retrying.

🔗 <https://github.com/razorpay/ifsc/actions/runs/123456|View Logs>

@channel - Manual intervention needed
```

**Implementation**:
```python
def notify_failure(version, error, stage, details, run_url):
    payload = {
        "text": f"❌ IFSC Release v{version} Failed",
        "blocks": [
            {
                "type": "header",
                "text": {"type": "plain_text", "text": f"❌ IFSC Release v{version} Failed"}
            },
            {
                "type": "section",
                "fields": [
                    {"type": "mrkdwn", "text": f"*Error:*\n{error}"},
                    {"type": "mrkdwn", "text": f"*Stage:*\n{stage}"}
                ]
            },
            {
                "type": "section",
                "text": {"type": "mrkdwn", "text": f"*Details:*\n{details}"}
            },
            {
                "type": "context",
                "elements": [
                    {"type": "mrkdwn", "text": "<!channel> Manual intervention needed"}
                ]
            },
            {
                "type": "actions",
                "elements": [
                    {"type": "button", "text": {"type": "plain_text", "text": "View Logs"}, "url": run_url, "style": "danger"}
                ]
            }
        ]
    }

    requests.post(SLACK_WEBHOOK, json=payload)
```

### 4. Warning Notification
**Trigger**: Non-critical issues that need attention

**Message**:
```
⚠️ *IFSC Release v2.0.54 - Warning*

Issue: Bank count decreased by 2

Details:
• Removed banks: BKDN, CSBK
• Reason: Likely bank mergers
• Impact: 456 IFSCs affected

This may be expected. Review before proceeding.

<https://github.com/razorpay/ifsc/pull/450|View PR>
```

### 5. Data Change Alert
**Trigger**: Significant data changes detected

**Message**:
```
📊 *IFSC Data Changes Detected*

RBI Update: Jan 17, 2026

Changes:
• 234 new branches (State Bank of India: 89, HDFC: 45, Others: 100)
• 12 closures (Punjab National Bank: 8, Others: 4)
• 67 SWIFT code updates (SBI international branches)

Expected release: Today 6 PM IST

<https://github.com/razorpay/ifsc/actions|Monitor Workflow>
```

### 6. Daily Status Update
**Trigger**: Cron job (daily at 9 AM IST)

**Message**:
```
📅 *IFSC Dataset Status - Jan 17, 2026*

Current Version: 2.0.53 (released Jan 9, 2026)

Data Freshness:
• RBI NEFT: 11 days old (Last update: Jan 6)
• RBI RTGS: 9 days old (Last update: Jan 8)
• NPCI NACH: Using cached data

⚠️ Recommendation: Check for updates manually (NPCI bot protection active)

Last release: 8 days ago
Average release frequency: 1 per week
```

## Slack Channel Strategy

### Channels

1. **#ifsc-releases** (Primary)
   - All release notifications
   - Success/failure messages
   - Deployment confirmations

2. **#ifsc-alerts** (Critical Only)
   - Failures requiring immediate action
   - Data integrity issues
   - Deployment failures

3. **#data-updates** (Monitoring)
   - Daily status updates
   - Data freshness checks
   - RBI/NPCI update notifications

## Configuration

### Environment Variables
```bash
# Slack webhook URLs
SLACK_WEBHOOK_IFSC_RELEASES=https://hooks.slack.com/services/T00/B00/xxx
SLACK_WEBHOOK_IFSC_ALERTS=https://hooks.slack.com/services/T00/B01/yyy
SLACK_WEBHOOK_DATA_UPDATES=https://hooks.slack.com/services/T00/B02/zzz

# Notification preferences
SLACK_NOTIFY_ON_START=true
SLACK_NOTIFY_ON_SUCCESS=true
SLACK_NOTIFY_ON_FAILURE=true
SLACK_NOTIFY_ON_WARNING=true
SLACK_MENTION_CHANNEL_ON_FAILURE=true
```

### Webhook Setup
```bash
# Create incoming webhooks in Slack:
# 1. Go to https://api.slack.com/apps
# 2. Select app (or create new)
# 3. Enable "Incoming Webhooks"
# 4. Add webhook for each channel
# 5. Copy URLs to environment variables
```

## Integration Points

### 1. Release Start (workflow begins)
```ruby
# At start of main workflow
notify_slack(
  type: 'start',
  version: VERSION,
  user: ENV['GITHUB_ACTOR'],
  run_url: "https://github.com/razorpay/ifsc/actions/runs/#{ENV['GITHUB_RUN_ID']}"
)
```

### 2. Data Changes Detected
```ruby
# After comparing with previous release
if changes > 50
  notify_slack(
    type: 'data_change',
    added: added_count,
    removed: removed_count,
    modified: modified_count,
    details: change_summary
  )
end
```

### 3. Quality Review Issues
```ruby
# After quality review
if warnings.any?
  notify_slack(
    type: 'warning',
    warnings: warnings,
    severity: 'medium'
  )
end

if errors.any?
  notify_slack(
    type: 'failure',
    errors: errors,
    severity: 'critical'
  )
  exit 1
end
```

### 4. Deployment Success
```ruby
# After successful GitHub release
notify_slack(
  type: 'success',
  version: VERSION,
  stats: release_stats,
  urls: {
    github: "https://github.com/razorpay/ifsc/releases/tag/v#{VERSION}",
    npm: "https://www.npmjs.com/package/ifsc",
    rubygems: "https://rubygems.org/gems/ifsc"
  }
)
```

## Rate Limiting

### Slack API Limits
- 1 message per second per webhook
- Burst: Up to 30 messages
- Throttle: Back off on 429 errors

**Implementation**:
```python
import time
from functools import wraps

def rate_limit(max_per_second):
    min_interval = 1.0 / max_per_second
    last_called = [0.0]

    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            elapsed = time.time() - last_called[0]
            if elapsed < min_interval:
                time.sleep(min_interval - elapsed)
            result = func(*args, **kwargs)
            last_called[0] = time.time()
            return result
        return wrapper
    return decorator

@rate_limit(max_per_second=1)
def send_slack_message(webhook, payload):
    return requests.post(webhook, json=payload)
```

## Error Handling

### Webhook Failure
```python
def notify_slack_safe(webhook, payload, retries=3):
    for attempt in range(retries):
        try:
            response = requests.post(webhook, json=payload, timeout=10)
            response.raise_for_status()
            return True
        except requests.exceptions.RequestException as e:
            if attempt < retries - 1:
                time.sleep(2 ** attempt)  # Exponential backoff
            else:
                log(f"Failed to send Slack notification after {retries} attempts: {e}", :warn)
                return False
```

### Fallback Notification
```python
# If Slack fails, fall back to email or logs
if not notify_slack_safe(webhook, payload):
    send_email_notification(payload)
    log_notification(payload)
```

## Message Templates

### Template Library
```python
TEMPLATES = {
    'start': {
        'icon': '🔄',
        'title': 'IFSC Release Started',
        'color': '#3AA3E3'
    },
    'success': {
        'icon': '✅',
        'title': 'IFSC Release Deployed',
        'color': '#36A64F'
    },
    'failure': {
        'icon': '❌',
        'title': 'IFSC Release Failed',
        'color': '#FF0000'
    },
    'warning': {
        'icon': '⚠️',
        'title': 'IFSC Release Warning',
        'color': '#FFA500'
    }
}

def build_message(template_type, **data):
    template = TEMPLATES[template_type]
    return {
        "attachments": [{
            "color": template['color'],
            "blocks": [
                {
                    "type": "header",
                    "text": {"type": "plain_text", "text": f"{template['icon']} {template['title']}"}
                },
                # ... dynamic content based on data ...
            ]
        }]
    }
```

## Success Criteria

- ✅ Notifications sent for all key events
- ✅ Messages contain actionable information
- ✅ Links to relevant resources included
- ✅ Error context provided for failures
- ✅ No notification spam (smart batching)

## Related Files

- Environment variables in CI/CD settings
- `.github/workflows/*.yml` - Workflow notification points
- `scraper/scripts/notify.rb` - Notification helper (to be created)

## Future Enhancements

### Interactive Notifications
```
Allow team to approve/reject releases from Slack:

"⚠️ Release v2.0.54 has 2 bank removals. Proceed?"
[Approve] [Reject] [Review Details]
```

### Metrics Dashboard
```
Weekly digest:
📊 *IFSC Metrics - Week 3, 2026*

Releases: 2
New IFSCs: 456
Average deploy time: 4m 23s
Success rate: 100%
```

### Smart Alerts
```
Use AI to detect anomalies:
"🤖 Unusual pattern: 89% of new IFSCs are from SBI.
This is 3x higher than average. Review recommended."
```

### Thread Updates
```
Create thread for each release:
- Start: "Release v2.0.54 started"
  ↳ Update: "Data generation complete"
  ↳ Update: "Tests passed"
  ↳ Final: "Deployed successfully ✅"
```
