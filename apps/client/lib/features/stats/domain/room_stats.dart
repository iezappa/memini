import '../../../core/tracking/domain/tracking_stats.dart';
import '../../rooms/domain/room.dart';

/// Aggregate figures over a set of played rooms.
///
/// The shared figures come from [TrackingStats]; this only adds what is true
/// of escape rooms alone — that a room can be escaped or not.
class RoomStats {
  const RoomStats({required this.tracking, required this.escaped});

  final TrackingStats<Room> tracking;
  final int escaped;

  int get total => tracking.total;
  int get rated => tracking.rated;
  double? get averageRating => tracking.averageRating;
  Room? get bestRoom => tracking.best;
  Map<int, int> get roomsPerYear => tracking.perYear;

  int get failed => total - escaped;

  /// Share of played rooms that were escaped, from 0 to 1. Null when empty.
  double? get escapeRate => total == 0 ? null : escaped / total;

  static final empty = RoomStats(
    tracking: TrackingStats.empty<Room>(),
    escaped: 0,
  );

  factory RoomStats.from(List<Room> rooms) {
    var escaped = 0;
    for (final room in rooms) {
      if (room.escaped) escaped++;
    }
    return RoomStats(tracking: TrackingStats.from(rooms), escaped: escaped);
  }
}
