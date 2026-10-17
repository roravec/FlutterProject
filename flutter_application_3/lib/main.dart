import 'package:flutter/material.dart';
import 'dart:math';

final randomizer = Random();

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DiceRoller(),
  ));
}

class DiceRoller extends StatefulWidget {
  const DiceRoller({super.key});

  @override
  State<DiceRoller> createState() => _DiceRollerState();
}

class _DiceRollerState extends State<DiceRoller> {
  var currentDiceRoll = 1;

  void rollDice() {
    setState(() {
      currentDiceRoll = randomizer.nextInt(6) + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/dice-$currentDiceRoll.png',
              width: 200,
            ),
            const SizedBox(height: 20),
            Text(
              'Hodené číslo: $currentDiceRoll',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: rollDice,
              child: const Text('Hoď kockou'),
            ),
          ],
        ),
      ),
    );
  }
}
