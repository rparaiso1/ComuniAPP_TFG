import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:comuniapp/core/di/providers.dart';
import 'package:comuniapp/core/services/org_selector_service.dart';
import 'package:comuniapp/features/calendar/data/datasources/calendar_remote_datasource.dart';
import 'package:comuniapp/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:comuniapp/features/calendar/domain/entities/calendar_event_entity.dart';
import 'package:comuniapp/features/calendar/domain/repositories/calendar_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = ref.watch(authRemoteDataSourceProvider);

  final activeOrgId = ref.watch(activeOrgIdProvider);
  final remoteDataSource = CalendarRemoteDataSourceImpl(
    client: httpClient,
    getToken: () => authDataSource.accessToken ?? '',
    getOrgId: () => activeOrgId,
  );

  return CalendarRepositoryImpl(remoteDataSource: remoteDataSource);
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class CalendarState {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final List<CalendarEventEntity> events;
  final Map<DateTime, List<CalendarEventEntity>> eventsByDay;
  final bool isLoading;
  final String? error;

  CalendarState({
    DateTime? selectedDate,
    DateTime? focusedMonth,
    this.events = const [],
    this.eventsByDay = const {},
    this.isLoading = false,
    this.error,
  })  : selectedDate = selectedDate ?? DateTime.now(),
        focusedMonth = focusedMonth ?? DateTime.now();

  CalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedMonth,
    List<CalendarEventEntity>? events,
    Map<DateTime, List<CalendarEventEntity>>? eventsByDay,
    bool? isLoading,
    String? error,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      events: events ?? this.events,
      eventsByDay: eventsByDay ?? this.eventsByDay,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<CalendarEventEntity> getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return eventsByDay[normalized] ?? [];
  }
}

// ---------------------------------------------------------------------------
// Controller (Notifier pattern)
// ---------------------------------------------------------------------------

class CalendarController extends Notifier<CalendarState> {
  late CalendarRepository repository;

  @override
  CalendarState build() {
    repository = ref.watch(calendarRepositoryProvider);
    return CalendarState();
  }

  Future<void> loadMonth(int year, int month) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final events = await repository.getMonthEvents(year, month);

      // Agrupar por día
      final Map<DateTime, List<CalendarEventEntity>> byDay = {};
      for (var event in events) {
        final day = DateTime(event.start.year, event.start.month, event.start.day);
        byDay.putIfAbsent(day, () => []).add(event);
      }

      state = state.copyWith(
        events: events,
        eventsByDay: byDay,
        isLoading: false,
        focusedMonth: DateTime(year, month),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadToday() async {
    try {
      final todayEvents = await repository.getTodayEvents();

      final today = DateTime.now();
      final normalizedToday = DateTime(today.year, today.month, today.day);

      final newByDay =
          Map<DateTime, List<CalendarEventEntity>>.from(state.eventsByDay);
      newByDay[normalizedToday] = todayEvents;

      state = state.copyWith(eventsByDay: newByDay);
    } catch (e) {
      // Silently fail for today's events
    }
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void changeFocusedMonth(DateTime month) {
    state = state.copyWith(focusedMonth: month);
    loadMonth(month.year, month.month);
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarState>(
  () => CalendarController(),
);
