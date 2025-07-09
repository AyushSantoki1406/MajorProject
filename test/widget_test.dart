import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_app/main.dart';

void main() {
  testWidgets('Login screen renders correctly', (WidgetTester tester) async {
await tester.pumpWidget(const QuizApp(showOnboarding: false));

    // Check for presence of Email and Password text fields and Login button
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
