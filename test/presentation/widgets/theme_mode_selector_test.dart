import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/app/di/providers.dart';
import 'package:Neralune/core/storage/kv_storage_port.dart';
import 'package:Neralune/presentation/widgets/theme_mode_selector.dart';

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
  testWidgets('selecting dark mode persists the user preference', (
    tester,
  ) async {
    final storage = FakeKvStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [kvStorageProvider.overrideWithValue(storage)],
        child: const MaterialApp(home: Scaffold(body: ThemeModeSelector())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sombre'));
    await tester.pumpAndSettle();

    expect(storage.values['revision.theme_mode'], 'dark');
  });
}
