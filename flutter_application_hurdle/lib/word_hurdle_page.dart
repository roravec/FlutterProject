import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'hurdle_provider.dart';
import 'keyboard_view.dart';
import 'wordle_view.dart';

// Stav hry drží HurdleProvider, preto stránka môže byť StatelessWidget
// – UI sa prekresľuje cez notifyListeners() a Consumer.
class WordHurdlePage extends StatelessWidget {
  const WordHurdlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Hurdle'),
        centerTitle: true,
        actions: [
          // Reštart hry bez reštartu celej aplikácie
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                Provider.of<HurdleProvider>(context, listen: false).reset(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Consumer<HurdleProvider>(
              builder: (context, provider, child) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Attempts: ${provider.attempts}/${provider.totalAttempts}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            // Expanded zabezpečí, že GridView zaberie dostupný priestor
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.70,
                child: Consumer<HurdleProvider>(
                  builder: (context, provider, child) => GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: provider.hurdleBoard.length,
                    itemBuilder: (context, index) {
                      final wordle = provider.hurdleBoard[index];
                      return WordleView(wordle: wordle);
                    },
                  ),
                ),
              ),
            ),
            Consumer<HurdleProvider>(
              builder: (context, provider, child) => KeyboardView(
                excludedLetters: provider.excludedLetters,
                onPressed: (value) {
                  provider.inputLetter(value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<HurdleProvider>(
                builder: (context, provider, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        provider.deleteLetter();
                      },
                      child: const Text('DELETE'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _handleInput(context, provider);
                      },
                      child: const Text('SUBMIT'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleInput(BuildContext context, HurdleProvider provider) {
    // Po skončení hry sa už nič nevyhodnocuje
    if (provider.isGameOver) {
      showMsg(context, 'Game over – start a new game');
      return;
    }

    // Kontrola, či je zadaných všetkých 5 písmen
    if (!provider.shouldCheckForAnswer) {
      showMsg(context, 'Not enough letters');
      return;
    }

    // Overenie platnosti slova
    if (!provider.isValidWord) {
      showMsg(context, 'Not a word in my dictionary');
      return;
    }

    provider.checkAnswer();

    // Výhra – zhoduje sa s targetWord
    if (provider.wins) {
      showResult(
        context: context,
        title: 'You Win!!!',
        body: 'The word was ${provider.targetWord}',
        onPlayAgain: () {
          Navigator.pop(context);
          provider.reset();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      );
      // Prehra – pokusy sú vyčerpané
    } else if (provider.noAttemptsLeft) {
      showResult(
        context: context,
        title: 'You lost!!',
        body: 'The word was ${provider.targetWord}',
        onPlayAgain: () {
          Navigator.pop(context);
          provider.reset();
        },
        onCancel: () {
          Navigator.pop(context);
        },
      );
    }
  }
}
