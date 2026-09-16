// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:feed_re/main.dart';

void main() {
  testWidgets('FeedRe app shows sign in and home flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: FeedReApp()));
    await tester.pumpAndSettle();

    expect(find.text('FeedRe'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
