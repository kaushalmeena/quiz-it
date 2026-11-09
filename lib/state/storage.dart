import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Minimal key-value storage, so state can be persisted without tying
/// notifiers (or tests) to a platform plugin.
abstract interface class Storage {
  String? read(String key);

  Future<void> write(String key, String value);
}

/// [Storage] backed by shared_preferences, with values cached in memory so
/// reads are synchronous.
class PrefsStorage implements Storage {
  PrefsStorage._(this._prefs);

  static Future<PrefsStorage> open(Set<String> keys) async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: keys),
    );
    return PrefsStorage._(prefs);
  }

  final SharedPreferencesWithCache _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);
}

/// In-memory [Storage], used in tests.
class MemoryStorage implements Storage {
  MemoryStorage([Map<String, String>? values]) : values = values ?? {};

  final Map<String, String> values;

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

/// Overridden in `main()` once storage has been opened.
final storageProvider = Provider<Storage>(
  (ref) => throw UnimplementedError('storageProvider must be overridden'),
);
