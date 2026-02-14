import 'package:attendance_mobile/src/application/application.dart';
import 'package:attendance_mobile/src/data/data.dart';
import 'package:attendance_mobile/src/domain/models/models.dart';
import 'package:attendance_mobile/src/ui/attendance_flow_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAttendanceRepository extends Mock implements AttendanceRepository {}

void main() {
  group('AttendanceFlowPage', () {
    late MockAttendanceRepository repository;

    setUp(() {
      repository = MockAttendanceRepository();
    });

    testWidgets('renders idle state text', (tester) async {
      final controller = AttendanceController(
        config: const AttendanceConfig(
          requireQr: false,
          requireGeolocation: false,
          verificationMethod: VerificationMethod.none,
        ),
        userId: 'user-1',
        checkType: CheckType.checkIn,
        repository: repository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceFlowPage(controller: controller),
          ),
        ),
      );

      expect(find.text('Listo para marcar asistencia'), findsOneWidget);

      controller.dispose();
    });
  });
}
