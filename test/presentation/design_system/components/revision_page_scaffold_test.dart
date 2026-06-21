import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Neralune/presentation/design_system/components/revision_mvp_components.dart';

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
}
