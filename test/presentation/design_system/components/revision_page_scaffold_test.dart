import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';
import 'package:Neralune/presentation/design_system/tokens/revision_typography.dart';

void main() {
  testWidgets('keeps header fixed while body content scrolls', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RevisionPageScaffold(
            headerChildren: const [
              Text('Fixed header', key: ValueKey('fixed-header')),
            ],
            children: [
              for (var index = 0; index < 30; index++)
                SizedBox(height: 64, child: Text('Body item $index')),
            ],
          ),
        ),
      ),
    );

    final initialHeaderTop = tester
        .getTopLeft(find.byKey(const ValueKey('fixed-header')))
        .dy;

    await tester.drag(find.byType(Scrollable), const Offset(0, -420));
    await tester.pumpAndSettle();

    final scrolledHeaderTop = tester
        .getTopLeft(find.byKey(const ValueKey('fixed-header')))
        .dy;

    expect(scrolledHeaderTop, initialHeaderTop);
  });

  testWidgets('top-aligns short pages instead of vertically centering them', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevisionPageScaffold(
            children: [
              Text('Short page title', key: ValueKey('short-page-title')),
            ],
          ),
        ),
      ),
    );

    final titleTop = tester
        .getTopLeft(find.byKey(const ValueKey('short-page-title')))
        .dy;

    expect(titleTop, lessThan(120));
  });

  testWidgets('uses the canonical V4 content width by default', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 720);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevisionPageScaffold(
            children: [
              SizedBox(
                key: ValueKey('content-probe'),
                height: 24,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('content-probe'))).width,
      580,
    );
  });

  testWidgets('expands primary pages on fullscreen desktop layouts', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1920, 1080);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevisionPageScaffold(
            children: [
              SizedBox(
                key: ValueKey('wide-content-probe'),
                height: 24,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const ValueKey('wide-content-probe'))).width,
      greaterThan(1400),
    );
  });

  testWidgets('page header keeps title and trailing top-aligned', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RevisionPageHeader(
            title: 'Cours',
            subtitle: 'Ta bibliothèque',
            trailing: SizedBox(
              key: ValueKey('header-trailing'),
              width: 48,
              height: 72,
            ),
          ),
        ),
      ),
    );

    final titleFinder = find.text('Cours');
    final subtitleFinder = find.text('Ta bibliothèque');

    expect(titleFinder, findsOneWidget);
    expect(subtitleFinder, findsOneWidget);
    expect(
      tester.widget<Text>(titleFinder).style,
      RevisionTypography.pageTitle,
    );
    expect(
      tester.getTopLeft(titleFinder).dy,
      tester.getTopLeft(find.byKey(const ValueKey('header-trailing'))).dy,
    );
  });
}
