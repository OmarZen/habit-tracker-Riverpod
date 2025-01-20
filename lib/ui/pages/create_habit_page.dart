import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:habit_tracker/data/database/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/providers/database_provider.dart';

class CreateHabitPage extends HookConsumerWidget {
  const CreateHabitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final titleController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final isDaily = useState(false);
    final hasReminder = useState(false);
    final reminderTime =
        useState<TimeOfDay?>(const TimeOfDay(hour: 10, minute: 0));
    final selectedColor = useState<Color>(colorScheme.primary);

    Future<void> onPressed() async {
      final title = titleController.text;
      final description = descriptionController.text;

      if (title.isEmpty) {
        return;
      }

      final habit = HabitsCompanion.insert(
        title: title,
        description: Value(description),
        isDaily: Value(isDaily.value),
        createdAt: Value(DateTime.now()),
        reminderTime: Value(reminderTime.value?.format(context)),
      );

      await ref.read(databaseProvider).createHabit(habit);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Habit Title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hoverColor: colorScheme.primary,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                floatingLabelStyle: TextStyle(
                  color: colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => titleController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Habit Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hoverColor: colorScheme.primary,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                floatingLabelStyle: TextStyle(
                  color: colorScheme.primary,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => descriptionController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Goal",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              spacing: 16,
              children: [
                Text('Daily'),
                Switch(
                  value: isDaily.value,
                  onChanged: (value) => isDaily.value = value,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Reminder",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Has Reminder'),
              subtitle: hasReminder.value
                  ? Text(
                      'Reminder at ${reminderTime.value?.format(context) ?? 'No time selected'}')
                  : null,
              value: hasReminder.value,
              onChanged: (value) {
                hasReminder.value = value;
                if (value) {
                  showTimePicker(
                          context: context,
                          initialTime: reminderTime.value ??
                              const TimeOfDay(hour: 10, minute: 0))
                      .then((time) {
                    if (time != null) {
                      reminderTime.value = time;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            if (hasReminder.value) ...[
              Text(
                'Reminder Time: ${reminderTime.value?.format(context) ?? 'No time selected'}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 16),
            Text(
              "Color",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final color in Colors.primaries)
                  GestureDetector(
                    onTap: () {
                      selectedColor.value = color;
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor.value == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Create Habit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
