import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Rolling the dice shows a value from 1 to 6', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DiceRoller()));

    expect(find.text('Hodené číslo: 1'), findsOneWidget);

    for (var i = 0; i < 20; i++) {
      await tester.tap(find.text('Hoď kockou'));
      await tester.pump();

      final image = tester.widget<Image>(find.byType(Image));
      final assetName = (image.image as AssetImage).assetName;
      final value = int.parse(assetName.split('dice-').last.split('.').first);

      expect(value, inInclusiveRange(1, 6));
      expect(find.text('Hodené číslo: $value'), findsOneWidget);
    }
  });
}
