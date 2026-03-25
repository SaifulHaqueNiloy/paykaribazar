# AI System Monitoring & Operations Guide

**Comprehensive guide for monitoring and managing the Paykari Bazar AI system**

Created: March 23, 2026  
Status: ✅ Production-Ready

---

## 📋 Quick Reference

| Task | Where | How |
|------|-------|-----|
| View system health | Admin Dashboard | Open "📊 Dashboard" tab |
| Check cache performance | Admin Dashboard | Open "📈 Metrics" tab |
| Adjust rate limits | Admin Dashboard | Open "⚙️ Config" > "Rate Limits" |
| Review alerts | Admin Dashboard | Open "🚨 Alerts" tab |
| View error logs | Firestore console | Collection: `ai_error_logs` |
| View request logs | Firestore console | Collection: `ai_request_logs` |
| Check quota usage | System Health | "Daily Quota" metric |
| Analyze trends | Admin Dashboard | 24-hour trends displayed |

---

## 🟢 Green Light - All Systems Operational

```
Status: 🟢 Healthy
Daily Quota: 20-70% used
Cache Hit Rate: 60-70%+
Response Time: 100-2000ms
Error Rate: 0-20/day
Requests/Min: < 30
Actions: None needed - Monitor regularly
```

**What to do:** Continue normal operations. Check dashboard weekly for trends.

---

## 🟡 Yellow Light - Needs Attention

```
Status: 🟡 Degraded
Daily Quota: 70-80% used
Cache Hit Rate: 40-60%
Response Time: 2000-5000ms
Error Rate: 20-50/day
Requests/Min: 40-60
Actions: 
  1. Investigate what's different
  2. Check error logs
  3. Consider temporary limit increase
  4. Optimize prompts
```

**What to do:**
1. Review error logs in Firestore (`ai_error_logs`)
2. Check if cache hit rate dropped (indicates prompt changes)
3. Consider increasing rate limit temporarily
4. Optimize prompts to reduce response time

---

## 🔴 Red Light - Critical Issues

```
Status: 🔴 Error
Daily Quota: 80-100% used
Cache Hit Rate: < 40%
Response Time: > 5000ms
Error Rate: > 50/day
Requests/Min: 60 (at limit)
Actions:
  1. IMMEDIATELY increase quota
  2. Check error logs for root cause
  3. Consider emergency fallback
  4. Notify team leads
```

**What to do:**
1. Immediately increase daily quota limit via dashboard
2. Review recent error logs for patterns
3. Consider enabling fallback models
4. Ready to implement emergency measures

---

## 📊 Daily Operations Checklist

### Morning (9 AM)
- [ ] Open Admin Dashboard
- [ ] Check system status indicator
- [ ] Review yesterday's quota usage
- [ ] Note any alerts from overnight

### Midday (1 PM)
- [ ] Verify quota usage is on track
- [ ] Check error rate trend
- [ ] Monitor if approaching 50% daily quota

### Evening (5 PM)
- [ ] Review day's metrics
- [ ] Project quota for end of day
- [ ] Check if any critical alerts need response
- [ ] Plan for tomorrow's demand

---

## 🚨 Alert Response Guide

### Alert: "Critical: 90% Daily Quota Used"
**Severity:** 🚨 CRITICAL

**Response:**
1. Open Admin Dashboard → ⚙️ Config
2. Click "Adjust Rate Limits"
3. Increase `dailyQuotaLimit` by 50-100%
4. Click Save
5. Log the change with reason
6. Notify team of increase

**Prevention:**
- Monitor quota at 70% mark
- Plan for traffic increases
- Implement request batching

---

### Alert: "Warning: 80% Daily Quota Used"
**Severity:** ⚠️ WARNING

**Response:**
1. Check if this is normal for this day of week
2. Review request patterns in `ai_request_logs`
3. If trending high, prepare quota increase
4. Document the usage pattern

**Prevention:**
- Notify teams to optimize prompts
- Encourage cache reuse
- Consider off-peak processing

---

### Alert: "Warning: Slow Response Times"
**Severity:** ⚠️ WARNING

**Response:**
1. Check Firestore query performance
2. Verify network connectivity
3. Review if peak traffic time
4. Check for service degradation

**Investigation:**
```dart
// In console or code
final logs = await FirebaseFirestore.instance
    .collection('ai_request_logs')
    .where('status', isEqualTo: 'success')
    .orderBy('duration_ms', descending: true)
    .limit(10)
    .get();
    
// Those with highest duration_ms are slowest
```

---

### Alert: "Warning: High Error Rate"
**Severity:** ⚠️ WARNING

