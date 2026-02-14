import 'package:attendance_mobile/attendance_mobile.dart';
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

    AttendanceController createController() {
      return AttendanceController(
        config: const AttendanceConfig(
          requireQr: false,
          requireGeolocation: false,
          verificationMethod: VerificationMethod.none,
        ),
        userId: 'user-1',
        checkType: CheckType.checkIn,
        repository: repository,
      );
    }

    Widget buildPage(AttendanceController controller) {
      return MaterialApp(
        home: Scaffold(
          body: AttendanceFlowPage(controller: controller),
        ),
      );
    }

    testWidgets('renders idle state text', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      expect(find.text('Listo para marcar asistencia'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders QrScanPage on scanningQr', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.scanningQr,
      );
      await tester.pump();

      expect(find.text('Escaneando codigo QR...'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders QrScanPage on validatingQr', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.validatingQr,
      );
      await tester.pump();

      expect(find.text('Escaneando codigo QR...'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders GeoValidationPage on locating', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.locating,
      );
      await tester.pump();

      expect(find.text('Validando ubicacion...'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders GeoValidationPage on validatingLocation', (
      tester,
    ) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.validatingLocation,
      );
      await tester.pump();

      expect(find.text('Validando ubicacion...'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders IdentityValidationPage on verifyingIdentity', (
      tester,
    ) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.verifyingIdentity,
      );
      await tester.pump();

      expect(find.text('Verificando identidad...'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders progress indicator on submitting', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.submitting,
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders success ResultPage on completed', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.completed,
      );
      await tester.pump();

      expect(find.text('Asistencia registrada'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders error ResultPage on error', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.error,
        errors: ['OUT_OF_RANGE'],
      );
      await tester.pump();

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('OUT_OF_RANGE'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('renders cancelled state text', (tester) async {
      final controller = createController();
      await tester.pumpWidget(buildPage(controller));

      controller.value = const AttendanceState(
        step: AttendanceStep.cancelled,
      );
      await tester.pump();

      expect(find.text('Operacion cancelada'), findsOneWidget);
      controller.dispose();
    });

    testWidgets('uses custom strings', (tester) async {
      final controller = createController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AttendanceFlowPage(
              controller: controller,
              strings: const AttendanceStrings(
                readyToMark: 'Ready',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Ready'), findsOneWidget);
      controller.dispose();
    });
  });
}
