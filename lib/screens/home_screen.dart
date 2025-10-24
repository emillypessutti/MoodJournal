import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/mood_entry.dart';
import '../services/mood_storage.dart';
import '../widgets/mood_selector.dart';
import '../widgets/mood_card.dart';
import '../widgets/daily_goal_card.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<MoodEntry> _moodEntries = [];
  bool _isLoading = true;
  bool _hasEntryToday = false;

  @override
  void initState() {
    super.initState();
    _loadMoodEntries();
  }

  Future<void> _loadMoodEntries() async {
    setState(() {
      _isLoading = true;
    });

    final entries = await MoodStorage.getMoodEntries();
    final hasEntryToday = await MoodStorage.hasEntryToday();

    setState(() {
      _moodEntries = entries;
      _hasEntryToday = hasEntryToday;
      _isLoading = false;
    });
  }

  Future<void> _onMoodSelected(MoodType mood) async {
    final now = DateTime.now();
    final entry = MoodEntry(
      id: '${now.millisecondsSinceEpoch}',
      mood: mood,
      timestamp: now,
    );

    await MoodStorage.saveMoodEntry(entry);
    await _loadMoodEntries();
  }

  Future<void> _onMoodDeleted(String id) async {
    await MoodStorage.deleteMoodEntry(id);
    await _loadMoodEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('MoodJournal'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Como você está se sentindo hoje?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  MoodSelector(
                    onMoodSelected: _onMoodSelected,
                    hasEntryToday: _hasEntryToday,
                  ),
                  const SizedBox(height: 24),
                  const DailyGoalCard(),
                  const SizedBox(height: 24),
                  if (_moodEntries.isNotEmpty) ...[
                    const Text(
                      'Entradas recentes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._moodEntries.take(3).map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MoodCard(
                          entry: entry,
                          onDelete: () => _onMoodDeleted(entry.id),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

