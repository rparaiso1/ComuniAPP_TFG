import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/services/org_selector_service.dart';
import '../../data/datasources/booking_remote_datasource.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../../../core/utils/paginated_state.dart';

// Repository provider
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final authDataSource = ref.watch(authRemoteDataSourceProvider);
  
  final activeOrgId = ref.watch(activeOrgIdProvider);
  final remoteDataSource = BookingRemoteDataSourceImpl(
    client: httpClient,
    getToken: () => authDataSource.accessToken ?? '',
    getOrgId: () => activeOrgId,
  );

  return BookingRepositoryImpl(remoteDataSource: remoteDataSource);
});

// State class
class BookingState with PaginatedState {
  final List<BookingEntity> bookings;
  final bool isLoading;
  final String? error;
  final bool isCreating;
  @override
  final bool isLoadingMore;
  @override
  final bool hasMore;
  @override
  final int currentSkip;

  BookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.isCreating = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
  });

  BookingState copyWith({
    List<BookingEntity>? bookings,
    bool? isLoading,
    String? error,
    bool? isCreating,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCreating: isCreating ?? this.isCreating,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}

// Controller
class BookingController extends Notifier<BookingState> {
  late BookingRepository repository;
  String? _lastZoneId;
  bool _lastMyOnly = false;

  @override
  BookingState build() {
    repository = ref.watch(bookingRepositoryProvider);
    return BookingState();
  }

  Future<void> loadBookings({String? zoneId, bool myOnly = false}) async {
    _lastZoneId = zoneId;
    _lastMyOnly = myOnly;
    state = state.copyWith(isLoading: true, error: null, currentSkip: 0, hasMore: true);
    try {
      final bookings = await repository.getBookings(
        zoneId: zoneId,
        myOnly: myOnly,
        skip: 0,
        limit: kDefaultPageSize,
      );
      state = state.copyWith(
        bookings: bookings,
        isLoading: false,
        currentSkip: bookings.length,
        hasMore: bookings.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final newBookings = await repository.getBookings(
        zoneId: _lastZoneId,
        myOnly: _lastMyOnly,
        skip: state.currentSkip,
        limit: kDefaultPageSize,
      );
      state = state.copyWith(
        bookings: [...state.bookings, ...newBookings],
        isLoadingMore: false,
        currentSkip: state.currentSkip + newBookings.length,
        hasMore: newBookings.length >= kDefaultPageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createBooking({
    required String zoneId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    state = state.copyWith(isCreating: true, error: null);
    try {
      final newBooking = await repository.createBooking(
        zoneId: zoneId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      state = state.copyWith(
        bookings: [newBooking, ...state.bookings],
        isCreating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: e.toString(),
      );
    }
  }

  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final updated = await repository.cancelBooking(bookingId, reason: reason);
      state = state.copyWith(
        bookings: state.bookings
            .map((b) => b.id == bookingId ? updated : b)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> approveBooking(String bookingId) async {
    try {
      final updated = await repository.approveBooking(bookingId);
      state = state.copyWith(
        bookings: state.bookings
            .map((b) => b.id == bookingId ? updated : b)
            .toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

// Controller provider
final bookingControllerProvider =
    NotifierProvider<BookingController, BookingState>(
  () => BookingController(),
);
