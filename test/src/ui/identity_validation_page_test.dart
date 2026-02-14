import 'package:attendance_mobile/attendance_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IdentityValidationPage', () {
    testWidgets('renders progress indicator and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: IdentityValidationPage())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Verificando identidad...'), findsOneWidget);
    });
  });
}
