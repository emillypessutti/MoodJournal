import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_journal/widgets/app_drawer.dart';
import 'package:mood_journal/models/user_profile.dart';
import 'package:mood_journal/services/profile_repository.dart';

void main() {
  group('AppDrawer', () {
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

    testWidgets('should render drawer with default profile', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              drawer: const AppDrawer(),
              body: Container(),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(
        const Offset(0, 300),
        const Offset(300, 300),
      );
      await tester.pumpAndSettle();

      // Check if drawer is visible
      expect(find.byType(Drawer), findsOneWidget);
      
      // Check if user name shows default
      expect(find.text('Usuário'), findsOneWidget);
      
      // Check if avatar widget is present
      expect(find.byType(AvatarWidget), findsOneWidget);
      
      // Check menu items
      expect(find.text('Editar Perfil'), findsOneWidget);
      expect(find.text('Histórico de Humor'), findsOneWidget);
      expect(find.text('Estatísticas'), findsOneWidget);
      expect(find.text('Configurações'), findsOneWidget);
      expect(find.text('Sobre'), findsOneWidget);
      expect(find.text('Política de Privacidade'), findsOneWidget);
    });

    testWidgets('should render drawer with user profile', (WidgetTester tester) async {
      // Set up user profile
      await PreferencesService.setUserName('João Silva');
      await PreferencesService.setUserEmail('joao@example.com');

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              drawer: const AppDrawer(),
              body: Container(),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(
        const Offset(0, 300),
        const Offset(300, 300),
      );
      await tester.pumpAndSettle();

      // Check if user name is displayed
      expect(find.text('João Silva'), findsOneWidget);
      expect(find.text('joao@example.com'), findsOneWidget);
    });

    testWidgets('should show photo options when avatar is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              drawer: const AppDrawer(),
              body: Container(),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(
        const Offset(0, 300),
        const Offset(300, 300),
      );
      await tester.pumpAndSettle();

      // Tap on avatar
      await tester.tap(find.byType(AvatarWidget));
      await tester.pumpAndSettle();

      // Check if bottom sheet is shown
      expect(find.text('Alterar foto do perfil'), findsOneWidget);
      expect(find.text('Tirar foto'), findsOneWidget);
      expect(find.text('Escolher da galeria'), findsOneWidget);
    });

    testWidgets('should show remove photo option when user has photo', (WidgetTester tester) async {
      // Set up user with photo
      await PreferencesService.setUserName('João Silva');
      await PreferencesService.setUserPhotoPath('/test/path.jpg');

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              drawer: const AppDrawer(),
              body: Container(),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(
        const Offset(0, 300),
        const Offset(300, 300),
      );
      await tester.pumpAndSettle();

      // Tap on avatar
      await tester.tap(find.byType(AvatarWidget));
      await tester.pumpAndSettle();

      // Check if remove photo option is shown
      expect(find.text('Remover foto'), findsOneWidget);
    });

    testWidgets('should navigate to profile edit when menu item is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              drawer: const AppDrawer(),
              body: Container(),
            ),
            routes: {
              '/profile-edit': (context) => const Scaffold(
                body: Text('Profile Edit Screen'),
              ),
            },
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(
        const Offset(0, 300),
        const Offset(300, 300),
      );
      await tester.pumpAndSettle();

      // Tap on edit profile
      await tester.tap(find.text('Editar Perfil'));
      await tester.pumpAndSettle();

      // Check if profile edit screen is shown
      expect(find.text('Profile Edit Screen'), findsOneWidget);
    });

    testWidgets('should have proper accessibility labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: Scaffold(
              drawer: const AppDrawer(),
              body: Container(),
            ),
          ),
        ),
      );

      // Open drawer
      await tester.dragFrom(
        const Offset(0, 300),
        const Offset(300, 300),
      );
      await tester.pumpAndSettle();

      // Check if menu items have proper semantics
      final editProfileTile = find.text('Editar Perfil');
      expect(editProfileTile, findsOneWidget);
      
      // Verify the tile is tappable
      expect(tester.getSemantics(editProfileTile), isNotNull);
    });
  });
}
