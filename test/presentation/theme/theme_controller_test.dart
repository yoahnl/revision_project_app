import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revision_app/app/di/providers.dart';
import 'package:revision_app/core/storage/kv_storage_port.dart';
import 'package:revision_app/presentation/theme/theme_controller.dart';

class FakeKvStorage implements KvStoragePort {
  final Map<String, String> values = {};

  @override
  Future<String?> readString(String key) async => values[key];

  @override
  Future<void> writeString(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  test('theme controller defaults to system mode', () async {
    final storage = FakeKvStorage();
    final container = ProviderContainer(
      overrides: [kvStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    final mode = await container.read(themeProvider.future);

    expect(mode, ThemeMode.system);
  });

  test('theme controller persists selected dark mode', () async {
    final storage = FakeKvStorage();
    final container = ProviderContainer(
      overrides: [kvStorageProvider.overrideWithValue(storage)],
    );
    addTearDown(container.dispose);

    await container.read(themeProvider.future);
    await container.read(themeProvider.notifier).select(ThemeMode.dark);

    expect(await container.read(themeProvider.future), ThemeMode.dark);
    expect(storage.values['revision.theme_mode'], 'dark');
  });
}
