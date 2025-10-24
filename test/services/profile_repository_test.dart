import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_journal/services/preferences_service.dart';
import 'package:mood_journal/services/profile_repository.dart';

void main() {
  group('ProfileRepository', () {
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

    test('should initialize with empty profile', () {
      final profile = container.read(profileRepositoryProvider);
      
      expect(profile.name, isNull);
      expect(profile.email, isNull);
      expect(profile.photoPath, isNull);
      expect(profile.photoUpdatedAt, isNull);
      expect(profile.initials, equals('?'));
      expect(profile.hasPhoto, isFalse);
      expect(profile.isComplete, isFalse);
    });

    test('should update name correctly', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      const testName = 'João Silva';
      
      await repository.updateName(testName);
      
      final profile = container.read(profileRepositoryProvider);
      expect(profile.name, equals(testName));
      expect(profile.initials, equals('JS'));
      expect(profile.isComplete, isTrue);
    });

    test('should update email correctly', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      const testEmail = 'joao@example.com';
      
      await repository.updateEmail(testEmail);
      
      final profile = container.read(profileRepositoryProvider);
      expect(profile.email, equals(testEmail));
    });

    test('should update profile with multiple fields', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      const testName = 'Maria Santos';
      const testEmail = 'maria@example.com';
      
      await repository.updateProfile(
        name: testName,
        email: testEmail,
      );
      
      final profile = container.read(profileRepositoryProvider);
      expect(profile.name, equals(testName));
      expect(profile.email, equals(testEmail));
      expect(profile.initials, equals('MS'));
      expect(profile.isComplete, isTrue);
    });

    test('should clear profile correctly', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      
      // Set some data first
      await repository.updateProfile(
        name: 'Test User',
        email: 'test@example.com',
      );
      
      // Verify data is set
      var profile = container.read(profileRepositoryProvider);
      expect(profile.name, equals('Test User'));
      expect(profile.email, equals('test@example.com'));
      
      // Clear profile
      await repository.clearProfile();
      
      // Verify data is cleared
      profile = container.read(profileRepositoryProvider);
      expect(profile.name, isNull);
      expect(profile.email, isNull);
      expect(profile.photoPath, isNull);
      expect(profile.initials, equals('?'));
      expect(profile.isComplete, isFalse);
    });

    test('should refresh profile from storage', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      
      // Set data directly in preferences
      await PreferencesService.setUserName('Direct Name');
      await PreferencesService.setUserEmail('direct@example.com');
      
      // Refresh repository
      await repository.refresh();
      
      // Verify data is loaded
      final profile = container.read(profileRepositoryProvider);
      expect(profile.name, equals('Direct Name'));
      expect(profile.email, equals('direct@example.com'));
    });

    test('should handle single name initials correctly', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      
      await repository.updateName('João');
      
      final profile = container.read(profileRepositoryProvider);
      expect(profile.initials, equals('J'));
    });

    test('should handle multiple names initials correctly', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      
      await repository.updateName('João Silva Santos');
      
      final profile = container.read(profileRepositoryProvider);
      expect(profile.initials, equals('JS')); // First two words
    });

    test('should handle empty name initials correctly', () async {
      final repository = container.read(profileRepositoryProvider.notifier);
      
      await repository.updateName('');
      
      final profile = container.read(profileRepositoryProvider);
      expect(profile.initials, equals('?'));
      expect(profile.isComplete, isFalse);
    });
  });
}
