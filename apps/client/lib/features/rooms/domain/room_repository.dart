import '../../../core/tracking/domain/tracking_filter.dart';
import '../../../core/tracking/domain/tracking_repository.dart';
import 'room.dart';

/// Narrows a room list: the shared axes plus the two that only escape rooms
/// have — which franchise ran it, and whether the team got out.
class RoomFilter extends TrackingFilter {
  const RoomFilter({
    super.query,
    super.minRating,
    super.sort,
    this.franchiseId,
    this.escaped,
  });

  final int? franchiseId;
  final bool? escaped;

  @override
  bool get isEmpty => super.isEmpty && franchiseId == null && escaped == null;

  @override
  RoomFilter copyWith({
    String? query,
    double? minRating,
    TrackingSort? sort,
    int? franchiseId,
    bool? escaped,
    bool clearQuery = false,
    bool clearMinRating = false,
    bool clearFranchise = false,
    bool clearEscaped = false,
  }) {
    return RoomFilter(
      query: clearQuery ? null : (query ?? this.query),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      sort: sort ?? this.sort,
      franchiseId: clearFranchise ? null : (franchiseId ?? this.franchiseId),
      escaped: clearEscaped ? null : (escaped ?? this.escaped),
    );
  }
}

/// Domain port for room persistence.
abstract interface class RoomRepository
    implements TrackingRepository<Room, RoomDraft, RoomFilter> {}
