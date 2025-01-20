import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:habit_tracker/data/database/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Habits, HabitCompletions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Habit>> getHabits() => select(habits).get();
  Stream<List<Habit>> watchHabits() => select(habits).watch();

  Future<int> createHabit(HabitsCompanion habit) => into(habits).insert(habit);

  Stream<List<HabitWithCompletion>> watchHabitsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final query = select(habits).join([
      leftOuterJoin(
        habitCompletions,
        habitCompletions.habitId.equalsExp(habits.id) &
            habitCompletions.completedAt.isBetweenValues(startOfDay, endOfDay),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final habit = row.readTable(habits);
        final completion = row.readTableOrNull(habitCompletions);
        return HabitWithCompletion(
            habit: habit, isCompleted: completion != null);
      }).toList();
    });
  }

  // Future<void> completeHabit(int habitId, DateTime selectedDate) {
  //   return transaction(() async {
  //     final startOfDay =
  //         DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  //     final endOfDay =
  //         DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1);
  //
  //     final existingCompletion = await (select(habitCompletions)
  //           ..where(
  //             (t) =>
  //                 t.habitId.equals(habitId) &
  //                 t.completedAt.isBetween(
  //                   Variable(startOfDay),
  //                   Variable(endOfDay),
  //                 ),
  //           ))
  //         .get();
  //
  //     if (existingCompletion.isEmpty) {
  //       await into(habitCompletions).insert(
  //         HabitCompletionsCompanion.insert(
  //           habitId: habitId,
  //           completedAt: selectedDate,
  //         ),
  //       );
  //
  //       final habit = await (select(habits)..where((t) => t.id.equals(habitId)))
  //           .getSingle();
  //       await update(habits).replace(habit
  //           .copyWith(
  //             streak: habit.streak + 1,
  //             totalCompletions: habit.totalCompletions + 1,
  //           )
  //           .toCompanion(true));
  //     }
  //   });
  // }

  // Toggle the completion of a habit for a given date
  Future<void> toggleHabitCompletion(int habitId, DateTime selectedDate) {
    return transaction(() async {
      final startOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
      final endOfDay =
          DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1);

      final existingCompletion = await (select(habitCompletions)
            ..where(
              (t) =>
                  t.habitId.equals(habitId) &
                  t.completedAt.isBetween(
                    Variable(startOfDay),
                    Variable(endOfDay),
                  ),
            ))
          .get();

      if (existingCompletion.isEmpty) {
        await into(habitCompletions).insert(
          HabitCompletionsCompanion.insert(
            habitId: habitId,
            completedAt: selectedDate,
          ),
        );

        final habit = await (select(habits)..where((t) => t.id.equals(habitId)))
            .getSingle();
        await update(habits).replace(habit
            .copyWith(
              streak: habit.streak + 1,
              totalCompletions: habit.totalCompletions + 1,
            )
            .toCompanion(true));
      } else {
        await (delete(habitCompletions)
              ..where((t) =>
                  t.habitId.equals(habitId) &
                  t.completedAt.isBetween(
                    Variable(startOfDay),
                    Variable(endOfDay),
                  )))
            .go();

        final habit = await (select(habits)..where((t) => t.id.equals(habitId)))
            .getSingle();
        await update(habits).replace(habit
            .copyWith(
              streak: habit.streak - 1,
              totalCompletions: habit.totalCompletions - 1,
            )
            .toCompanion(true));
      }
    });
  }

  Stream<(int, int)> watchDailySummary(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final completionsStream = (select(habitCompletions)
          ..where((t) => t.completedAt.isBetween(
                Variable(startOfDay),
                Variable(endOfDay),
              )))
        .watch();

    final habitStream = watchHabitsForDate(date);
    return Rx.combineLatest2(completionsStream, habitStream,
        (completions, habits) => (completions.length, habits.length));
  }
}

class HabitWithCompletion {
  final Habit habit;
  final bool isCompleted;

  HabitWithCompletion({required this.habit, required this.isCompleted});
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'habits.db'));
    return NativeDatabase.createInBackground(file);
  });
}
