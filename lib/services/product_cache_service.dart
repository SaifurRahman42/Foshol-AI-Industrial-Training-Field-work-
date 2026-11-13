import 'package:hive_flutter/hive_flutter.dart';

/// Stores a complete market snapshot in a Hive box.
/// The box is opened once in main() before the app starts.
class ProductCacheService {
  static const String boxName = 'foshol_market_cache';
  static const String snapshotKey = 'snapshot';

  Box get _box => Hive.box(boxName);

  Map<String, dynamic>? readSnapshot() {
    final value = _box.get(snapshotKey);
    if (value == null) return null;
    return Map<String, dynamic>.from(value as Map);
  }

  Future<void> writeSnapshot(Map<String, dynamic> snapshot) async {
    await _box.put(snapshotKey, snapshot);
  }

  Future<void> clear() async {
    await _box.delete(snapshotKey);
  }
}
