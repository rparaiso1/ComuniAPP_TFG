import '../../domain/entities/calendar_event_entity.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_remote_datasource.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarRemoteDataSource remoteDataSource;

  CalendarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<CalendarEventEntity>> getMonthEvents(int year, int month) async {
    return (await remoteDataSource.getMonthEvents(year, month))
        .cast<CalendarEventEntity>();
  }

  @override
  Future<List<CalendarEventEntity>> getTodayEvents() async {
    return (await remoteDataSource.getTodayEvents())
        .cast<CalendarEventEntity>();
  }

  @override
  Future<List<CalendarEventEntity>> getUpcomingEvents() async {
    return (await remoteDataSource.getUpcomingEvents())
        .cast<CalendarEventEntity>();
  }

  @override
  Future<List<CalendarEventEntity>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return (await remoteDataSource.getEvents(
      startDate: startDate,
      endDate: endDate,
    ))
        .cast<CalendarEventEntity>();
  }
}
