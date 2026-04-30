import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<BookingEntity>> getBookings({
    String? zoneId,
    bool myOnly = false,
    int skip = 0,
    int limit = 100,
  }) async {
    return (await remoteDataSource.getBookings(
      zoneId: zoneId,
      myOnly: myOnly,
      skip: skip,
      limit: limit,
    ))
        .cast<BookingEntity>();
  }

  @override
  Future<BookingEntity> getBooking(String bookingId) async {
    return await remoteDataSource.getBooking(bookingId) as BookingEntity;
  }

  @override
  Future<BookingEntity> createBooking({
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    return await remoteDataSource.createBooking(
      zoneId: zoneId,
      startTime: startTime,
      endTime: endTime,
      notes: notes,
    ) as BookingEntity;
  }

  @override
  Future<BookingEntity> cancelBooking(String bookingId, {String? reason}) async {
    return await remoteDataSource.cancelBooking(bookingId, reason: reason) as BookingEntity;
  }

  @override
  Future<BookingEntity> approveBooking(String bookingId) async {
    return await remoteDataSource.approveBooking(bookingId) as BookingEntity;
  }
}
