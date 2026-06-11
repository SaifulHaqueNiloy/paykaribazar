# AI Admin Dashboard - Complete Guide

**Integration Date:** March 23, 2026  
**Status:** ✅ **PRODUCTION-READY**

---

## 📊 Overview

The AI Admin Dashboard provides real-time monitoring, analytics, and configuration management for the Paykari Bazar AI system. It gives operations teams full visibility into system health, usage patterns, and enables dynamic configuration adjustments.

---

## 🚀 Quick Start

### 1. Add to Your Navigation

```dart
// In your app router or navigation structure
GoRoute(
  path: '/admin/ai-dashboard',
  builder: (context, state) => const AIAdminDashboard(),
),

// Or simply navigate to it
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => const AIAdminDashboard(userId: currentUserId),
  ),
);
```

### 2. Access the Dashboard

```dart
// For admin users only - add permission check
if (userRole == 'admin') {
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => const AIAdminDashboard(),
  ));
}
```

### 3. Initialize on App Start

```dart
// In your main app initialization
Future<void> initializeAI() async {
  final aiService = getIt<AIService>();
  await aiService.initialize(userId: currentUserId);
  
  // Optional: Start logging health snapshots
  final monitor = AISystemHealthMonitor(aiService: aiService);
  Timer.periodic(Duration(minutes: 15), (_) {
    monitor.getCurrentHealth().then((health) {
      monitor.logHealthSnapshot(health);
    });
  });
}
```

---

## 📱 Dashboard Tabs

### Tab 1: 📊 Dashboard
**Main system overview with real-time metrics**

- Current system status indicator (🟢🟡🔴)
- Daily quota usage with visual progress bar
- Cache hit rate tracking
- Request rate per minute
- Average response time
- Error count (24h)
- Total requests processed

**Actions:**
- 🔄 Refresh - Update all metrics
- 📥 Export - Export diagnostics data

### Tab 2: 📈 Metrics
**Detailed performance metrics and trends**

- **Cache Performance**
  - Hit rate percentage
  - Total requests served
  - Requests from cache

- **Performance Metrics**
  - Average response time (ms)
  - Neural load percentage
  - Check duration (ms)

- **Quota Usage**
  - Requests used
  - Requests remaining
  - Usage percentage

### Tab 3: ⚙️ Configuration
**Runtime configuration adjustments**

- **Rate Limiting**
  - Requests per minute limit
  - Daily quota limit
  - Quick adjustment dialog

- **Cache Configuration**
  - Max cache entries
  - Cache duration (hours)
  - Real-time adjustment

- **Model Configuration**
  - Primary model selection
  - Fallback model selection
  - Model switching

- **Admin Actions**
  - Reset to defaults button

### Tab 4: 🚨 Alerts
**System alerts and notifications**

- Critical alerts (quota nearly full, system errors)
- Warning alerts (high response times, high error rates)
- Info alerts (normal operations)
- Timestamp for each alert
- Color-coded severity indicators

---

## 🔍 Key Features

### Real-Time Monitoring
```dart
// Get current health snapshot
final health = await monitor.getCurrentHealth(userId: userId);

print('Status: ${health.statusEmoji}');
print('Quota: ${health.remainingQuota}/${health.dailyQuotaLimit}');
print('Cache Hit Rate: ${health.cacheHitRate}%');
```

### Health Streaming
```dart
// Real-time health updates every 10 seconds
monitor.streamHealth(updateInterval: Duration(seconds: 10)).listen((health) {
  print('Health update: ${health.systemStatus}');
  updateUI(health);
});
```

### Historical Analysis
```dart
// Get health history from last 24 hours
final history = await monitor.getHealthHistory(hours: 24);
print('${history.length} health snapshots available');
```

### Trend Analytics
```dart
// Get 24-hour trends
final trends = await monitor.getHealthTrends(hours: 24);
print('Average cache hit rate: ${trends.averageCacheHitRate}%');
print('Peak requests/min: ${trends.peakRequestsPerMinute}');
print('Uptime: ${trends.uptimePercent}%');
```

### Smart Alerts
```dart
// Get active alerts based on current health
final alerts = monitor.getAlerts(health);
for (final alert in alerts) {
  print('${alert.severityLabel}: ${alert.title}');
  print('  ${alert.message}');
}
```

