/// Performance tracking and regression detection utilities
///
/// Provides utilities for measuring and tracking performance metrics across test runs.
/// Integrates with CI/CD for regression detection and historical trend analysis.
library;

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Performance measurement data for a single operation
class PerformanceMetric {
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  PerformanceMetric({
    required this.name,
    required this.duration,
    required this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'duration_ms': duration.inMilliseconds,
    'duration_us': duration.inMicroseconds,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory PerformanceMetric.fromJson(Map<String, dynamic> json) =>
      PerformanceMetric(
        name: json['name'] as String,
        duration: Duration(milliseconds: json['duration_ms'] as int),
        timestamp: DateTime.parse(json['timestamp'] as String),
        metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      );

  @override
  String toString() =>
      '$name: ${duration.inMilliseconds}ms (${duration.inMicroseconds}μs)';
}

/// Aggregated performance statistics
class PerformanceStats {
  final String name;
  final List<PerformanceMetric> metrics;

  PerformanceStats({
    required this.name,
    required this.metrics,
  });

  /// Average duration across all measurements
  Duration get averageDuration {
    if (metrics.isEmpty) return Duration.zero;
    final totalMs =
        metrics.fold<int>(0, (sum, m) => sum + m.duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ metrics.length);
  }

  /// Minimum duration across all measurements
  Duration get minDuration {
    if (metrics.isEmpty) return Duration.zero;
    return metrics.reduce((a, b) => a.duration < b.duration ? a : b).duration;
  }

  /// Maximum duration across all measurements
  Duration get maxDuration {
    if (metrics.isEmpty) return Duration.zero;
    return metrics.reduce((a, b) => a.duration > b.duration ? a : b).duration;
  }

  /// Standard deviation of measurements
  double get standardDeviation {
    if (metrics.length < 2) return 0.0;
    final avg = averageDuration.inMilliseconds.toDouble();
    final sumSquaredDiff = metrics.fold<double>(
      0,
      (sum, m) {
        final diff = m.duration.inMilliseconds - avg;
        return sum + (diff * diff);
      },
    );
    return sqrt(sumSquaredDiff / (metrics.length - 1));
  }

  /// Percentile duration (e.g., p95 = 95th percentile)
  Duration percentileDuration(double percentile) {
    if (metrics.isEmpty) return Duration.zero;
    final sorted = List<PerformanceMetric>.from(metrics)
      ..sort((a, b) => a.duration.compareTo(b.duration));
    final index = ((percentile / 100) * sorted.length).ceil() - 1;
    return sorted[index.clamp(0, sorted.length - 1)].duration;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'count': metrics.length,
    'average_ms': averageDuration.inMilliseconds,
    'min_ms': minDuration.inMilliseconds,
    'max_ms': maxDuration.inMilliseconds,
    'p50_ms': percentileDuration(50).inMilliseconds,
    'p95_ms': percentileDuration(95).inMilliseconds,
    'p99_ms': percentileDuration(99).inMilliseconds,
    'std_dev': standardDeviation,
    'metrics': metrics.map((m) => m.toJson()).toList(),
  };

  @override
  String toString() =>
      '''$name:
  Count: ${metrics.length}
  Average: ${averageDuration.inMilliseconds}ms
  Min: ${minDuration.inMilliseconds}ms
  Max: ${maxDuration.inMilliseconds}ms
  P50: ${percentileDuration(50).inMilliseconds}ms
  P95: ${percentileDuration(95).inMilliseconds}ms
  P99: ${percentileDuration(99).inMilliseconds}ms
  Std Dev: ${standardDeviation.toStringAsFixed(2)}ms''';
}

/// Tracks performance metrics across multiple measurements
class PerformanceTracker {
  final Map<String, List<PerformanceMetric>> _metrics = {};

  /// Measure the duration of a synchronous operation
  T measure<T>(
    String name,
    T Function() operation, {
    Map<String, dynamic>? metadata,
  }) {
    final stopwatch = Stopwatch()..start();
    try {
      return operation();
    } finally {
      stopwatch.stop();
      _recordMetric(
        PerformanceMetric(
          name: name,
          duration: stopwatch.elapsed,
          metadata: metadata ?? {},
        ),
      );
    }
  }

  /// Measure the duration of an async operation
  Future<T> measureAsync<T>(
    String name,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      return await operation();
    } finally {
      stopwatch.stop();
      _recordMetric(
        PerformanceMetric(
          name: name,
          duration: stopwatch.elapsed,
          metadata: metadata ?? {},
        ),
      );
    }
  }

  /// Manually record a performance metric
  void recordMetric(PerformanceMetric metric) {
    _recordMetric(metric);
  }

  void _recordMetric(PerformanceMetric metric) {
    _metrics.putIfAbsent(metric.name, () => []).add(metric);
  }

  /// Get statistics for a specific metric
  PerformanceStats? getStats(String name) {
    final metrics = _metrics[name];
    if (metrics == null || metrics.isEmpty) return null;
    return PerformanceStats(name: name, metrics: metrics);
  }

  /// Get all recorded metrics
  List<PerformanceMetric> getAllMetrics() {
    return _metrics.values.expand((m) => m).toList();
  }

  /// Get statistics for all metrics
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    for (final entry in _metrics.entries) {
      stats[entry.key] =
          PerformanceStats(name: entry.key, metrics: entry.value);
    }
    return stats;
  }

