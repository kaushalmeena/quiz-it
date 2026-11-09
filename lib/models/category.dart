import 'package:flutter/widgets.dart';

/// A trivia category. A `null` [id] means "any category".
@immutable
class Category {
  const Category({required this.id, required this.name, required this.icon});

  final int? id;
  final String name;
  final IconData icon;

  /// Drops the "Entertainment: " / "Science: " prefixes the API uses.
  static String shortName(String name) {
    final separator = name.indexOf(': ');
    return separator == -1 ? name : name.substring(separator + 2);
  }
}