---

## ⚙️ Configuration Management

### Adjusting Rate Limits

**Via Dashboard:**
1. Navigate to ⚙️ Config tab
2. Click "Adjust Rate Limits"
3. Set new per-minute limit and daily quota
4. Click "Save"

**Programmatically:**
```dart
final configManager = AIConfigurationManager();

await configManager.updateRateLimit(
  requestsPerMinute: 100,  // Increase from 60
  dailyQuotaLimit: 20000,  // Increase from 10,000
);
```

### Adjusting Cache Settings

```dart
await configManager.updateCacheConfig(
  maxEntries: 1000,          // Increase cache size
  cacheDurationHours: 2,     // Longer cache TTL
);
```

### Changing Models

```dart
await configManager.updateModelConfig(
  primaryModel: 'gemini-2.0-flash',
  fallbackModel: 'gemini-1.5-pro',
);
```

### Updating Timeout Settings

```dart
await configManager.updateTimeoutConfig(
  requestTimeoutSeconds: 45,    // Increase timeout
  streamTimeoutSeconds: 90,     // Longer stream timeout
);
```

### Resetting to Defaults

```dart
await configManager.resetToDefaults();
```

---

## 📊 Understanding the Metrics

### Daily Quota
- **Definition:** Maximum requests allowed per calendar day
- **Default:** 10,000 requests/day
- **Alert:** Warning at 80%, Critical at 90%
- **Reset:** Automatically resets at midnight

### Cache Hit Rate
- **Definition:** Percentage of requests served from cache
- **Target:** 60-70% for optimal performance
- **Improvement:** Use similar prompts to increase hit rate
- **Impact:** Every 10% increase = 10% API cost reduction

### Requests Per Minute
- **Definition:** Current request rate
- **Limit:** 60 requests/minute (default)
- **Alert:** Triggered when limit is reached
- **Impact:** Prevents API rate limiting

### Response Time
- **Definition:** Average time to generate response
- **Target:** < 2000ms (with cache hits ~100ms)
- **Warning:** > 5000ms indicates performance issues
- **Factors:** Network latency, prompt complexity

### Error Rate (24h)
- **Definition:** Number of failed requests in last 24 hours
- **Target:** < 50 errors/day
- **Alert:** Triggered at > 50 errors
- **Analysis:** Check error logs for patterns

---

## 🚨 Alert Types

### Critical Alerts 🚨
- **90%+ Quota Used**: Daily limit nearly exhausted
- **System Status Error**: System not operating normally
- **Rate Limit Reached**: Per-minute limit exceeded

### Warning Alerts ⚠️
- **80%+ Quota Used**: Daily limit approaching
- **Slow Response Times**: Average > 5000ms
- **High Error Rate**: > 50 errors in 24 hours

### Info Alerts ℹ️
- **System Status Changes**: Healthy/Degraded transitions
- **Configuration Updates**: When settings change

---

## 📈 Usage Patterns to Monitor

### Healthy System
✅ Cache hit rate: 60-70%  
✅ Response time: 100-2000ms  
✅ Error rate: < 50/day  
✅ Quota usage: < 70% by end of day  
✅ Status: 🟢 Healthy  

### Needs Attention
⚠️ Cache hit rate: < 40%  
⚠️ Response time: > 3000ms  
⚠️ Error rate: 50-100/day  
⚠️ Quota usage: > 80% by midday  
⚠️ Status: 🟡 Degraded  

### Critical State
🚨 Cache hit rate: < 20%  
🚨 Response time: > 5000ms  
🚨 Error rate: > 100/day  
🚨 Quota usage: > 90%  
🚨 Status: 🔴 Error  

---

## 🔧 Optimization Tips

### Improve Cache Hit Rate
1. Batch similar requests together
2. Reuse exact prompts when possible
3. Increase cache duration if appropriate
4. Monitor cache statistics regularly

### Reduce Response Time
1. Check for network latency issues
2. Optimize prompt length
3. Consider fallback models
4. Monitor peak usage times

### Manage Quota Efficiently
1. Identify low-value requests
2. Optimize batching strategies
3. Use caching more aggressively
4. Monitor daily trends