**Response:**
1. Open Firestore console
2. Check `ai_error_logs` collection
3. Group errors by `error_code`
4. Investigate top error types
5. Implement fixes if needed

**Common Error Codes:**
- `quotaExceeded` - Quota limit hit
- `timeout` - Requests taking too long
- `serverError` - API server issues (transient)
- `invalidRequest` - Malformed prompt
- `networkError` - Connectivity issues

---

## 📈 Monitoring Metrics

### Key Performance Indicators (KPIs)

**1. Cache Hit Rate**
- Target: 60-70%
- Formula: `cached_requests / total_requests * 100`
- Improvement: Increase prompt reuse, batch similar requests
- Impact: Every 10% increase = 10% cost savings

**2. Daily Quota Usage**
- Target: 50-80% by end of day
- Formula: `(total_requests_used / daily_limit) * 100`
- Red flag: > 80% before noon
- Action: Increase limit or reduce usage

**3. Response Time**
- Target: < 2000ms
- Normal: 100-500ms (cached), 1000-2000ms (API)
- Warning: > 3000ms
- Critical: > 5000ms

**4. Error Rate**
- Target: < 20 errors/day
- Warning: 20-50 errors
- Critical: > 50 errors
- Track: By error type, by user, by time

**5. Requests Per Minute**
- Limit: 60 requests/minute
- Warning: > 50 requests/minute (75% of limit)
- Critical: Reaching or exceeding limit
- Action: Scale or request API increase

---

## 🔧 Configuration Management

### Scenario 1: Traffic Surge Detected

**Symptom:** Quota usage at 90% by noon

**Response:**
```dart
final configManager = AIConfigurationManager();

// 1. Increase daily quota temporarily
await configManager.updateRateLimit(
  requestsPerMinute: 60,      // Keep same
  dailyQuotaLimit: 20000,     // Double from 10,000
);

// 2. Log the change
await configManager.logConfigChange(
  changeType: 'quota_increase',
  oldValues: {'daily_quota_limit': 10000},
  newValues: {'daily_quota_limit': 20000},
  changedBy: 'ops_team',
  reason: 'Unexpected traffic surge during lunch hours',
);

// 3. Monitor impact
print('Quota increased. Monitoring new usage...');
```

---

### Scenario 2: Cache Hit Rate Dropping

**Symptom:** Cache hit rate dropped from 65% to 45%

**Investigation:**
```dart
// Check what changed
final history = await configManager.getConfigChangeHistory(limit: 20);
for (final record in history) {
  print('${record.timestamp}: ${record.summary}');
}

// Check recent prompts in logs
final logs = await FirebaseFirestore.instance
    .collection('ai_request_logs')
    .orderBy('timestamp', descending: true)
    .limit(100)
    .get();

// Analyze prompt patterns
// If many unique prompts - cache will be low (expected)
// If prompts changed - may need optimization
```

**Action:**
1. Investigate what prompted the change
2. If it's temporary (one-off event), monitor
3. If prolonged, consider cache optimization
4. Increase cache duration or max entries if needed

---

### Scenario 3: Error Rate Spike

**Symptom:** Errors jumped from 5/day to 45/day

**Response:**
```dart
// 1. Get error distribution
final errorStats = await errorHandler.getErrorStats(days: 1);
print(errorStats); // See errors_by_type

// 2. Focus on most common error
// Example: If mostly quotaExceeded
if (errorStats['errors_by_type']['quotaExceeded'] > 20) {
  // Increase quota
  await configManager.updateRateLimit(
    requestsPerMinute: 60,
    dailyQuotaLimit: 15000,
  );
}

// 3. If mostly timeout errors
if (errorStats['errors_by_type']['timeout'] > 15) {
  // Increase timeout
  await configManager.updateTimeoutConfig(
    requestTimeoutSeconds: 45,  // Increase from 30
    streamTimeoutSeconds: 90,
  );
}
```

---

## 📊 Firestore Collections Reference

### Collection: `ai_request_logs`
```javascript
{
  timestamp: Timestamp,
  operation: string,          // generateResponse, etc
  model: string,              // gemini-2.0-flash
  user_id: string,            // user identifier
  prompt_length: number,      // characters
  used_cache: boolean,        // was it cached?
  response_length: number,    // response characters
  duration_ms: number,        // milliseconds
  tokens_used: number,        // token estimate
  status: string,             // success, error
  type: string,               // request, response
}
```

**Query Examples:**
```javascript
// Get all cache misses
db.collection('ai_request_logs')
  .where('used_cache', '==', false)
  .orderBy('timestamp', 'desc')
  .limit(100)

// Get slowest requests
db.collection('ai_request_logs')
  .where('status', '==', 'success')
  .orderBy('duration_ms', 'desc')
  .limit(10)

// Get requests by user
db.collection('ai_request_logs')
  .where('user_id', '==', 'user123')
  .orderBy('timestamp', 'desc')
```

