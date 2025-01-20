import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:habit_tracker/ui/components/habit_card_list.dart';
import 'package:habit_tracker/ui/pages/create_habit_page.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/providers/daily_summry_provider.dart';
import '../providers/theme_provider.dart';
import 'components/daily_summary_card.dart';
import 'components/time_line_view.dart';

class MainPage extends HookConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = useState(DateTime.now());
    final colorScheme = Theme.of(context).colorScheme;

    final themeProviderNotifier = ref.read(themeProvider.notifier);
    final themeProviderState = ref.watch(themeProvider);

    List<int> habitCompletion = [
      1,
      1,
      1,
      0,
      1,
      0,
      1
    ]; // Example data for habit completion (1: completed, 0: not completed)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              child: Center(
                child: Text(
                  'Settings',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inverseSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Theme Mode'),
              trailing: Switch(
                value: themeProviderState == ThemeMode.dark,
                onChanged: (value) {
                  themeProviderNotifier.toggleThemeMode();
                },
              ),
            ),
            ListTile(
              title: const Text('Themes'),
              subtitle: DropdownButton<int>(
                value: themeProviderNotifier.currentThemeIndex,
                onChanged: (value) {
                  themeProviderNotifier.setCurrentTheme(value!);
                },
                items: List.generate(
                  themeProviderNotifier.currentThemeNames.length,
                  (index) => DropdownMenuItem(
                    value: index,
                    child: Text(themeProviderNotifier.currentThemeNames[index]),
                  ),
                ),
              ),
            ),
            // see the some statistics about nuber of the tasks and streaks and have a colored fire icon to show how he is doing for this week

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: ListTile(
                  title: const Text('Statistics'),
                  trailing: Icon(
                    Icons.emoji_events,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Statistics Line Chart
            AspectRatio(
              aspectRatio: 1.70,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: 1,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.black),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        7,
                        (index) => FlSpot(index.toDouble(),
                            habitCompletion[index].toDouble()),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 5,
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
            // end of the statistics line chart
            // get the from the dailySummaryProvider the number of the tasks and the number of the completed tasks and show them in the card
            ref.watch(dailySummaryProvider(selectedDate.value)).when(
                  data: (data) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHigh,
                            child: ListTile(
                              title: Text(
                                'Daily Summary',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                ),
                              ),
                              trailing: Icon(
                                Icons.emoji_events,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                'Completed Tasks: ${data.$1}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            spacing: 8,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                'Total Tasks: ${data.$2}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, _) => Text("Error:"),
                ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TimeLineView(
                selectedDate: selectedDate.value,
                onSelectedDateChanged: (date) => selectedDate.value = date,
              ),
              const SizedBox(height: 16),
              ref.watch(dailySummaryProvider(selectedDate.value)).when(
                    data: (data) {
                      return DailySummaryCard(
                        completedTasks: data.$1,
                        totalTasks: data.$2,
                        date: DateFormat('dd-MMM-yyyy')
                            .format(selectedDate.value),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (error, _) => Text("Error:"),
                  ),
              const SizedBox(height: 16),
              Text(
                "Habits",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              HabitCardList(
                selectedDate: selectedDate.value,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
              onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CreateHabitPage(),
                    ),
                  ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Text(
                  "Create Habit",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )),
        ),
      ),
    );
  }
}
