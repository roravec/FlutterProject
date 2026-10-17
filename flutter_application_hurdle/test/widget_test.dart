import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_application_1/hurdle_provider.dart';
import 'package:flutter_application_1/main.dart';

void typeWord(HurdleProvider p, String word) {
  for (final ch in word.split('')) {
    p.inputLetter(ch);
  }
}

void main() {
  group('HurdleProvider', () {
    late HurdleProvider p;

    setUp(() {
      p = HurdleProvider()..init();
      p.targetWord = 'APPLE';
    });

    test('correct word wins', () {
      typeWord(p, 'APPLE');
      expect(p.isValidWord, isTrue);
      p.checkAnswer();
      expect(p.wins, isTrue);
      expect(p.attempts, 1);
      // po výhre už nejde písať
      p.inputLetter('A');
      expect(p.index, 5);
    });

    test('wrong word marks letters and moves to next row', () {
      typeWord(p, 'PLANT');
      p.checkAnswer();
      expect(p.wins, isFalse);
      expect(p.attempts, 1);
      expect(p.hurdleBoard[0].existsInTarget, isTrue); // P
      expect(p.hurdleBoard[3].doesNotExistInTarget, isTrue); // N
      expect(p.excludedLetters, containsAll(['N', 'T']));
      expect(p.rowInputs, isEmpty);
      // mazanie nesmie zasiahnuť odoslaný riadok
      p.deleteLetter();
      expect(p.hurdleBoard[4].letter, 'T');
    });

    test('six wrong guesses lose, reset starts new game', () {
      for (int i = 0; i < 6; i++) {
        typeWord(p, 'PLANT');
        p.checkAnswer();
      }
      expect(p.noAttemptsLeft, isTrue);
      expect(p.wins, isFalse);

      p.reset();
      expect(p.attempts, 0);
      expect(p.index, 0);
      expect(p.excludedLetters, isEmpty);
      expect(p.hurdleBoard.every((w) => w.letter.isEmpty), isTrue);
      expect(p.targetWord, isNotEmpty);
    });
  });

  testWidgets('keyboard input appears on board', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => HurdleProvider()..init(),
        child: const MyApp(),
      ),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Q'));
    await tester.pump();
    expect(find.text('Q'), findsNWidgets(2)); // kláves + políčko
    await tester.tap(find.text('SUBMIT'));
    await tester.pump();
    expect(find.text('Not enough letters'), findsOneWidget);
  });
}
