import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';
import '../../theme/tokens.dart';
import '../domain/map_point.dart';

/// A still map of one place, drawn from OpenStreetMap's own tiles.
///
/// No package and no key. A slippy map is a grid of 256px PNGs addressed by
/// zoom, column and row, so the handful of them that cover this box can be
/// asked for directly and laid out by hand. That keeps the preview to five
/// or six requests, which is what OpenStreetMap's tile policy asks of a
/// personal app, and it keeps a map library — and its own map of
/// dependencies — out of a notebook that otherwise has none.
///
/// Deliberately not interactive: this is a picture that answers "where was
/// that", and the link underneath opens the real map for everything else.
class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    required this.point,
    this.height = 180,
    this.zoom = 16,
  });

  final MapPoint point;
  final double height;

  /// 16 shows the block a place is on. Lower loses the street names, higher
  /// loses everything around it.
  final int zoom;

  static const _tile = 256.0;
  static const _host = 'https://tile.openstreetmap.org';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Radii.card,
      child: SizedBox(
        height: height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final centre = _pixelsOf(point, zoom);
            // The top-left corner of the box, in the world's own pixels.
            final left = centre.dx - width / 2;
            final top = centre.dy - height / 2;

            return Stack(
              fit: StackFit.expand,
              children: [
                // A plate under the tiles, so the box has the right shape
                // from the first frame rather than growing into it as each
                // picture lands.
                ColoredBox(color: context.colors.surfaceContainerHighest),
                for (var x = (left / _tile).floor();
                    x <= ((left + width) / _tile).floor();
                    x++)
                  for (var y = (top / _tile).floor();
                      y <= ((top + height) / _tile).floor();
                      y++)
                    Positioned(
                      left: x * _tile - left,
                      top: y * _tile - top,
                      width: _tile,
                      height: _tile,
                      child: Image.network(
                        '$_host/$zoom/${_wrap(x, zoom)}/$y.png',
                        fit: BoxFit.cover,
                        // A tile that does not arrive leaves the plate
                        // showing, which reads as a piece of map still
                        // loading rather than as something broken.
                        errorBuilder: (context, _, _) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                // The pin, at the middle of the box by construction.
                Center(
                  child: Padding(
                    // The point of a pin is its tip, not its centre.
                    padding: const EdgeInsets.only(bottom: 28),
                    child: Icon(
                      Icons.place,
                      size: 34,
                      color: context.colors.primary,
                      shadows: const [
                        Shadow(color: Color(0x99000000), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
                // Required wherever these tiles are shown, and it is the
                // least anyone can do for a map somebody else surveyed.
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(color: Color(0xB3FFFFFF)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        '© OpenStreetMap',
                        style: context.text.bodySmall?.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF3A3A3A),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Where a point falls on the whole world, measured in tile pixels.
  ///
  /// The Web Mercator projection every slippy map uses: longitude is a
  /// straight scale, latitude goes through the same log-tangent the
  /// projection is defined by.
  static Offset _pixelsOf(MapPoint point, int zoom) {
    final world = _tile * (1 << zoom);
    final latitude = point.latitude * math.pi / 180;

    return Offset(
      (point.longitude + 180) / 360 * world,
      (1 - _asinh(math.tan(latitude)) / math.pi) / 2 * world,
    );
  }

  /// The world is a cylinder: a box that runs off the right edge picks the
  /// map up again on the left.
  static int _wrap(int x, int zoom) {
    final columns = 1 << zoom;

    return ((x % columns) + columns) % columns;
  }

  static double _asinh(double x) => math.log(x + math.sqrt(x * x + 1));
}
