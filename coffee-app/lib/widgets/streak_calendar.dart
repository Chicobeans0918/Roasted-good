import 'package:flutter/material.dart';

import '../data/streaks.dart';
import '../models/tried_coffee.dart';
import '../theme/app_theme.dart';

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Month calendar marking the days with at least one tasting.
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({super.key, required this.tried});

  final List<TriedCoffee> tried;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    // Sunday-first leading blanks.
    final leading = first.weekday % 7;
    final logged = tastingDays(tried);
    final today = DateTime(now.year, now.month, now.day);

    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      final isLogged = logged.contains(date);
      final isToday = date == today;
      cells.add(
        Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isLogged ? p.accent : Colors.transparent,
            border: isToday && !isLogged
                ? Border.all(color: p.ink, width: 1.5)
                : null,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isLogged ? p.onAccent : p.muted,
              fontWeight:
                  isLogged ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: p.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_monthNames[now.month - 1]} ${now.year}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final d in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: cells,
          ),
        ],
      ),
    );
  }
}
