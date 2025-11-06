import 'package:flutter_test/flutter_test.dart';
import 'package:mood_journal/data/dtos/daily_goal_dto.dart';
import 'package:mood_journal/data/mappers/daily_goal_mapper.dart';
import 'package:mood_journal/domain/entities/daily_goal_entity.dart';

void main() {
  group('DailyGoalMapper', () {
    test('toEntity converte DTO para Entity corretamente', () {
      // Arrange
      final dto = DailyGoalDto(
        goalId: 'goal-123',
        uid: 'user-456',
        goalType: 'moodEntries',
        target: 3,
        current: 2,
        dateIso: '2023-11-13',
        completed: false,
      );

      // Act
      final entity = DailyGoalMapper.toEntity(dto);

      // Assert
      expect(entity.id, 'goal-123');
      expect(entity.userId, 'user-456');
      expect(entity.type, GoalType.moodEntries);
      expect(entity.targetValue, 3);
      expect(entity.currentValue, 2);
      expect(entity.date, DateTime(2023, 11, 13));
      expect(entity.isCompleted, false);
      expect(entity.progressPercentage, 66); // 2/3 = 66%
      expect(entity.remaining, 1);
    });

    test('toEntity calcula progresso corretamente', () {
      // Arrange
      final dto = DailyGoalDto(
        goalId: 'goal-789',
        uid: 'user-123',
        goalType: 'positiveEntries',
        target: 5,
        current: 5,
        dateIso: '2023-11-13',
        completed: true,
      );

      // Act
      final entity = DailyGoalMapper.toEntity(dto);

      // Assert
      expect(entity.isAchieved, true);
      expect(entity.progressPercentage, 100);
      expect(entity.remaining, 0);
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = DailyGoalEntity(
        id: 'goal-999',
        userId: 'user-789',
        type: GoalType.gratitude,
        targetValue: 10,
        currentValue: 7,
        date: DateTime(2023, 11, 14),
        isCompleted: false,
      );

      // Act
      final dto = DailyGoalMapper.toDto(entity);

      // Assert
      expect(dto.goalId, 'goal-999');
      expect(dto.uid, 'user-789');
      expect(dto.goalType, 'gratitude');
      expect(dto.target, 10);
      expect(dto.current, 7);
      expect(dto.dateIso, '2023-11-14');
      expect(dto.completed, false);
    });

    test('toDto formata data corretamente para ISO 8601', () {
      // Arrange
      final entity = DailyGoalEntity(
        id: 'goal-date',
        userId: 'user-123',
        type: GoalType.reflection,
        targetValue: 1,
        currentValue: 0,
        date: DateTime(2023, 1, 5), // Testa padding com zeros
        isCompleted: false,
      );

      // Act
      final dto = DailyGoalMapper.toDto(entity);

      // Assert
      expect(dto.dateIso, '2023-01-05');
    });

    test('conversão bidirecional (Entity -> DTO -> Entity) mantém dados', () {
      // Arrange
      final originalEntity = DailyGoalEntity(
        id: 'goal-bidirectional',
        userId: 'user-456',
        type: GoalType.moodEntries,
        targetValue: 4,
        currentValue: 3,
        date: DateTime(2023, 11, 13),
        isCompleted: false,
      );

      // Act
      final dto = DailyGoalMapper.toDto(originalEntity);
      final convertedEntity = DailyGoalMapper.toEntity(dto);

      // Assert
      expect(convertedEntity.id, originalEntity.id);
      expect(convertedEntity.userId, originalEntity.userId);
      expect(convertedEntity.type, originalEntity.type);
      expect(convertedEntity.targetValue, originalEntity.targetValue);
      expect(convertedEntity.currentValue, originalEntity.currentValue);
      expect(convertedEntity.date, originalEntity.date);
      expect(convertedEntity.isCompleted, originalEntity.isCompleted);
    });

    test('Entity valida invariantes de domínio', () {
      // Arrange & Act & Assert - targetValue deve ser positivo
      expect(
        () => DailyGoalEntity(
          id: 'invalid-goal',
          userId: 'user-123',
          type: GoalType.moodEntries,
          targetValue: 0, // Inválido
          currentValue: 0,
          date: DateTime.now(),
          isCompleted: false,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('toEntityList converte lista de DTOs', () {
      // Arrange
      final dtos = [
        DailyGoalDto(
          goalId: '1',
          uid: 'user-1',
          goalType: 'moodEntries',
          target: 3,
          current: 1,
          dateIso: '2023-11-13',
          completed: false,
        ),
        DailyGoalDto(
          goalId: '2',
          uid: 'user-1',
          goalType: 'gratitude',
          target: 5,
          current: 5,
          dateIso: '2023-11-13',
          completed: true,
        ),
      ];

      // Act
      final entities = DailyGoalMapper.toEntityList(dtos);

      // Assert
      expect(entities.length, 2);
      expect(entities[0].id, '1');
      expect(entities[0].isAchieved, false);
      expect(entities[1].id, '2');
      expect(entities[1].isAchieved, true);
    });
  });
}
