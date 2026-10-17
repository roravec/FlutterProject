import 'dart:math';

import 'package:english_words/english_words.dart' as words;
import 'package:flutter/foundation.dart';

import 'wordle.dart';

class HurdleProvider extends ChangeNotifier {
  // Generátor náhodných čísel (pre výber cieľového slova)
  final random = Random.secure();

  // Zoznam všetkých slov dĺžky 5 znakov
  List<String> totalWords = [];

  // Dočasné vstupy používateľa (aktuálny riadok v mriežke)
  List<String> rowInputs = [];

  // Zoznam vyradených písmen (písmená, ktoré nie sú v cieľovom slove)
  List<String> excludedLetters = [];

  // Herný panel – 30 prvkov typu Wordle (6 riadkov × 5 písmen)
  List<Wordle> hurdleBoard = [];

  // Cieľové (náhodne vybrané) slovo
  String targetWord = '';

  int count = 0; // počet písmen v aktuálnom riadku
  int index = 0; // pozícia v mriežke
  final int lettersPerRow = 5;

  final int totalAttempts = 6;
  int attempts = 0; // počet odoslaných (vyhodnotených) pokusov

  bool wins = false;

  // ------------------------- INICIALIZÁCIA -------------------------
  void init() {
    totalWords = words.all.where((element) => element.length == 5).toList();
    generateBoard();
    generateRandomWord();
  }

  // ------------------------- GENEROVANIE MRIEŽKY -------------------------
  void generateBoard() {
    hurdleBoard = List.generate(
      totalAttempts * lettersPerRow,
      (index) => Wordle(letter: ''),
    );
  }

  // ------------------------- GENEROVANIE CIEĽOVÉHO SLOVA -------------------------
  void generateRandomWord() {
    targetWord = totalWords[random.nextInt(totalWords.length)].toUpperCase();
    debugPrint(targetWord);
  }

  // ------------------------- GETTERY -------------------------
  bool get isValidWord =>
      totalWords.contains(rowInputs.join('').toLowerCase());

  bool get shouldCheckForAnswer => rowInputs.length == lettersPerRow;

  bool get noAttemptsLeft => attempts == totalAttempts;

  // Hra skončila – hráč vyhral alebo minul všetky pokusy
  bool get isGameOver => wins || noAttemptsLeft;

  // ------------------------- VSTUP PÍSMENA -------------------------
  void inputLetter(String letter) {
    if (isGameOver) return;
    if (count < lettersPerRow && index < hurdleBoard.length) {
      rowInputs.add(letter);
      hurdleBoard[index] = Wordle(letter: letter);
      count++;
      index++;
      notifyListeners();
    }
  }

  // ------------------------- MAZANIE PÍSMENA -------------------------
  void deleteLetter() {
    if (isGameOver) return;
    // Mazať sa dá iba v aktuálnom riadku (count > 0)
    if (count > 0) {
      rowInputs.removeLast();
      hurdleBoard[index - 1] = Wordle(letter: '');
      count--;
      index--;
      notifyListeners();
    }
  }

  // ------------------------- KONTROLA ODPOVEDE -------------------------
  void checkAnswer() {
    final input = rowInputs.join('');
    _markLettersOnBoard();
    attempts++;
    if (targetWord == input) {
      wins = true;
    } else if (attempts < totalAttempts) {
      _goToNextRow();
    }
    notifyListeners();
  }

  // Označí písmená v práve odoslanom riadku
  void _markLettersOnBoard() {
    final rowStart = index - lettersPerRow;
    for (int i = rowStart; i < index; i++) {
      final letter = hurdleBoard[i].letter;
      if (targetWord.contains(letter)) {
        hurdleBoard[i].existsInTarget = true;
      } else {
        hurdleBoard[i].doesNotExistInTarget = true;
        if (!excludedLetters.contains(letter)) {
          excludedLetters.add(letter);
        }
      }
    }
  }

  void _goToNextRow() {
    count = 0;
    rowInputs.clear();
  }

  // ------------------------- REŠTART HRY -------------------------
  void reset() {
    count = 0;
    index = 0;
    rowInputs.clear();
    hurdleBoard.clear();
    excludedLetters.clear();
    attempts = 0;
    wins = false;
    targetWord = '';
    generateBoard();
    generateRandomWord();
    notifyListeners();
  }
}
