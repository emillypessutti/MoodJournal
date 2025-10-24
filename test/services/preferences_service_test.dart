import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_journal/services/preferences_service.dart';

void main() {
  group('PreferencesService', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and retrieve user name', () async {
      const testName = 'João Silva';
      
      await PreferencesService.setUserName(testName);
      final retrievedName = await PreferencesService.getUserName();
      
      expect(retrievedName, equals(testName));
    });

    test('should save and retrieve user email', () async {
      const testEmail = 'joao@example.com';
      
      await PreferencesService.setUserEmail(testEmail);
      final retrievedEmail = await PreferencesService.getUserEmail();
      
      expect(retrievedEmail, equals(testEmail));
    });

    test('should save and retrieve user photo path', () async {
      const testPath = '/path/to/photo.jpg';
      
      await PreferencesService.setUserPhotoPath(testPath);
      final retrievedPath = await PreferencesService.getUserPhotoPath();
      
      expect(retrievedPath, equals(testPath));
    });

    test('should clear user photo path when set to null', () async {
      const testPath = '/path/to/photo.jpg';
      
      // Set a path first
      await PreferencesService.setUserPhotoPath(testPath);
      expect(await PreferencesService.getUserPhotoPath(), equals(testPath));
      
      // Clear it
      await PreferencesService.setUserPhotoPath(null);
      expect(await PreferencesService.getUserPhotoPath(), isNull);
    });

    test('should save and retrieve photo updated timestamp', () async {
      const testTimestamp = 1234567890;
      
      await PreferencesService.setUserPhotoUpdatedAt(testTimestamp);
      final retrievedTimestamp = await PreferencesService.getUserPhotoUpdatedAt();
      
      expect(retrievedTimestamp, equals(testTimestamp));
    });

    test('should clear all user profile data', () async {
      // Set some data
      await PreferencesService.setUserName('Test User');
      await PreferencesService.setUserEmail('test@example.com');
      await PreferencesService.setUserPhotoPath('/test/path.jpg');
      await PreferencesService.setUserPhotoUpdatedAt(1234567890);
      
      // Clear all
      await PreferencesService.clearUserProfile();
      
      // Verify all are cleared
      expect(await PreferencesService.getUserName(), isNull);
      expect(await PreferencesService.getUserEmail(), isNull);
      expect(await PreferencesService.getUserPhotoPath(), isNull);
      expect(await PreferencesService.getUserPhotoUpdatedAt(), isNull);
    });

    test('should handle mood entries', () async {
      final testEntries = ['{"id":"1","mood":0}', '{"id":"2","mood":1}'];
      
      await PreferencesService.setMoodEntries(testEntries);
      final retrievedEntries = await PreferencesService.getMoodEntries();
      
      expect(retrievedEntries, equals(testEntries));
    });

    test('should handle daily goal setting', () async {
      await PreferencesService.setDailyGoal(true);
      expect(await PreferencesService.getDailyGoal(), isTrue);
      
      await PreferencesService.setDailyGoal(false);
      expect(await PreferencesService.getDailyGoal(), isFalse);
    });

    test('should handle first time flag', () async {
      expect(await PreferencesService.isFirstTime(), isTrue);
      
      await PreferencesService.setFirstTimeCompleted();
      expect(await PreferencesService.isFirstTime(), isFalse);
    });
  });
}
