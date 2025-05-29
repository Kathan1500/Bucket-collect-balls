import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(BucketCollectBallsGame());
}

class BucketCollectBallsGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bucket Collect Balls',
      home: GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const double bucketWidth = 130;
  static const double bucketHeight = 100;
  static const double ballRadius = 13;

  double bucketX = 0;
  late double bucketY;
  double screenWidth = 0;
  double screenHeight = 0;
  int score = 0;
  int missed = 0;
  int highScore = 0;
  List<int> topScores = [];
  bool gameRunning = false;
  bool showStartButton = false;
  bool gameOverDialogShown = false;
  List<Ball> balls = [];
  late Timer gameTimer;
  Random rng = Random();
  String playerName = "";
  bool gotPlayerName = false;

  // For stable dragging
  double panStartX = 0.0;
  double bucketStartX = 0.0;

  @override
  void initState() {
    super.initState();
    _loadHighScores();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askPlayerName();
    });
  }

  void _askPlayerName() async {
    String? enteredName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        String tempName = "";
        return AlertDialog(
          title: Text('Enter your name'),
          content: TextField(
            autofocus: true,
            onChanged: (v) => tempName = v,
            decoration: InputDecoration(hintText: "Player Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (tempName.trim().isNotEmpty) {
                  Navigator.of(ctx).pop(tempName.trim());
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    if (enteredName != null && enteredName.isNotEmpty) {
      setState(() {
        playerName = enteredName;
        gotPlayerName = true;
        showStartButton = true;
      });
    }
  }

  void _loadHighScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      topScores = (prefs.getStringList('topScores') ?? []).map(int.parse).toList();
      if (topScores.isNotEmpty) {
        highScore = topScores.first;
      }
    });
  }

  void _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    topScores.add(score);
    topScores.sort((a, b) => b.compareTo(a));
    if (topScores.length > 5) topScores = topScores.sublist(0, 5);
    await prefs.setStringList('topScores', topScores.map((e) => e.toString()).toList());
    setState(() {
      highScore = topScores.first;
    });
  }

  void _startGame() {
    setState(() {
      bucketX = screenWidth / 2 - bucketWidth / 2;
      bucketY = screenHeight * 0.80;
      score = 0;
      missed = 0;
      balls = [];
      gameRunning = true;
      gameOverDialogShown = false;
      showStartButton = false;
    });
    _spawnBall();
    gameTimer = Timer.periodic(Duration(milliseconds: 13), (_) => _gameLoop());
  }

  void _spawnBall() {
    double x = rng.nextDouble() * (screenWidth - ballRadius * 2);
    balls.add(Ball(x: x, y: -ballRadius * 2));
  }

  void _gameLoop() {
    if (!gameRunning) return;
    setState(() {
      for (var ball in balls) {
        ball.y += 2.0;
      }
      List<Ball> toRemove = [];
      for (var ball in balls) {
        if (ball.y + ballRadius >= screenHeight) {
          missed++;
          toRemove.add(ball);
          if (missed >= 3 && !gameOverDialogShown) {
            _onGameOver();
          }
        }
        // More forgiving collision
        else if (
        ball.x + ballRadius > bucketX - 12 &&
            ball.x < bucketX + bucketWidth + 12 &&
            ball.y + ballRadius > bucketY - 16 &&
            ball.y < bucketY + bucketHeight + 18
        ) {
          score++;
          toRemove.add(ball);
        }
      }
      balls.removeWhere((b) => toRemove.contains(b));
      if (balls.isEmpty || rng.nextDouble() < 0.03) {
        _spawnBall();
      }
    });
  }

  void _onGameOver() async {
    setState(() {
      gameRunning = false;
      gameOverDialogShown = true;
    });
    _saveHighScore(score);
    gameTimer.cancel();
    await Future.delayed(Duration(milliseconds: 400));
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.grey.shade100,
        title: Text("Game Over", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("$playerName's Score: $score", style: TextStyle(fontSize: 22)),
            SizedBox(height: 12),
            Text("Leaderboard", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...topScores.take(5).map((s) => Text("$s")),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade50,
              foregroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _startGame();
            },
            child: Text("Restart"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (gameRunning) gameTimer.cancel();
    super.dispose();
  }

  // Stable and responsive dragging!
  void _onPanStart(DragStartDetails details) {
    panStartX = details.localPosition.dx;
    bucketStartX = bucketX;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      double delta = details.localPosition.dx - panStartX;
      bucketX = (bucketStartX + delta).clamp(0.0, screenWidth - bucketWidth);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    // You can add animation or inertia here if you want
  }

  // Tap-to-move bucket (optional, but feels great on mobile)
  void _onTapDown(TapDownDetails details) {
    setState(() {
      double newX = details.localPosition.dx - bucketWidth / 2;
      bucketX = newX.clamp(0.0, screenWidth - bucketWidth);
    });
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      if (screenWidth != size.width || screenHeight != size.height) {
        setState(() {
          screenWidth = size.width;
          screenHeight = size.height;
          bucketY = screenHeight * 0.80;
        });
      }
    });

    return Scaffold(
      body: screenWidth == 0
          ? Container()
          : SafeArea(
        child: Stack(
          children: [
            // Beautiful gradient background
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffd3cce3), Color(0xff2b5876)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Tap-to-move (invisible layer)
            if (gameRunning)
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  behavior: HitTestBehavior.translucent,
                  child: Container(color: Colors.transparent),
                ),
              ),
            // Scoreboard
            Positioned(
              left: 24,
              top: 24,
              child: Text(
                "Score: $score",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple),
              ),
            ),
            Positioned(
              left: 180,
              top: 24,
              child: Text(
                "Missed: $missed",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: ElevatedButton(
                onPressed: () {
                  _startGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text("Restart", style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
            ),
            // Balls
            ...balls.map(
                  (ball) => Positioned(
                left: ball.x,
                top: ball.y,
                child: Container(
                  width: ballRadius * 2,
                  height: ballRadius * 2,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.redAccent.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2)
                    ],
                  ),
                ),
              ),
            ),
            // Responsive bucket!
            Positioned(
              left: bucketX,
              top: bucketY,
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: SizedBox(
                  width: bucketWidth,
                  height: bucketHeight,
                  child: CustomPaint(
                    painter: CartoonBucketPainter(),
                  ),
                ),
              ),
            ),
            // Start Button overlay (after player name entered)
            if (showStartButton)
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                    backgroundColor: Colors.green,
                  ),
                  child: Text("Start Game", style: TextStyle(fontSize: 28, color: Colors.white)),
                  onPressed: _startGame,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Ball {
  double x;
  double y;
  Ball({required this.x, required this.y});
}

class CartoonBucketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bucket = Paint()
      ..color = Color(0xffab47bc)
      ..style = PaintingStyle.fill;
    final rim = Paint()
      ..color = Color(0xffe1bee7)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.deepPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Draw bucket base
    var rect = Rect.fromLTWH(0, size.height * 0.18, size.width, size.height * 0.70);
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        bucket);
    canvas.drawRRect(
        RRect.fromRectAndCorners(rect,
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        stroke);
    // Draw rim
    canvas.drawOval(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.32), rim);
    canvas.drawOval(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.32), stroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