### Reduce Error Rate
1. Check error logs for patterns
2. Validate prompts before sending
3. Implement better timeout handling
4. Review rate limit configuration

---

## 📊 Integration Examples

### Add to Existing Admin Panel

```dart
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const Text('Admin Control Center'),
          ListTile(
            title: const Text('AI System Dashboard'),
            leading: const Icon(Icons.analytics),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AIAdminDashboard(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Add Dashboard Widget to Home

```dart
class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(currentHealthProvider);
    
    return Scaffold(
      body: Column(
        children: [
          healthAsync.when(
            data: (health) => Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('AI System: ${health.statusEmoji}'),
                    Text('Quota: ${health.remainingQuota}'),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AIAdminDashboard(),
                        ),
                      ),
                      child: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔐 Security Considerations

### Access Control
```dart
// Do NOT show dashboard to regular users
if (user.role != 'admin') {
  return Unauthorized(); // Show error
}

// Only super-admins can reset configuration
if (user.role != 'super_admin') {
  disableButton('Reset to Defaults');
}
```

### Activity Logging
- All configuration changes are logged to Firestore
- Includes who made the change and when
- Available in configuration change history

### Sensitive Data
- API keys are never displayed
- Errors don't include full prompts
- Access logs are stored securely

---

## 📚 API Reference

### AISystemHealthMonitor

```dart
class AISystemHealthMonitor {
  // Get current health snapshot
  Future<AISystemHealth> getCurrentHealth({String? userId})
  
  // Stream real-time health updates
  Stream<AISystemHealth> streamHealth({
    String? userId,
    Duration updateInterval = const Duration(seconds: 10),
  })
  
  // Get historical data
  Future<List<AISystemHealth>> getHealthHistory({int hours = 24})
  
  // Analyze trends
  Future<AIHealthTrends> getHealthTrends({int hours = 24})
  
  // Get active alerts
  List<AIHealthAlert> getAlerts(AISystemHealth health)
  
  // Log snapshot for history
  Future<void> logHealthSnapshot(AISystemHealth health)
}
```

### AIConfigurationManager

```dart
class AIConfigurationManager {
  // Get current overrides
  Future<AIConfigOverrides> getCurrentOverrides()
  
  // Update rate limits
  Future<void> updateRateLimit({
    required int requestsPerMinute,
    required int dailyQuotaLimit,
  })
  
  // Update cache
  Future<void> updateCacheConfig({
    required int maxEntries,
    required int cacheDurationHours,
  })
  
  // Update retry strategy
  Future<void> updateRetryConfig({
    required int maxRetries,
    required int initialDelayMs,
    required double backoffMultiplier,
  })
  
  // Update timeouts
  Future<void> updateTimeoutConfig({
    required int requestTimeoutSeconds,
    required int streamTimeoutSeconds,
  })
  
  // Update models
  Future<void> updateModelConfig({
    required String primaryModel,
    required String fallbackModel,
  })
  
  // Reset to defaults
  Future<void> resetToDefaults()
  
  // Get change history
  Future<List<ConfigChangeRecord>> getConfigChangeHistory({int limit = 50})
}
```

---

## 💡 Best Practices

1. **Regular Monitoring** - Check dashboard weekly to identify trends
2. **Proactive Adjustments** - Adjust limits before hitting constraints
3. **Document Changes** - Always note reason for configuration changes
4. **Alert Responses** - Act within 1 hour of critical alerts
5. **Performance Review** - Analyze trends monthly for optimization
6. **Backup Overrides** - Test changes in staging first
7. **Gradual Changes** - Adjust limits incrementally, not drastically

---

## 🆘 Troubleshooting

### Dashboard Shows "Error"
- Check Firestore connectivity
- Verify user has read permissions
- Refresh the app

### Metrics Not Updating
- Check if AI service is initialized
- Verify Firestore collections exist
- Look for network connectivity issues

### Configuration Changes Not Applied
- Restart the app
- Check if user has write permissions
- Verify changes in Firestore

### Missing Historical Data
- Wait 15 minutes for first health log (first interval)
- Check if logging is enabled
- Verify Firestore storage has space

---

**Dashboard ready for production use!** 🚀
