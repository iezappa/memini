import 'package:flutter/material.dart';

import '../../core/tracking/domain/tracked_domain.dart';
import '../concerts/presentation/gig_detail_screen.dart';
import '../concerts/presentation/gig_form_screen.dart';
import '../dining/presentation/meal_detail_screen.dart';
import '../dining/presentation/meal_form_screen.dart';
import '../games/presentation/game_detail_screen.dart';
import '../games/presentation/game_form_screen.dart';
import '../rooms/presentation/room_detail_screen.dart';
import '../rooms/presentation/room_form_screen.dart';
import '../screen/presentation/viewing_detail_screen.dart';
import '../screen/presentation/viewing_form_screen.dart';

/// Which screen a domain reads and writes with.
///
/// The hub is the one place that has to open any of the five without
/// knowing which, so the switch lives here rather than being written out
/// again wherever a domain has to be turned into a screen.
Widget detailScreenFor(TrackedDomain domain, String id) => switch (domain) {
  TrackedDomain.rooms => RoomDetailScreen(roomId: id),
  TrackedDomain.dining => MealDetailScreen(mealId: id),
  TrackedDomain.concerts => GigDetailScreen(gigId: id),
  TrackedDomain.screen => ViewingDetailScreen(viewingId: id),
  TrackedDomain.games => GameDetailScreen(gameId: id),
};

Widget formScreenFor(TrackedDomain domain) => switch (domain) {
  TrackedDomain.rooms => const RoomFormScreen(),
  TrackedDomain.dining => const MealFormScreen(),
  TrackedDomain.concerts => const GigFormScreen(),
  TrackedDomain.screen => const ViewingFormScreen(),
  TrackedDomain.games => const GameFormScreen(),
};
