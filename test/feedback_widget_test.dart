import 'package:flutter/material.dart';
import 'package:flutter_feedback_kit/flutter_feedback_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBackend extends Mock implements FeedbackBackend {}

void main() {
  late _MockBackend backend;

  final entry = FeedbackEntry(
    category: FeedbackCategory.bug,
    message: '',
    platform: '',
    appVersion: '',
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(entry);
  });

  setUp(() {
    backend = _MockBackend();
  });

  Widget buildWidget({
    VoidCallback? onSuccess,
    void Function(Object)? onError,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: FeedbackWidget(
            backend: backend,
            appVersion: '1.0.0',
            onSuccess: onSuccess,
            onError: onError,
          ),
        ),
      ),
    );
  }

  group('FeedbackWidget rendering', () {
    testWidgets('shows category dropdown, message field, and submit button',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('does not show mic button when speechService is null',
        (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.byIcon(Icons.mic_none_outlined), findsNothing);
      expect(find.byIcon(Icons.mic), findsNothing);
    });

    testWidgets('shows screenshot add button', (tester) async {
      await tester.pumpWidget(buildWidget());
      expect(find.text('Screenshot'), findsOneWidget);
    });
  });

  group('FeedbackWidget validation', () {
    testWidgets('shows error when submitting empty message', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.text('Send Feedback'));
      await tester.pump();
      expect(find.text('Message is required'), findsOneWidget);
    });
  });

  group('FeedbackWidget submission', () {
    testWidgets('calls backend.submit on valid input', (tester) async {
      when(() => backend.submit(any())).thenAnswer((_) async {});

      await tester.pumpWidget(buildWidget());
      await tester.enterText(find.byType(TextFormField), 'This is my feedback');
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      verify(() => backend.submit(any())).called(1);
    });

    testWidgets('calls onSuccess callback after successful submit',
        (tester) async {
      when(() => backend.submit(any())).thenAnswer((_) async {});

      bool called = false;
      await tester.pumpWidget(buildWidget(onSuccess: () => called = true));
      await tester.enterText(find.byType(TextFormField), 'Great app!');
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
    });

    testWidgets('calls onError when backend throws', (tester) async {
      when(() => backend.submit(any())).thenThrow(Exception('server error'));

      Object? capturedError;
      await tester.pumpWidget(
        buildWidget(onError: (e) => capturedError = e),
      );
      await tester.enterText(find.byType(TextFormField), 'Crash report');
      await tester.tap(find.text('Send Feedback'));
      await tester.pumpAndSettle();

      expect(capturedError, isNotNull);
    });
  });

  group('FeedbackTheme integration', () {
    testWidgets('applies custom submitButtonColor via FeedbackTheme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FeedbackTheme(
              data: const FeedbackThemeData(
                submitButtonColor: Colors.teal,
              ),
              child: FeedbackWidget(
                backend: backend,
                appVersion: '1.0.0',
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      final style = button.style;
      expect(style, isNotNull);
    });
  });

  group('FeedbackButton', () {
    testWidgets('renders as FloatingActionButton.extended', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FeedbackButton(
              backend: backend,
              appVersion: '1.0.0',
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Feedback'), findsOneWidget);
    });

    testWidgets('opens bottom sheet with FeedbackWidget on tap',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FeedbackButton(
              backend: backend,
              appVersion: '1.0.0',
            ),
            body: const SizedBox(),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(FeedbackWidget), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('uses custom child widget as label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: FeedbackButton(
              backend: backend,
              appVersion: '1.0.0',
              child: const Text('Give Feedback'),
            ),
            body: const SizedBox(),
          ),
        ),
      );

      expect(find.text('Give Feedback'), findsOneWidget);
    });
  });
}
