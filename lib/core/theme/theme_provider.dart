import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

const String themeBoxName = 'themeBox';
const String themeKey = 'themeMode';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final Box _box;
  ThemeNotifier(this._box) : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() {
    final storedTheme = _box.get(themeKey, defaultValue: ThemeMode.system.index);
    state = ThemeMode.values[storedTheme];
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    state = themeMode;
    await _box.put(themeKey, themeMode.index);
  }
}

// Provider for our ThemeNotifier
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final box = Hive.box(themeBoxName);
  return ThemeNotifier(box);
});
