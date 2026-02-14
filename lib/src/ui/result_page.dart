import 'package:attendance_mobile/src/application/attendance_state.dart';
import 'package:flutter/material.dart';

/// Page displayed when the flow completes (success or error).
class ResultPage extends StatelessWidget {
  /// Creates a [ResultPage].
  const ResultPage({
    required this.state,
    required this.onRetry,
    super.key,
  });

  /// The current attendance state.
  final AttendanceState state;

  /// Callback invoked when the user taps retry.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isSuccess = state.step == AttendanceStep.completed;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            size: 64,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            isSuccess ? 'Asistencia registrada' : 'Error',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (!isSuccess && state.errors.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(state.errors.join(', ')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }
}
