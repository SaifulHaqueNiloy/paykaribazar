import 'dart:async';
import 'package:flutter/material.dart';
import '../../../utils/styles.dart';

class FlashSaleTimer extends StatefulWidget {
  final DateTime endTime;
  const FlashSaleTimer({super.key, required this.endTime});

  @override
  State<FlashSaleTimer> createState() => _FlashSaleTimerState();
}

class _FlashSaleTimerState extends State<FlashSaleTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    setState(() {
      _timeLeft = widget.endTime.difference(now);
      if (_timeLeft.isNegative) _timeLeft = Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDigit(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isZero) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Colors.red, size: 24),
          const SizedBox(width: 8),
          const Text(
            'Flash Sale Ends In:',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.red),
          ),
          const Spacer(),
          _timeBox(_formatDigit(_timeLeft.inHours)),
          _separator(),
          _timeBox(_formatDigit(_timeLeft.inMinutes.remainder(60))),
          _separator(),
          _timeBox(_formatDigit(_timeLeft.inSeconds.remainder(60))),
        ],
      ),
    );
  }

  Widget _timeBox(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        value,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _separator() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 4),
    child: Text(':', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
  );
}