---

### Collection: `ai_error_logs`
```javascript
{
  timestamp: Timestamp,
  operation: string,          // where error occurred
  error_code: string,         // quotaExceeded, timeout, etc
  error_message: string,      // error details
  user_id: string,            // affected user
  stack_trace: string,        // for debugging
  context: object,            // additional context
}
```

---

### Collection: `ai_health_logs`
```javascript
{
  timestamp: Timestamp,
  cache_hit_rate: number,
  remaining_quota: number,
  requests_per_minute: number,
  average_response_time_ms: number,
  total_requests: number,
  cached_requests: number,
  total_errors_24h: number,
  system_status: string,      // healthy, degraded, error
  neural_load: number,        // percentage
}
```

---

### Collection: `ai_config_history`
```javascript
{
  timestamp: Timestamp,
  change_type: string,        // what was changed
  old_values: object,         // previous config
  new_values: object,         // new config
  changed_by: string,         // admin user
  reason: string,             // why changed
}
```

---

## 🎯 Weekly Operations Report

**Instructions:** Complete this every Friday

```
Week of: [DATE]

System Health:
- [ ] Average daily quota usage: ____%
- [ ] Peak daily quota usage: ____%
- [ ] Average cache hit rate: ____%
- [ ] Average error rate: ___/day
- [ ] Average response time: ____ms

Incidents:
- [ ] Any critical alerts? ___________
- [ ] Any quota expansions? ___________
- [ ] Any configuration changes? ___________

Optimization Opportunities:
- [ ] Cache hit rate trending? ___________
- [ ] Response times stable? ___________
- [ ] Error rates normal? ___________

Notes:
_________________________________
_________________________________

Action Items for Next Week:
- [ ] _________________________________
- [ ] _________________________________
- [ ] _________________________________
```

---

## 🆘 Emergency Procedures

### Emergency: Quota Exhausted Mid-Day

**Immediate Response (< 5 minutes):**
1. Open Admin Dashboard
2. Go to ⚙️ Config tab
3. Click "Adjust Rate Limits"
4. Increase `dailyQuotaLimit` to 50,000
5. Click Save
6. Verify change applied

**Follow-up (within 1 hour):**
1. Notify team leads
2. Investigate root cause
3. Identify if temporary or new normal
4. Plan permanent quota adjustment

---

### Emergency: Response Time Degradation

**Immediate Response:**
1. Open ⚙️ Config tab
2. Check current timeout setting
3. If < 30sec, increase to 45sec
4. Monitor response times for improvement

**If Problem Persists:**
1. Switch to fallback model
2. Reduce per-minute limit to reduce load
3. Check Firestore console for service issues
4. Contact Firebase support if needed

---

### Emergency: Error Spike

**Immediate Response:**
1. Open 🚨 Alerts tab
2. Identify error type
3. Take action based on error type (see guide above)
4. Monitor error rate for resolution

---

## 📞 Escalation Path

```
Level 1: Monitoring
- Dashboard shows metric
- Investigator reviews logs
- Decision: Continue monitoring or escalate

Level 2: Standard Response
- Known issue with documented response
- Apply configuration change
- Monitor for effectiveness
- Document change and outcome

Level 3: Expert Review
- Unknown cause or complex issue
- Engage senior engineer
- May require Firebase support
- Document findings for future reference

Level 4: Emergency
- System critical or data at risk
- Page on-call engineer immediately
- Consider emergency quota increase
- Potentially activate secondary systems
```

---

## 📚 Related Documentation

- **[AI_SYSTEM_UPGRADES.md](AI_SYSTEM_UPGRADES.md)** - Technical upgrade details
- **[AI_SYSTEM_QUICK_REFERENCE.md](AI_SYSTEM_QUICK_REFERENCE.md)** - Developer guide
- **[AI_ADMIN_DASHBOARD_GUIDE.md](AI_ADMIN_DASHBOARD_GUIDE.md)** - Dashboard features
- **[UPGRADE_VERIFICATION.md](UPGRADE_VERIFICATION.md)** - Verification checklist

---

## 🎓 Training Checklist

**For new operations team members:**

- [ ] Read this entire guide
- [ ] Access Admin Dashboard
- [ ] Review current metrics
- [ ] Understand alert types
- [ ] Practice quota adjustment
- [ ] Review Firestore collections
- [ ] Study weekly report template
- [ ] Complete one on-call rotation
- [ ] Able to respond to all alert types
- [ ] Certified for independent operation

---

**Operations team ready for production!** 🚀
