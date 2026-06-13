import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../app/di/providers.dart';

part 'theme_controller.g.dart';

final themeProvider = themeControllerProvider;
const themeModeStorageKey = 'revision.theme_mode';

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  @override
  Future<ThemeMode> build() async {
    final storage = ref.read(kvStorageProvider);
    final storedMode = await storage.readString(themeModeStorageKey);
    return decodeThemeMode(storedMode);
  }

  Future<void> select(ThemeMode mode) async {
    state = AsyncData(mode);
    await ref
        .read(kvStorageProvider)
        .writeString(themeModeStorageKey, encodeThemeMode(mode));
  }
}

ThemeMode decodeThemeMode(String? value) {
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

String encodeThemeMode(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
  };
}
