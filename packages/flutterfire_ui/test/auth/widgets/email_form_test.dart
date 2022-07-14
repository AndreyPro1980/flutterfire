import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutterfire_ui/auth.dart';

import '../../test_utils.dart';

void main() {
  group('EmailForm', () {
    late Widget widget;

    setUp(() {
      widget = TestMaterialApp(
        child: EmailForm(
          auth: MockAuth(),
          action: AuthAction.signIn,
        ),
      );
    });

    testWidgets('has a Sign in button of outlined variant', (tester) async {
      await tester.pumpWidget(widget);
      final button = find.byType(OutlinedButton);

      expect(button, findsOneWidget);
    });

    testWidgets('has a Forgot password button of text variant', (tester) async {
      await tester.pumpWidget(widget);
      final button = find.byType(TextButton);

      expect(
        button,
        findsOneWidget,
      );
    });

    testWidgets('respects the EmailFormStyle', (tester) async {
      await tester.pumpWidget(
        FlutterFireUITheme(
          styles: const {
            EmailFormStyle(signInButtonVariant: ButtonVariant.filled)
          },
          child: widget,
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });
  });
}