import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool oTurn = true;
  List<String> displayXO = ['','','','','','','','',''];
  List<int> matchedIndexes = [];
  int oScore = 0;
  int xScore = 0;
  int filledBoxes = 0;
  int attempts = 0;
  String resultDeclaration = '';
  bool winnerFound = false;
  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(
      Duration(seconds: 1),
      (_) {
        setState(() {
          if (seconds > 0) {
            seconds--;
          } else {
            stopTimer();
          }
        });
      }
    );
  }
  void stopTimer () {
    resetTimer();
    timer?.cancel();
  }
  void resetTimer() {
    seconds = maxSeconds;
  }
  void resetScoreboard() {
    setState(() {
      xScore = 0;
      oScore = 0;
    });
  }
  static var customFontWhite = GoogleFonts.coiny(
    textStyle: TextStyle(
      color: Colors.white,
      letterSpacing: 3,
      fontSize: 20,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColor.primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded( // player o x
              flex: 1,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Player O', style: customFontWhite,),
                        Text(oScore.toString(), style: customFontWhite,)
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Player X', style: customFontWhite,),
                        Text(xScore.toString(), style: customFontWhite,)
                      ],
                    ),
                  ],
                ),
              )
            ),
            Expanded( // 9 box 
              flex: 4,
              child: GridView.builder(
                itemCount: 9,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _tapped(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          width: 5,
                          color: MainColor.primaryColor,
                        ),
                        
                        color: matchedIndexes.contains(index) 
                        ? MainColor.accentColor 
                        : MainColor.secondaryColor
                      ),
                      child: Center(
                        child: Text(
                          displayXO[index],
                          style: GoogleFonts.coiny(
                            textStyle : TextStyle(
                              fontSize: 64, 
                              color: MainColor.primaryColor
                            )
                          ),
                        )
                      ),
                    ),
                  );
                },
              )
            ),
            Expanded( // button + timer
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      resultDeclaration, 
                      style: customFontWhite
                    ),
                    SizedBox(height: 15),
                    _buildTimer(),
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
  void _tapped(int index) {
    final isRunning = timer == null ? false : timer!.isActive;
    if (isRunning) {
      setState(() {
        if (oTurn && displayXO[index] == '') {
          displayXO[index] = 'O';
          filledBoxes++;
          oTurn = !oTurn;
        } else if (!oTurn && displayXO[index] == '') {
          displayXO[index] = 'X';
          filledBoxes++;
          oTurn = !oTurn;
        }
        _checkWinner();
      });
    }
  }

  void _checkWinner() {
    List<List<int>> winningCombinations = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [6, 4, 2],
    ];
    for (var combination in winningCombinations) {
      int index1 = combination[0];
      int index2 = combination[1];
      int index3 = combination[2];

      String value1 = displayXO[index1];
      String value2 = displayXO[index2];
      String value3 = displayXO[index3];

      if (value1 == value2 && value1 == value3 && value1 != '') {
        setState(() {
          resultDeclaration = 'Player $value1 Menang!';
          matchedIndexes.addAll(combination);
          stopTimer();
          _updateScore(value1);
        });
        return;
      }
    }
      if (!winnerFound && filledBoxes == 9) {
        setState(() {
          resultDeclaration = 'Tidak Ada Pemenang';
          stopTimer();
        });
      }
  }
  void _updateScore (String winner) {
    if(winner == 'O') {
      oScore++;
    } else if( winner == 'X') {
      xScore++;
    }
  }
  void _clearBoard () {
    setState(() {
      for (int i = 0; i < 9; i++) {
        displayXO[i] = '';
      }
      resultDeclaration = '';
    });
    filledBoxes = 0;
    matchedIndexes = [];
  }
  Widget _buildTimer() {
    final isRunning = timer == null ? false : timer!.isActive;
    return isRunning 
    ? SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1 - seconds / maxSeconds,
            valueColor: AlwaysStoppedAnimation(Colors.white),
            strokeWidth: 8,
            backgroundColor: MainColor.accentColor,
          ),
          Center(
            child: Text(
              '$seconds', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.white, 
                fontSize: 50
              ),
            )
          ),
        ],
      ),
    )
    : 
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container( // start game button
          margin: EdgeInsets.all(8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16
              )
            ),
            onPressed: () {
              startTimer();
              _clearBoard();
              attempts++;
            }, 
            child: Text(
              attempts == 0 ? 'Mulai' : 'Main Lagi', 
              style: TextStyle(
                fontSize: 20, 
                color: Colors.black
              )
            )
          ),
        ),
        SizedBox(width: 16),
        if (xScore != 0 || oScore != 0) ...[
        Container( // reset scoreboard button
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16
            )
            ),
            onPressed: () {
              resetScoreboard();
              _clearBoard();
              setState(() {
                attempts = 0;
              });
            },
            child: Text(
              'Reset',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        SizedBox(width: 16),
        ],
      ],
    );
  }
}
