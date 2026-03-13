import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:comuniapp/core/theme/app_colors.dart';
import 'package:comuniapp/core/utils/l10n_extension.dart';
import 'package:comuniapp/core/utils/responsive.dart';
import 'package:comuniapp/features/calendar/domain/entities/calendar_event_entity.dart';
import 'package:comuniapp/features/calendar/presentation/controllers/calendar_controller.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref.read(calendarControllerProvider.notifier).loadMonth(now.year, now.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calendarControllerProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: context.colors.backgroundGradient,
        ),
        child: ContentConstraint(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: context.colors.onGradient),
                    tooltip: context.l.goBack,
                    onPressed: () => context.canPop() ? context.pop() : context.goNamed('home'),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.today, color: context.colors.onGradient),
                      tooltip: context.l.goToToday,
                      onPressed: () {
                        final now = DateTime.now();
                        ref.read(calendarControllerProvider.notifier).selectDate(now);
                        ref.read(calendarControllerProvider.notifier).changeFocusedMonth(now);
                      },
                    ),
                  ),
                ],
                flexibleSpace: Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Text(
                        context.l.calendar,
                        style: TextStyle(
                          color: context.colors.onGradient,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // Calendar Header
                        _CalendarHeader(
                          focusedMonth: state.focusedMonth,
                          onPreviousMonth: () {
                            final prev = DateTime(
                              state.focusedMonth.year,
                              state.focusedMonth.month - 1,
                            );
                            ref.read(calendarControllerProvider.notifier).changeFocusedMonth(prev);
                          },
                          onNextMonth: () {
                            final next = DateTime(
                              state.focusedMonth.year,
                              state.focusedMonth.month + 1,
                            );
                            ref.read(calendarControllerProvider.notifier).changeFocusedMonth(next);
                          },
                        ),

                        // Calendar Grid
                        _CalendarGrid(
                          focusedMonth: state.focusedMonth,
                          selectedDate: state.selectedDate,
                          eventsByDay: state.eventsByDay,
                          onDaySelected: (date) {
                            ref.read(calendarControllerProvider.notifier).selectDate(date);
                          },
                        ),

                        const Divider(height: 1),

                        // Selected Day Events
                        Expanded(
                          child: _EventsList(
                            selectedDate: state.selectedDate,
                            events: state.getEventsForDay(state.selectedDate),
                          ),
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime focusedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _CalendarHeader({
    required this.focusedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  static List<String> _getMonthNames(BuildContext context) => [
    context.l.monthJanuary, context.l.monthFebruary, context.l.monthMarch,
    context.l.monthApril, context.l.monthMay, context.l.monthJune,
    context.l.monthJuly, context.l.monthAugust, context.l.monthSeptember,
    context.l.monthOctober, context.l.monthNovember, context.l.monthDecember,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: context.l.previousMonth,
            onPressed: onPreviousMonth,
          ),
          Text(
            '${_getMonthNames(context)[focusedMonth.month - 1]} ${focusedMonth.year}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: context.l.nextMonth,
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Map<DateTime, List<CalendarEventEntity>> eventsByDay;
  final Function(DateTime) onDaySelected;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.eventsByDay,
    required this.onDaySelected,
  });

  static List<String> _getDayNames(BuildContext context) => [
    context.l.dayMon, context.l.dayTue, context.l.dayWed,
    context.l.dayThu, context.l.dayFri, context.l.daySat, context.l.daySun,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);
    
    // Lunes = 1, Domingo = 7. Ajustamos para que Lunes sea 0.
    final startWeekday = (firstDayOfMonth.weekday - 1) % 7;
    final daysInMonth = lastDayOfMonth.day;
    
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedSelected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    return Column(
      children: [
        // Day names header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: _getDayNames(context).map((name) {
              return Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),

        // Calendar days grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: 42, // 6 weeks x 7 days
          itemBuilder: (context, index) {
            final dayOffset = index - startWeekday;
            if (dayOffset < 0 || dayOffset >= daysInMonth) {
              return const SizedBox();
            }

            final day = DateTime(focusedMonth.year, focusedMonth.month, dayOffset + 1);
            final normalizedDay = DateTime(day.year, day.month, day.day);
            final isToday = normalizedDay == normalizedToday;
            final isSelected = normalizedDay == normalizedSelected;
            final events = eventsByDay[normalizedDay] ?? [];

            return InkWell(
              onTap: () => onDaySelected(day),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isToday
                          ? theme.colorScheme.primaryContainer
                          : null,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday && !isSelected
                      ? Border.all(color: theme.colorScheme.primary, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${dayOffset + 1}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isToday || isSelected ? FontWeight.bold : null,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : isToday
                                ? theme.colorScheme.primary
                                : null,
                      ),
                    ),
                    if (events.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: events.take(3).map((e) {
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: Color(e.colorValue),
                              shape: BoxShape.circle,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _EventsList extends StatelessWidget {
  final DateTime selectedDate;
  final List<CalendarEventEntity> events;

  const _EventsList({
    required this.selectedDate,
    required this.events,
  });

  static List<String> _getDayNamesLong(BuildContext context) => [
    context.l.dayMonFull, context.l.dayTueFull, context.l.dayWedFull,
    context.l.dayThuFull, context.l.dayFriFull, context.l.daySatFull, context.l.daySunFull,
  ];

  static List<String> _getMonthNames(BuildContext context) => [
    context.l.monthJanuaryLower, context.l.monthFebruaryLower, context.l.monthMarchLower,
    context.l.monthAprilLower, context.l.monthMayLower, context.l.monthJuneLower,
    context.l.monthJulyLower, context.l.monthAugustLower, context.l.monthSeptemberLower,
    context.l.monthOctoberLower, context.l.monthNovemberLower, context.l.monthDecemberLower,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weekdayIndex = (selectedDate.weekday - 1) % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${_getDayNamesLong(context)[weekdayIndex]}, ${selectedDate.day} de ${_getMonthNames(context)[selectedDate.month - 1]}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Events list
        Expanded(
          child: events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 48,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l.noEvents,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _EventCard(event: event);
                  },
                ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final CalendarEventEntity event;

  const _EventCard({required this.event});

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  IconData _getEventIcon() {
    switch (event.type) {
      case 'community':
        return Icons.groups;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: Color(event.colorValue),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${_formatTime(event.start)} - ${_formatTime(event.end)}'),
            if (event.facilityName != null)
              Text(
                event.facilityName!,
                style: TextStyle(color: theme.colorScheme.primary),
              ),
          ],
        ),
        trailing: Icon(_getEventIcon(), color: Color(event.colorValue)),
      ),
    );
  }
}
