import '../entities/booking_entity.dart';

abstract class BookingRepository {
  Future<List<BookingEntity>> getBookings({
    String? zoneId,
    bool myOnly = false,
    int skip = 0,
    int limit = 100,
  });
  Future<BookingEntity> getBooking(String bookingId);
  Future<BookingEntity> createBooking({
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });
  Future<BookingEntity> cancelBooking(String bookingId, {String? reason});
  Future<BookingEntity> approveBooking(String bookingId);
}
