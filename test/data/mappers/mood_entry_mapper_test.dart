import 'package:flutter_test/flutter_test.dart';
import 'package:mood_journal/data/dtos/mood_entry_dto.dart';
import 'package:mood_journal/data/mappers/mood_entry_mapper.dart';
import 'package:mood_journal/domain/entities/mood_entry_entity.dart';

void main() {
  group('MoodEntryMapper', () {
    test('toEntity converte DTO para Entity corretamente', () {
      // Arrange
      final dto = MoodEntryDto(
        id: 'entry-123',
        moodLevel: 5,
        timestamp: 1699891200000, // 2023-11-13 12:00:00
        notes: '  Dia incrível!  ',
        tagsList: ['feliz', 'trabalho'],
      );

      // Act
      final entity = MoodEntryMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'entry-123');
      expect(entity.level, MoodLevel.veryHappy);
      expect(entity.timestamp, DateTime.fromMillisecondsSinceEpoch(1699891200000));
      expect(entity.note, 'Dia incrível!'); // Normalizado (sem espaços)
      expect(entity.tags, ['feliz', 'trabalho']);
      expect(entity.intensity, 5);
    });

    test('toEntity normaliza tags null para lista vazia', () {
      // Arrange
      final dto = MoodEntryDto(
        id: 'entry-456',
        moodLevel: 3,
        timestamp: 1699891200000,
        notes: null,
        tagsList: null,
      );

      // Act
      final entity = MoodEntryMapper.toEntity(dto);

      // Assert
      expect(entity.tags, isEmpty);
      expect(entity.note, null);
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = MoodEntryEntity(
        id: 'entry-789',
        level: MoodLevel.happy,
        timestamp: DateTime(2023, 11, 13, 15, 30),
        note: 'Boa tarde!',
        tags: ['amigos', 'diversão'],
      );

      // Act
      final dto = MoodEntryMapper.toDto(entity);

      // Assert
      expect(dto.id, 'entry-789');
      expect(dto.moodLevel, 4);
      expect(dto.timestamp, DateTime(2023, 11, 13, 15, 30).millisecondsSinceEpoch);
      expect(dto.notes, 'Boa tarde!');
      expect(dto.tagsList, ['amigos', 'diversão']);
    });

    test('toDto converte lista vazia de tags para null', () {
      // Arrange
      final entity = MoodEntryEntity(
        id: 'entry-999',
        level: MoodLevel.neutral,
        timestamp: DateTime.now(),
        note: 'Sem tags',
        tags: [],
      );

      // Act
      final dto = MoodEntryMapper.toDto(entity);

      // Assert
      expect(dto.tagsList, null);
    });

    test('conversão bidirecional (Entity -> DTO -> Entity) mantém dados', () {
      // Arrange
      final originalEntity = MoodEntryEntity(
        id: 'entry-bidirectional',
        level: MoodLevel.sad,
        timestamp: DateTime(2023, 11, 13, 10, 0),
        note: 'Teste bidirecional',
        tags: ['teste'],
      );

      // Act
      final dto = MoodEntryMapper.toDto(originalEntity);
      final convertedEntity = MoodEntryMapper.toEntity(dto);

      // Assert
      expect(convertedEntity.id, originalEntity.id);
      expect(convertedEntity.level, originalEntity.level);
      expect(convertedEntity.timestamp, originalEntity.timestamp);
      expect(convertedEntity.note, originalEntity.note);
      expect(convertedEntity.tags, originalEntity.tags);
    });

    test('toEntityList converte lista de DTOs', () {
      // Arrange
      final dtos = [
        MoodEntryDto(
          id: '1',
          moodLevel: 5,
          timestamp: 1699891200000,
          notes: 'Nota 1',
          tagsList: null,
        ),
        MoodEntryDto(
          id: '2',
          moodLevel: 3,
          timestamp: 1699977600000,
          notes: 'Nota 2',
          tagsList: ['tag'],
        ),
      ];

      // Act
      final entities = MoodEntryMapper.toEntityList(dtos);

      // Assert
      expect(entities.length, 2);
      expect(entities[0].id, '1');
      expect(entities[1].id, '2');
    });
  });
}
