/// Default number of items per page for paginated lists.
const int kDefaultPageSize = 20;

/// Mixin that defines the contract for paginated state classes.
///
/// State classes using this mixin should include [isLoadingMore],
/// [hasMore], and [currentSkip] fields in their constructors and
/// `copyWith` methods.
///
/// Example:
/// ```dart
/// class MyState with PaginatedState {
///   @override final bool isLoadingMore;
///   @override final bool hasMore;
///   @override final int currentSkip;
///   // ...
/// }
/// ```
mixin PaginatedState {
  /// Whether more items are currently being loaded (infinite scroll).
  bool get isLoadingMore;

  /// Whether there are more items available on the server.
  bool get hasMore;

  /// Current skip offset for the next page request.
  int get currentSkip;
}
