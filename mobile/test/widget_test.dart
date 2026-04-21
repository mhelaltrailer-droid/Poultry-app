import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daytoday_app/app.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(
      const DayTodayApp(initialLocale: Locale('en')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
