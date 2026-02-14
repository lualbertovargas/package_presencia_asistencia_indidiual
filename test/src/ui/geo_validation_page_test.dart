import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoValidationPage', () {
    testWidgets('renders progress indicator and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GeoValidationPage())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Validando ubicacion...'), findsOneWidget);
    });
  });
}
