import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';

class TimeLineView extends StatelessWidget {
  const TimeLineView({
    super.key,
    required this.selectedDate,
    required this.onSelectedDateChanged,
  });

  final DateTime selectedDate;
  final void Function(DateTime) onSelectedDateChanged;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: EasyDateTimeLine(
        initialDate: selectedDate,
        onDateChange: onSelectedDateChanged,
        headerProps: EasyHeaderProps(
          monthPickerType: MonthPickerType.dropDown,
          showHeader: true,
          showSelectedDate: true,
          monthStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          selectedDateStyle: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        dayProps: EasyDayProps(
          dayStructure: DayStructure.dayStrDayNumMonth,
          activeDayStyle: DayStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.secondary,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dayStrStyle: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            dayNumStyle: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          inactiveDayStyle: DayStyle(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: colorScheme.surface,
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 1.0,
              ),
            ),
            dayStrStyle: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            dayNumStyle: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          todayHighlightStyle: TodayHighlightStyle.withBackground,
          todayHighlightColor: colorScheme.primaryContainer.withValues(
            alpha: 0.3,
          ),
        ),
        timeLineProps: EasyTimeLineProps(
          separatorPadding: 16,
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
