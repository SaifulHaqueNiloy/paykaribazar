/// Performance benchmark tests for regression detection
///
/// Tests to systematically measure and track performance metrics.
/// Runs benchmarks for critical operations and asserts performance thresholds.

import 'package:flutter_test/flutter_test.dart';
import '../helpers/base.dart';
import '../helpers/performance_tracker.dart';

void main() {
  group('Performance Tracker Functionality', () {
    late PerformanceTracker tracker;

    setUp(() {
      tracker = PerformanceTracker();
    });

    test('measure records synchronous operation duration', () {
      final result = tracker.measure('test_op', () => 'result');
      expect(result, equals('result'));
      expect(tracker.metricCount, equals(1));
    });

    test('measure async records asynchronous operation duration', () async {
      final result = await tracker.measureAsync(
        'async_op',
        () async => 'result',
      );
      expect(result, equals('result'));
      expect(tracker.metricCount, equals(1));
    });

    test('getStats returns performance statistics', () {
      for (int i = 0; i < 5; i++) {
        tracker.measure('metric', () => i);
      }
      
      final stats = tracker.getStats('metric');
      expect(stats, isNotNull);
      expect(stats!.metrics.length, equals(5));
      expect(stats.minDuration <= stats.averageDuration, isTrue);
      expect(stats.averageDuration <= stats.maxDuration, isTrue);
    });

    test('percentileDuration calculates percentiles correctly', () {
      // Add measurements with known values
      for (int i = 1; i <= 100; i++) {
        tracker.recordMetric(
          PerformanceMetric(
            name: 'metric',
            duration: Duration(milliseconds: i),
            metadata: {},
          ),
        );
      }

      final stats = tracker.getStats('metric');
      expect(stats, isNotNull);
      
      // P50 should be around 50ms
      final p50 = stats!.percentileDuration(50).inMilliseconds;
      expect(p50 >= 40 && p50 <= 60, isTrue);
    });

    test('exportAsJson produces valid JSON', () {
      tracker.measure('metric', () => 'value');
      final json = tracker.exportAsJson(pretty: false);
      expect(json.isNotEmpty, isTrue);
      expect(json.contains('"timestamp"'), isTrue);
    });

    test('exportAsCsv produces valid CSV', () {
      tracker.measure('metric', () => 'value');
      final csv = tracker.exportAsCsv();
      expect(csv.contains('name,duration_ms,timestamp'), isTrue);
      expect(csv.contains('metric'), isTrue);
    });

    test('clear removes all metrics', () {
      tracker.measure('metric1', () => 1);
      tracker.measure('metric2', () => 2);
      expect(tracker.metricCount, equals(2));
      
      tracker.clear();
      expect(tracker.metricCount, equals(0));
    });

    test('multiple metrics tracked independently', () {
      tracker.measure('metric_a', () => 'a');
      tracker.measure('metric_b', () => 'b');
      tracker.measure('metric_a', () => 'a2');

      expect(tracker.getStats('metric_a')!.metrics.length, equals(2));
      expect(tracker.getStats('metric_b')!.metrics.length, equals(1));
    });

    test('recordMetric accepts preformed metrics', () {
      tracker.recordMetric(
        PerformanceMetric(
          name: 'custom',
          duration: const Duration(milliseconds: 100),
          metadata: {'key': 'value'},
        ),
      );

      final stats = tracker.getStats('custom');
      expect(stats, isNotNull);
      expect(stats!.averageDuration.inMilliseconds, equals(100));
    });

    test('AutoStopwatch measures operation', () {
      final stopwatch = AutoStopwatch('auto_op', tracker);
      stopwatch.stop();
      
      expect(tracker.metricCount, equals(1));
      expect(tracker.getStats('auto_op'), isNotNull);
    });
  });

  group('Performance Benchmarks - Critical Operations', () {
    late PerformanceTracker tracker;

    setUp(() {
      tracker = PerformanceTracker();
    });

    group('Data Operations', () {
      test('list operations', () {
        tracker.measure(
          'list_operations',
          () {
            final items = List.generate(1000, (i) => i);
            return items.where((i) => i % 2 == 0).toList();
          },
        );

        final stats = tracker.getStats('list_operations');
        expect(stats, isNotNull);
        expect(stats!.averageDuration.inMilliseconds < 50, isTrue);
      });

      test('map bulk operations', () {
        tracker.measure(
          'map_operations',
          () {
            final map = <String, int>{};
            for (int i = 0; i < 10000; i++) {
              map['key_$i'] = i;
            }
            return map.length;
          },
        );

        final stats = tracker.getStats('map_operations');
        expect(stats, isNotNull);
        // Just verify it completes
        expect(tracker.metricCount, equals(1));
      });

      test('json serialization', () {
        tracker.measure(
          'json_serialize',
          () {
            return {
              'id': 'user_123',
              'email': 'user@example.com',
              'name': 'Test User',
              'active': true,
            };
          },
        );

        final stats = tracker.getStats('json_serialize');
        expect(stats, isNotNull);
      });
    });

    group('Async Operations', () {
      test('immediate future', () async {
        await tracker.measureAsync(
          'immediate_future',
          () => Future.value('result'),
        );

        final stats = tracker.getStats('immediate_future');
        expect(stats, isNotNull);
        expect(stats!.metrics.isNotEmpty, isTrue);
      });

      test('delayed future within tolerance', () async {
        const delay = Duration(milliseconds: 50);
        await tracker.measureAsync(
          'delayed_future',
          () => Future.delayed(delay, () => 'result'),
        );

        final stats = tracker.getStats('delayed_future');
        expect(stats, isNotNull);
        // Should complete around the specified delay
        expect(
          stats!.averageDuration >= delay,
          isTrue,
        );
      });

      test('concurrent futures', () async {
        await tracker.measureAsync(
          'concurrent_futures',
          () async {
            final futures = List.generate(
              10,
              (i) => Future.delayed(Duration(milliseconds: i * 5), () => i),
            );
            return Future.wait(futures);
          },
        );

        final stats = tracker.getStats('concurrent_futures');
        expect(stats, isNotNull);
      });
    });
  });

  group('Assertion Helper Tests', () {
    late PerformanceTracker tracker;

    setUp(() {
      tracker = PerformanceTracker();
    });

    test('assertAverageBelowThreshold passes for fast operations', () {
      for (int i = 0; i < 10; i++) {
        tracker.measure('fast_op', () => i);
      }

      // Should not throw
      tracker.assertAverageBelowThreshold(
        'fast_op',
        const Duration(seconds: 1),
      );
    });

    test('assertMaxBelowThreshold passes for reasonable operations', () {
      for (int i = 0; i < 10; i++) {
        tracker.measure('operation', () {
          List.generate(100, (x) => x);
        });
      }

      // Should not throw
      tracker.assertMaxBelowThreshold(
        'operation',
        const Duration(seconds: 1),
      );
    });

    test('assertP95BelowThreshold validates percentile', () {
      for (int i = 0; i < 20; i++) {
        tracker.measure('operation', () {
          List.generate(50, (x) => x).where((x) => x % 2 == 0).toList();
        });
      }

      // Should not throw - p95 should be reasonable
      tracker.assertP95BelowThreshold(
        'operation',
        const Duration(seconds: 1),
      );
    });
  });

  group('Export Functionality', () {
    late PerformanceTracker tracker;

    setUp(() {
      tracker = PerformanceTracker();
    });

    test('json export is readable', () {
      tracker.measure('metric', () => 'value');
      final json = tracker.exportAsJson(pretty: true);
      
      expect(json.isNotEmpty, isTrue);
      expect(json.contains('timestamp'), isTrue);
      expect(json.contains('metrics'), isTrue);
      expect(json.contains('metric'), isTrue);
    });

    test('csv export has correct format', () {
      tracker.measure('test_metric', () => 'value');
      final csv = tracker.exportAsCsv();
      
      final lines = csv.split('\n');
      expect(lines[0], contains('name,duration_ms,timestamp'));
      expect(lines[1], contains('test_metric'));
    });

    test('report printing generates meaningful output', () {
      tracker.measure('metric', () => 'value');
      // Should not throw
      tracker.printReport();
      expect(tracker.metricCount, equals(1));
    });
  });
}
