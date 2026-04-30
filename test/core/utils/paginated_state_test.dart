import 'package:flutter_test/flutter_test.dart';
import 'package:comuniapp/core/utils/paginated_state.dart';

/// Concrete implementation for testing the PaginatedState mixin.
class TestPaginatedState with PaginatedState {
  @override
  final bool isLoadingMore;

  @override
  final bool hasMore;

  @override
  final int currentSkip;

  const TestPaginatedState({
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentSkip = 0,
  });

  TestPaginatedState copyWith({
    bool? isLoadingMore,
    bool? hasMore,
    int? currentSkip,
  }) {
    return TestPaginatedState(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }
}

void main() {
  group('kDefaultPageSize', () {
    test('is 20', () {
      expect(kDefaultPageSize, 20);
    });
  });

  group('PaginatedState mixin', () {
    test('default values', () {
      const state = TestPaginatedState();
      expect(state.isLoadingMore, isFalse);
      expect(state.hasMore, isTrue);
      expect(state.currentSkip, 0);
    });

    test('custom values', () {
      const state = TestPaginatedState(
        isLoadingMore: true,
        hasMore: false,
        currentSkip: 40,
      );
      expect(state.isLoadingMore, isTrue);
      expect(state.hasMore, isFalse);
      expect(state.currentSkip, 40);
    });

    test('copyWith updates isLoadingMore', () {
      const state = TestPaginatedState();
      final updated = state.copyWith(isLoadingMore: true);
      expect(updated.isLoadingMore, isTrue);
      expect(updated.hasMore, isTrue); // unchanged
      expect(updated.currentSkip, 0); // unchanged
    });

    test('copyWith updates hasMore', () {
      const state = TestPaginatedState();
      final updated = state.copyWith(hasMore: false);
      expect(updated.hasMore, isFalse);
      expect(updated.isLoadingMore, isFalse); // unchanged
    });

    test('copyWith updates currentSkip', () {
      const state = TestPaginatedState();
      final updated = state.copyWith(currentSkip: 20);
      expect(updated.currentSkip, 20);
    });

    test('simulates pagination flow', () {
      // Initial state
      const state = TestPaginatedState();
      expect(state.currentSkip, 0);
      expect(state.hasMore, isTrue);
      expect(state.isLoadingMore, isFalse);

      // Start loading more
      final loading = state.copyWith(isLoadingMore: true);
      expect(loading.isLoadingMore, isTrue);

      // Finish loading, advance skip by page size
      final page1 = loading.copyWith(
        isLoadingMore: false,
        currentSkip: kDefaultPageSize,
      );
      expect(page1.isLoadingMore, isFalse);
      expect(page1.currentSkip, kDefaultPageSize);
      expect(page1.hasMore, isTrue);

      // Load second page
      final page2 = page1.copyWith(
        currentSkip: kDefaultPageSize * 2,
      );
      expect(page2.currentSkip, 40);

      // Last page — no more items
      final done = page2.copyWith(hasMore: false);
      expect(done.hasMore, isFalse);
      expect(done.currentSkip, 40);
    });
  });
}
