import 'package:flutter_test/flutter_test.dart';
import 'package:mood_journal/data/dtos/mood_statistics_dto.dart';
import 'package:mood_journal/data/mappers/mood_statistics_mapper.dart';
import 'package:mood_journal/domain/entities/mood_statistics_entity.dart';

void main() {
  group('MoodStatisticsMapper', () {
    test('toEntity converte DTO para Entity corretamente', () {
      // Arrange
      final dto = MoodStatisticsDto(
        uid: 'user-123',
        periodType: 'week',
        avg: 4.2,
        count: 15,
        distribution: {
          'veryHappy': 5,
          'happy': 7,
          'neutral': 2,
          'sad': 1,
          'verySad': 0,
        },
        startTs: 1699891200000,
        endTs: 1700496000000,
      );

      // Act
      final entity = MoodStatisticsMapper.toEntity(dto);

      // Assert
      expect(entity.userId, 'user-123');
      expect(entity.period, Period.week);
      expect(entity.averageMood, 4.2);
      expect(entity.totalEntries, 15);
      expect(entity.moodDistribution['veryHappy'], 5);
      expect(entity.moodDistribution['happy'], 7);
      expect(entity.startDate, DateTime.fromMillisecondsSinceEpoch(1699891200000));
      expect(entity.endDate, DateTime.fromMillisecondsSinceEpoch(1700496000000));
      expect(entity.trend, 'positive'); // avg >= 4.0
      expect(entity.hasEnoughData, true); // count >= 3
    });

    test('toEntity normaliza distribuição corretamente', () {
      // Arrange - Backend pode retornar números como dynamic
      final dto = MoodStatisticsDto(
        uid: 'user-456',
        periodType: 'month',
        avg: 3.5,
        count: 30,
        distribution: {
          'happy': 12, // int
          'neutral': 15.0, // double convertido para int
          'sad': 3, // int
        },
        startTs: 1699891200000,
        endTs: 1700496000000,
      );

      // Act
      final entity = MoodStatisticsMapper.toEntity(dto);

      // Assert
      expect(entity.moodDistribution['happy'], 12);
      expect(entity.moodDistribution['neutral'], 15);
      expect(entity.moodDistribution['sad'], 3);
      expect(entity.moodDistribution, isA<Map<String, int>>());
    });

    test('toDto converte Entity para DTO corretamente', () {
      // Arrange
      final entity = MoodStatisticsEntity(
        userId: 'user-789',
        period: Period.quarter,
        averageMood: 3.8,
        totalEntries: 90,
        moodDistribution: {
          'veryHappy': 20,
          'happy': 35,
          'neutral': 25,
          'sad': 8,
          'verySad': 2,
        },
        startDate: DateTime(2023, 8, 1),
        endDate: DateTime(2023, 10, 31),
      );

      // Act
      final dto = MoodStatisticsMapper.toDto(entity);

      // Assert
      expect(dto.uid, 'user-789');
      expect(dto.periodType, 'quarter');
      expect(dto.avg, 3.8);
      expect(dto.count, 90);
      expect(dto.distribution['veryHappy'], 20);
      expect(dto.distribution['happy'], 35);
      expect(dto.startTs, DateTime(2023, 8, 1).millisecondsSinceEpoch);
      expect(dto.endTs, DateTime(2023, 10, 31).millisecondsSinceEpoch);
    });

    test('Entity calcula humor predominante corretamente', () {
      // Arrange
      final dto = MoodStatisticsDto(
        uid: 'user-dominant',
        periodType: 'week',
        avg: 4.0,
        count: 20,
        distribution: {
          'veryHappy': 3,
          'happy': 12, // Predominante
          'neutral': 4,
          'sad': 1,
        },
        startTs: 1699891200000,
        endTs: 1700496000000,
      );

      // Act
      final entity = MoodStatisticsMapper.toEntity(dto);

      // Assert
      expect(entity.dominantMood, 'happy');
    });

    test('Entity calcula métricas de período corretamente', () {
      // Arrange - 7 dias com 14 registros
      final dto = MoodStatisticsDto(
        uid: 'user-metrics',
        periodType: 'week',
        avg: 3.5,
        count: 14,
        distribution: {'happy': 14},
        startTs: DateTime(2023, 11, 1).millisecondsSinceEpoch,
        endTs: DateTime(2023, 11, 7).millisecondsSinceEpoch,
      );

      // Act
      final entity = MoodStatisticsMapper.toEntity(dto);

      // Assert
      expect(entity.periodInDays, 6); // 7 - 1 = 6 dias completos
      expect(entity.averageEntriesPerDay, closeTo(2.33, 0.01)); // 14/6
    });

    test('conversão bidirecional (Entity -> DTO -> Entity) mantém dados', () {
      // Arrange
      final originalEntity = MoodStatisticsEntity(
        userId: 'user-bidirectional',
        period: Period.month,
        averageMood: 4.5,
        totalEntries: 60,
        moodDistribution: {
          'veryHappy': 25,
          'happy': 30,
          'neutral': 5,
        },
        startDate: DateTime(2023, 11, 1),
        endDate: DateTime(2023, 11, 30),
      );

      // Act
      final dto = MoodStatisticsMapper.toDto(originalEntity);
      final convertedEntity = MoodStatisticsMapper.toEntity(dto);

      // Assert
      expect(convertedEntity.userId, originalEntity.userId);
      expect(convertedEntity.period, originalEntity.period);
      expect(convertedEntity.averageMood, originalEntity.averageMood);
      expect(convertedEntity.totalEntries, originalEntity.totalEntries);
      expect(convertedEntity.moodDistribution, originalEntity.moodDistribution);
      expect(convertedEntity.startDate, originalEntity.startDate);
      expect(convertedEntity.endDate, originalEntity.endDate);
    });

    test('Entity valida invariante de média de humor', () {
      // Arrange & Act & Assert - Média deve estar entre 1.0 e 5.0
      expect(
        () => MoodStatisticsEntity(
          userId: 'user-invalid',
          period: Period.week,
          averageMood: 6.0, // Inválido
          totalEntries: 10,
          moodDistribution: {},
          startDate: DateTime.now(),
          endDate: DateTime.now(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('toEntityList converte lista de DTOs', () {
      // Arrange
      final dtos = [
        MoodStatisticsDto(
          uid: 'user-1',
          periodType: 'week',
          avg: 4.0,
          count: 10,
          distribution: {'happy': 10},
          startTs: 1699891200000,
          endTs: 1700496000000,
        ),
        MoodStatisticsDto(
          uid: 'user-1',
          periodType: 'month',
          avg: 3.5,
          count: 40,
          distribution: {'neutral': 40},
          startTs: 1699891200000,
          endTs: 1702569600000,
        ),
      ];

      // Act
      final entities = MoodStatisticsMapper.toEntityList(dtos);

      // Assert
      expect(entities.length, 2);
      expect(entities[0].period, Period.week);
      expect(entities[1].period, Period.month);
      expect(entities[0].trend, 'positive');
      expect(entities[1].trend, 'stable');
    });
  });
}
