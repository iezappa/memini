/// The five things Memini tracks, in the order the home hub shows them.
///
/// This is a domain concept, not a presentation one: aggregate stats and the
/// backup both need to name a domain without importing any widgets.
enum TrackedDomain { rooms, dining, concerts, screen, games }