  /// Assert that average duration is below threshold
  void assertAverageBelowThreshold(
    String name,
    Duration threshold, {
    String? reason,
  }) {
    final stats = getStats(name);
    expect(
      stats != null && stats.averageDuration <= threshold,
      isTrue,
      reason:
          reason ?? '$name average ${stats?.averageDuration} exceeded $threshold',
    );
  }

  /// Assert that p95 duration is below threshold
  void assertP95BelowThreshold(
    String name,
    Duration threshold, {
    String? reason,
  }) {
    final stats = getStats(name);
    final p95 = stats?.percentileDuration(95) ?? Duration.zero;
    expect(
      p95 <= threshold,
      isTrue,
      reason: reason ?? '$name p95 $p95 exceeded $threshold',
    );
  }

  /// Assert that max duration is below threshold
  void assertMaxBelowThreshold(
    String name,
    Duration threshold, {
    String? reason,
  }) {
    final stats = getStats(name);
    expect(
      stats != null && stats.maxDuration <= threshold,
      isTrue,
      reason: reason ?? '$name max ${stats?.maxDuration} exceeded $threshold',
    );
  }

  /// Export metrics as JSON
  String exportAsJson({bool pretty = true}) {
    final allStats = getAllStats();
    final json = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'metrics': {
        for (final entry in allStats.entries) entry.key: entry.value.toJson(),
      },
    };
    return pretty ? jsonEncode(json) : jsonEncode(json);
  }

  /// Export metrics as CSV (header + data rows)
  String exportAsCsv() {
    final metrics = getAllMetrics();
    if (metrics.isEmpty) return 'name,duration_ms,timestamp\n';

    final buffer = StringBuffer('name,duration_ms,timestamp\n');
    for (final metric in metrics) {
      buffer.writeln(
        '${metric.name},${metric.duration.inMilliseconds},${metric.timestamp.toIso8601String()}',
      );
    }
    return buffer.toString();
  }

  /// Print summary report
  void printReport() {
    final allStats = getAllStats();
    if (allStats.isEmpty) {
      debugPrint('No performance metrics recorded');
      return;
    }

    debugPrint('\n${'=' * 60}');
    debugPrint('PERFORMANCE REPORT');
    debugPrint('=' * 60);

    for (final entry in allStats.entries) {
      debugPrint('\n${entry.value}');
    }

    debugPrint('\n${'=' * 60}');
  }

  /// Clear all recorded metrics
  void clear() {
    _metrics.clear();
  }

  /// Get metric count
  int get metricCount => _metrics.values.fold(0, (sum, list) => sum + list.length);
}

/// Single-use performance stopwatch with automatic recording
class AutoStopwatch {
  final String name;
  final PerformanceTracker tracker;
  final Map<String, dynamic>? metadata;
  late final Stopwatch _stopwatch;

  AutoStopwatch(
    this.name,
    this.tracker, {
    this.metadata,
  }) {
    _stopwatch = Stopwatch()..start();
  }

  /// Stop the stopwatch and record the metric
  void stop() {
    _stopwatch.stop();
    tracker.recordMetric(
      PerformanceMetric(
        name: name,
        duration: _stopwatch.elapsed,
        metadata: metadata ?? {},
      ),
    );
  }
}
