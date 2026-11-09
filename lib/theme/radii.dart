import 'package:flutter/widgets.dart';

/// The app's corner radius scale. Use these instead of literal values.
abstract final class Radii {
  /// Tags and small labels.
  static const small = BorderRadius.all(Radius.circular(8));

  /// Buttons, answer tiles and other controls.
  static const medium = BorderRadius.all(Radius.circular(16));

  /// Cards and category tiles.
  static const large = BorderRadius.all(Radius.circular(20));

  /// Pills and progress bars.
  static const pill = BorderRadius.all(Radius.circular(999));
}
