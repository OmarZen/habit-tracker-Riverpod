import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers/habits_for_date_provider.dart';
import 'habit_card.dart';

class HabitCardList extends HookConsumerWidget {
  const HabitCardList({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsyncValue = ref.watch(habitForDateProvider(selectedDate));
    return habitsAsyncValue.when(
      data: (habits) {
        return Expanded(
          child: ListView.separated(
            itemCount: habits.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final habitWithCompletion = habits[index];
              return HabitCard(
                title: habitWithCompletion.habit.title,
                streak: habitWithCompletion.habit.streak,
                progress: habitWithCompletion.isCompleted ? 1 : 0,
                habitId: habitWithCompletion.habit.id,
                isCompleted: habitWithCompletion.isCompleted,
                date: selectedDate,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Text("Error: error happened"),
    );
  }
}
