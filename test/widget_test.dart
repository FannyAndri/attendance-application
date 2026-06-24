import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Splash screen renders app branding', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Employee Attendance'), findsOneWidget);
    expect(find.text('Location-based attendance system'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Splash schedules a 2s delay; drain it without pumpAndSettle (progress indicator never settles).
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    await tester.pump();
  });
}
