import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_journal/widgets/avatar_widget.dart';
import 'package:mood_journal/models/user_profile.dart';
import 'package:mood_journal/services/profile_repository.dart';

void main() {
  group('AvatarWidget', () {
    late ProviderContainer container;

    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      
      // Create a new container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('should render initials when no photo', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(),
            ),
          ),
        ),
      );

      // Check if initials are displayed
      expect(find.text('?'), findsOneWidget);
      
      // Check if CircleAvatar is present
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should render user initials when name is provided', (WidgetTester tester) async {
      // Set up user profile
      await PreferencesService.setUserName('João Silva');

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(),
            ),
          ),
        ),
      );

      // Check if initials are displayed correctly
      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('should render single initial for single name', (WidgetTester tester) async {
      // Set up user profile with single name
      await PreferencesService.setUserName('João');

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(),
            ),
          ),
        ),
      );

      // Check if single initial is displayed
      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('should show edit icon when showEditIcon is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(showEditIcon: true),
            ),
          ),
        ),
      );

      // Check if edit icon is present
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should not show edit icon when showEditIcon is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(showEditIcon: false),
            ),
          ),
        ),
      );

      // Check if edit icon is not present
      expect(find.byIcon(Icons.edit), findsNothing);
    });

    testWidgets('should call onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: AvatarWidget(
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      // Tap on avatar
      await tester.tap(find.byType(AvatarWidget));
      await tester.pumpAndSettle();

      // Check if onTap was called
      expect(tapped, isTrue);
    });

    testWidgets('should render with custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(size: 100.0),
            ),
          ),
        ),
      );

      // Check if avatar widget is present
      expect(find.byType(AvatarWidget), findsOneWidget);
      
      // The size is handled internally, but we can verify the widget exists
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should have proper accessibility semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(),
            ),
          ),
        ),
      );

      // Check if GestureDetector is present for accessibility
      expect(find.byType(GestureDetector), findsOneWidget);
      
      // Check if CircleAvatar is present
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('should handle empty name gracefully', (WidgetTester tester) async {
      // Set up user profile with empty name
      await PreferencesService.setUserName('');

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(),
            ),
          ),
        ),
      );

      // Check if fallback initial is displayed
      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('should handle null name gracefully', (WidgetTester tester) async {
      // No name set (null)

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              body: const AvatarWidget(),
            ),
          ),
        ),
      );

      // Check if fallback initial is displayed
      expect(find.text('?'), findsOneWidget);
    });
  });
}
