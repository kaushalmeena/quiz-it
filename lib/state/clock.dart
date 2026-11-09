import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The current time. Overridden in tests to control timers, points and days.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
