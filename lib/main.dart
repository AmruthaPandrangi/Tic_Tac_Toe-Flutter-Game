import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/InShot_20250613_104544328.png', height: 250),
            const SizedBox(height: 20),
            const Text('TIC TAC TOE',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent))
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        backgroundColor: Colors.black87,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Colors.tealAccent, Colors.cyanAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text(
            "TIC TAC TOE",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOption(context, true, Icons.person, 'Single Player'),
            const SizedBox(height: 30),
            _buildOption(context, false, Icons.group, 'Multiplayer'),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, bool isSinglePlayer, IconData icon, String text) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 190,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.tealAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: Colors.tealAccent),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScreen(isSinglePlayer: isSinglePlayer),
              ),
            ),
            child: Container(
              width: double.infinity,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.tealAccent.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool isSinglePlayer;
  const GameScreen({super.key, required this.isSinglePlayer});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  List<String> board = List.filled(9, "");
  String currentPlayer = "X";
  String winner = "";
  bool isTie = false;

  late AnimationController _controller;
  late AnimationController _dialogController;
  late Animation<double> _scaleAnimation;

  // New controller for "Let's Play!" blinking text
  late AnimationController _letsPlayController;
  late Animation<double> _letsPlayFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.bounceOut,
    ));

    _dialogController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize the Let's Play! animation
    _letsPlayController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _letsPlayFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _letsPlayController, curve: Curves.easeIn),
    );

    _letsPlayController.forward();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _letsPlayController.stop());
    });
  }

  void resetGame() {
    setState(() {
      board = List.filled(9, "");
      currentPlayer = "X";
      winner = "";
      isTie = false;
    });
  }

  void playerMove(int index) {
    if (board[index] != "" || winner != "") return;

    setState(() {
      board[index] = currentPlayer;
      checkWinner();
      if (widget.isSinglePlayer && currentPlayer == "X" && winner == "") {
        currentPlayer = "O";
        Future.delayed(const Duration(milliseconds: 300), aiMove);
      } else {
        currentPlayer = currentPlayer == "X" ? "O" : "X";
      }
    });
  }

  void aiMove() {
    List<int> emptyIndices = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == "") emptyIndices.add(i);
    }
    if (emptyIndices.isNotEmpty) {
      int randomIndex = emptyIndices[Random().nextInt(emptyIndices.length)];
      setState(() {
        board[randomIndex] = "O";
        checkWinner();
        currentPlayer = "X";
      });
    }
  }

  void checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      [0, 4, 8],
      [2, 4, 6],
    ];
    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];
      if (a != "" && a == b && b == c) {
        winner = a;
        _controller.forward(from: 0.0);
        _dialogController.forward(from: 0.0);
        return;
      }
    }
    if (!board.contains("")) {
      isTie = true;
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ScaleTransition(
          scale: _dialogController,
          child: AlertDialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Text(
              winner != "" ? "$winner Wins!" : "It's a Tie!",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, color: Colors.white),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    resetGame();
                  },
                  child: const Text("Play Again"),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(covariant GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((winner != "" || isTie) && _dialogController.status == AnimationStatus.completed) {
      Future.delayed(const Duration(milliseconds: 300), showWinDialog);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isSinglePlayer ? 'Single Player' : 'Multiplayer', style: const TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold,
      ),)),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _letsPlayFade,
            child: const Text(
              "Let's Play!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
          ),
          const SizedBox(height: 60),
          const Text("Player 1: X", style: TextStyle(fontSize: 25, color: Colors.tealAccent)),
          const Text("Player 2: O", style: TextStyle(fontSize: 25, color: Colors.orangeAccent)),
          const SizedBox(height: 10),
          if (winner != "")
            ScaleTransition(
              scale: _scaleAnimation,
              child: Text(
                '$winner Wins!',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          if (isTie && winner == "")
            const Text("It's a Tie!", style: TextStyle(fontSize: 28, color: Colors.white)),
          const SizedBox(height: 20),
          GridView.builder(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => playerMove(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(
                        fontSize: 48,
                        color: board[index] == "X" ? Colors.tealAccent : Colors.orangeAccent,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (winner != "" || isTie)
            ElevatedButton(
              onPressed: resetGame,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text("Play Again",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                   ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.refresh,
                    color: Colors.black,
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dialogController.dispose();
    _letsPlayController.dispose();
    super.dispose();
  }
}
