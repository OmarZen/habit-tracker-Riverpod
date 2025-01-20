import 'package:habit_tracker/data/database/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'database_provider.dart';

final habitForDateProvider =
    StreamProvider.family<List<HabitWithCompletion>, DateTime>((ref, date) {
  final database = ref.watch(databaseProvider);
  return database.watchHabitsForDate(date);
});
