import 'trackable.dart';
import 'tracking_filter.dart';

/// Domain port every tracked feature persists through.
///
/// [T] is the entry, [D] its draft (an entry before the store assigns an id)
/// and [F] the domain's own filter. Keeping all three as type parameters is
/// what lets the features stay strongly typed while sharing one contract.
abstract interface class TrackingRepository<
  T extends Trackable,
  D,
  F extends TrackingFilter
> {
  Future<List<T>> list(F filter);

  Future<T?> findById(int id);

  Future<T> create(D draft);

  Future<void> update(T entry);

  Future<void> delete(int id);

  Stream<List<T>> watch(F filter);
}
