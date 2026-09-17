import '../../../core/tracking/domain/trackable.dart';

/// An escape room the owner has played.
class Room implements Trackable {
  const Room({
    required this.id,
    this.updatedAt,
    required this.title,
    required this.happenedOn,
    required this.escaped,
    this.description,
    this.franchiseId,
    this.rating,
    this.review,
    this.timeLeftMinutes,
  });

  @override
  final String id;

  @override
  final DateTime? updatedAt;
  @override
  final String title;
  @override
  final String? description;
  @override
  final double? rating;
  @override
  final String? review;
  @override
  final DateTime happenedOn;

  final String? franchiseId;
  final bool escaped;

  /// Minutes left on the clock when the room was escaped. Null when unknown,
  /// and meaningless when [escaped] is false.
  final int? timeLeftMinutes;

  @override
  bool get isRated => rating != null;

  Room copyWith({
    String? title,
    String? description,
    String? franchiseId,
    double? rating,
    String? review,
    DateTime? happenedOn,
    bool? escaped,
    int? timeLeftMinutes,
    bool clearFranchise = false,
    bool clearRating = false,
    bool clearTimeLeft = false,
  }) {
    return Room(
      id: id,
      updatedAt: updatedAt,
      title: title ?? this.title,
      description: description ?? this.description,
      franchiseId: clearFranchise ? null : (franchiseId ?? this.franchiseId),
      rating: clearRating ? null : (rating ?? this.rating),
      review: review ?? this.review,
      happenedOn: happenedOn ?? this.happenedOn,
      escaped: escaped ?? this.escaped,
      timeLeftMinutes: clearTimeLeft
          ? null
          : (timeLeftMinutes ?? this.timeLeftMinutes),
    );
  }
}

/// Input for creating a room, before the store assigns an id.
class RoomDraft {
  const RoomDraft({
    required this.title,
    required this.happenedOn,
    required this.escaped,
    this.description,
    this.franchiseId,
    this.rating,
    this.review,
    this.timeLeftMinutes,
  });

  final String title;
  final String? description;
  final String? franchiseId;
  final double? rating;
  final String? review;
  final DateTime happenedOn;
  final bool escaped;
  final int? timeLeftMinutes;
}
