import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers.dart';
import '../../../models/fleet_model.dart';
import '../../../utils/styles.dart';

final activeRidersProvider = StreamProvider<List<Rider>>((ref) {
  return ref.watch(fleetServiceProvider).getActiveRiders();
});

final fleetStatsProvider = StreamProvider<FleetStatus>((ref) {
  return ref.watch(fleetServiceProvider).getFleetStatus();
});

final shorebirdStatusProvider = FutureProvider<ShorebirdStatus>((ref) {
  return ref.watch(fleetServiceProvider).getShorebirdStatus();
});

class FleetTab extends ConsumerWidget {
  const FleetTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ridersAsync = ref.watch(activeRidersProvider);
    final statsAsync = ref.watch(fleetStatsProvider);
    final shorebirdAsync = ref.watch(shorebirdStatusProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(activeRidersProvider);
        ref.invalidate(fleetStatsProvider);
        ref.invalidate(shorebirdStatusProvider);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShorebirdCard(shorebirdAsync, isDark),
            const SizedBox(height: 20),
            _buildFleetStats(statsAsync, ridersAsync),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('LIVE RIDERS', style: AppStyles.titleStyle(null, isDark: isDark).copyWith(fontSize: 14, color: Colors.grey)),
                const Icon(Icons.map_rounded, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            _buildRidersList(ridersAsync, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildShorebirdCard(AsyncValue<ShorebirdStatus> status, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.system_update_rounded, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Shorebird Code Push', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                status.when(
                  data: (s) => Text('Version: v${s.currentVersion} • ${s.patchInstalled ? "Patch Active" : "No Patch"}', 
                    style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  loading: () => const Text('Checking...', style: TextStyle(fontSize: 12)),
                  error: (_, __) => const Text('Shorebird Offline', style: TextStyle(fontSize: 12, color: Colors.red)),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildFleetStats(AsyncValue<FleetStatus> stats, AsyncValue<List<Rider>> riders) {
    return Row(
      children: [
        Expanded(child: _statCard('Online', riders.value?.length ?? 0, Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Busy', riders.value?.where((r) => r.hasActiveOrder).length ?? 0, Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _statCard('Idle', (riders.value?.length ?? 0) - (riders.value?.where((r) => r.hasActiveOrder).length ?? 0), Colors.blue)),
      ],
    );
  }

  Widget _statCard(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }

  Widget _buildRidersList(AsyncValue<List<Rider>> riders, bool isDark) {
    return riders.when(
      data: (list) {
        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No active riders found.', style: TextStyle(color: Colors.grey)),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final rider = list[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppStyles.primaryColor.withValues(alpha: 0.1),
                  child: const Icon(Icons.person_rounded, color: AppStyles.primaryColor),
                ),
                title: Text(rider.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(rider.phone, style: const TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: rider.hasActiveOrder ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(rider.hasActiveOrder ? 'BUSY' : 'IDLE', 
                    style: TextStyle(color: rider.hasActiveOrder ? Colors.orange : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}

