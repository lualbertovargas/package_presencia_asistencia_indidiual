import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResultPage', () {
    testWidgets('renders success state', (tester) async {
      const state = AttendanceState(step: AttendanceStep.completed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultPage(
              state: state,
              onRetry: () {},
              successText: 'Asistencia registrada',
              errorText: 'Error',
              retryText: 'Reintentar',
            ),
          ),
        ),
      );

      expect(find.text('Asistencia registrada'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Reintentar'), findsNothing);
    });

    testWidgets('renders error state with retry button', (tester) async {
      const state = AttendanceState(
        step: AttendanceStep.error,
        errors: ['OUT_OF_RANGE'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultPage(
              state: state,
              onRetry: () {},
              successText: 'Asistencia registrada',
              errorText: 'Error',
              retryText: 'Reintentar',
            ),
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.text('OUT_OF_RANGE'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('calls onRetry when retry button is tapped', (tester) async {
      var retryCalled = false;
      const state = AttendanceState(
        step: AttendanceStep.error,
        errors: ['ERR'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultPage(
              state: state,
              onRetry: () => retryCalled = true,
              successText: 'Asistencia registrada',
              errorText: 'Error',
              retryText: 'Reintentar',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Reintentar'));
      expect(retryCalled, isTrue);
    });

    testWidgets('renders custom strings', (tester) async {
      const state = AttendanceState(step: AttendanceStep.completed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResultPage(
              state: state,
              onRetry: () {},
              successText: 'Attendance registered',
              errorText: 'Failure',
              retryText: 'Try again',
            ),
          ),
        ),
      );

      expect(find.text('Attendance registered'), findsOneWidget);
    });
  });
}
