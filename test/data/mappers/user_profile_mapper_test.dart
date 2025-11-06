import 'package:flutter_test/flutter_test.dart';
import 'package:mood_journal/data/dtos/user_profile_dto.dart';
import 'package:mood_journal/data/mappers/user_profile_mapper.dart';
import 'package:mood_journal/domain/entities/user_profile_entity.dart';

void main() {
  group('UserProfileMapper', () {
    test('toEntity converte DTO para Entity corretamente', () {
      // Arrange
      final dto = UserProfileDto(
        userId: 'user-123',
        userName: '  Maria Silva  ',
        userEmail: 'MARIA@EMAIL.COM',
        photoBase64: 'base64encodedphoto',
        createdTimestamp: 1699891200000,
        updatedTimestamp: 1699977600000,
      );

      // Act
      final entity = UserProfileMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'user-123');
      expect(entity.name, 'Maria Silva'); // Normalizado (sem espaços extras)
      expect(entity.email.value, 'maria@email.com'); // Normalizado (lowercase)
      expect(entity.photoUrl, 'base64encodedphoto');
      expect(entity.createdAt, DateTime.fromMillisecondsSinceEpoch(1699891200000));
      expect(entity.lastUpdated, DateTime.fromMillisecondsSinceEpoch(1699977600000));
      expect(entity.hasPhoto, true);
    });

    test('toEntity trata photo vazia como null', () {
      // Arrange
      final dto = UserProfileDto(
        userId: 'user-456',
        userName: 'João Santos',
        userEmail: 'joao@email.com',
        photoBase64: '',
        createdTimestamp: 1699891200000,
        updatedTimestamp: null,
      );

      // Act
      final entity = UserProfileMapper.toEntity(dto);

      // Assert
      expect(entity.photoUrl, null);
      expect(entity.hasPhoto, false);
      expect(entity.lastUpdated, null);
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = UserProfileEntity(
        id: 'user-789',
        name: 'Ana Costa',
        email: Email('ana@email.com'),
        photoUrl: 'photo123',
        createdAt: DateTime(2023, 11, 13, 10, 0),
        lastUpdated: DateTime(2023, 11, 14, 15, 30),
      );

      // Act
      final dto = UserProfileMapper.toDto(entity);

      // Assert
      expect(dto.userId, 'user-789');
      expect(dto.userName, 'Ana Costa');
      expect(dto.userEmail, 'ana@email.com');
      expect(dto.photoBase64, 'photo123');
      expect(dto.createdTimestamp, DateTime(2023, 11, 13, 10, 0).millisecondsSinceEpoch);
      expect(dto.updatedTimestamp, DateTime(2023, 11, 14, 15, 30).millisecondsSinceEpoch);
    });

    test('toEntity valida email inválido', () {
      // Arrange
      final dto = UserProfileDto(
        userId: 'user-invalid',
        userName: 'Teste',
        userEmail: 'email-invalido',
        photoBase64: null,
        createdTimestamp: 1699891200000,
        updatedTimestamp: null,
      );

      // Act & Assert
      expect(
        () => UserProfileMapper.toEntity(dto),
        throwsA(isA<AssertionError>()),
      );
    });

    test('conversão bidirecional (Entity -> DTO -> Entity) mantém dados', () {
      // Arrange
      final originalEntity = UserProfileEntity(
        id: 'user-bidirectional',
        name: 'Pedro Oliveira',
        email: Email('pedro@email.com'),
        photoUrl: 'photo456',
        createdAt: DateTime(2023, 11, 1),
        lastUpdated: DateTime(2023, 11, 13),
      );

      // Act
      final dto = UserProfileMapper.toDto(originalEntity);
      final convertedEntity = UserProfileMapper.toEntity(dto);

      // Assert
      expect(convertedEntity.id, originalEntity.id);
      expect(convertedEntity.name, originalEntity.name);
      expect(convertedEntity.email, originalEntity.email);
      expect(convertedEntity.photoUrl, originalEntity.photoUrl);
      expect(convertedEntity.createdAt, originalEntity.createdAt);
      expect(convertedEntity.lastUpdated, originalEntity.lastUpdated);
    });

    test('Entity calcula iniciais corretamente', () {
      // Arrange
      final dto = UserProfileDto(
        userId: 'user-initials',
        userName: 'Carlos Eduardo Santos',
        userEmail: 'carlos@email.com',
        photoBase64: null,
        createdTimestamp: 1699891200000,
        updatedTimestamp: null,
      );

      // Act
      final entity = UserProfileMapper.toEntity(dto);

      // Assert
      expect(entity.initials, 'CE');
    });

    test('toEntityList converte lista de DTOs', () {
      // Arrange
      final dtos = [
        UserProfileDto(
          userId: '1',
          userName: 'User 1',
          userEmail: 'user1@email.com',
          photoBase64: null,
          createdTimestamp: 1699891200000,
          updatedTimestamp: null,
        ),
        UserProfileDto(
          userId: '2',
          userName: 'User 2',
          userEmail: 'user2@email.com',
          photoBase64: 'photo',
          createdTimestamp: 1699977600000,
          updatedTimestamp: 1700064000000,
        ),
      ];

      // Act
      final entities = UserProfileMapper.toEntityList(dtos);

      // Assert
      expect(entities.length, 2);
      expect(entities[0].id, '1');
      expect(entities[1].id, '2');
      expect(entities[1].hasPhoto, true);
    });
  });
}
