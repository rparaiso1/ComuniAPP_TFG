import '../entities/calendar_event_entity.dart';

abstract class CalendarRepository {
  Future<List<CalendarEventEntity>> getMonthEvents(int year, int month);
  Future<List<CalendarEventEntity>> getTodayEvents();
  Future<List<CalendarEventEntity>> getUpcomingEvents();
  Future<List<CalendarEventEntity>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  });
}
