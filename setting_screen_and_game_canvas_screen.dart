import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _vibration = true;
  String _difficulty = 'Normal';
  String _snakeColor = 'Green';
  String _foodColor = 'Red';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibration = prefs.getBool('vibration') ?? true;
      _difficulty = prefs.getString('difficulty') ?? 'Normal';
      _snakeColor = prefs.getString('snakeColor') ?? 'Green';
      _foodColor = prefs.getString('foodColor') ?? 'Red';
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('vibration', _vibration);
    prefs.setString('difficulty', _difficulty);
    prefs.setString('snakeColor', _snakeColor);
    prefs.setString('foodColor', _foodColor);

    final gameState = context.findAncestorStateOfType<_GameScreenState>();
    if (gameState != null) {
      gameState.updateGameSettings(_difficulty);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.green,
        elevation: 6,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Gradient background with a blur effect
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                _buildSettingSwitch(
                  'Vibration On/Off',
                  _vibration,
                      (value) {
                    setState(() {
                      _vibration = value;
                    });
                  },
                  icon: Icons.vibration,
                ),
                const SizedBox(height: 20),
                _buildSettingDropdown(
                  'Difficulty',
                  _difficulty,
                  ['Easy', 'Normal', 'Hard'],
                      (newValue) {
                    setState(() {
                      _difficulty = newValue!;
                    });
                  },
                  icon: Icons.tune,
                ),
                const SizedBox(height: 20),
                _buildSettingDropdown(
                  'Snake Color',
                  _snakeColor,
                  ['Green', 'Blue', 'Yellow'],
                      (newValue) {
                    setState(() {
                      _snakeColor = newValue!;
                    });
                  },
                  icon: Icons.color_lens,
                ),
                const SizedBox(height: 20),
                _buildSettingDropdown(
                  'Food Color',
                  _foodColor,
                  ['Red', 'Purple', 'Orange'],
                      (newValue) {
                    setState(() {
                      _foodColor = newValue!;
                    });
                  },
                  icon: Icons.fastfood,
                ),
                const SizedBox(height: 40),
                _buildSaveButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
      String title, bool value, ValueChanged<bool> onChanged,
      {required IconData icon}) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8, // Shadow effect
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
          inactiveTrackColor: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingDropdown(
      String title, String currentValue, List<String> options,
      ValueChanged<String?> onChanged,
      {required IconData icon}) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8, // Shadow effect
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        trailing: DropdownButton<String>(
          value: currentValue,
          dropdownColor: Colors.black,
          style: const TextStyle(color: Colors.white, fontSize: 18),
          iconEnabledColor: Colors.green,
          items: options.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveSettings,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.green,
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 8, // Adds shadow
      ),
      child: const Text('Save Settings'),
    );
  }
}
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<Offset> snake = [];
  Offset food = const Offset(5, 5);
  String direction = 'up';
  bool gameOver = false;
  Timer? gameTimer;
  int score = 0;
  int highScore = 0;
  late double boardWidth;
  late double boardHeight;
  int rows = 20;
  int columns = 20;
  final int squareSize = 20;
  final int foodSize = 50;
  bool isPaused = false;
  int speed = 300;

  bool vibrationEnabled = true;
  String snakeColor = 'Green';
  String foodColor = 'Red';

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _loadGameSettings();
    startGame();
  }

  void _loadGameSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      vibrationEnabled = prefs.getBool('vibration') ?? true;
      String difficulty = prefs.getString('difficulty') ?? 'Normal';
      snakeColor = prefs.getString('snakeColor') ?? 'Green';
      foodColor = prefs.getString('foodColor') ?? 'Red';

      _updateSpeed(difficulty);
    });
  }

  void _updateSpeed(String difficulty) {
    setState(() {
      switch (difficulty) {
        case 'Easy':
          speed = 400;
          break;
        case 'Normal':
          speed = 300;
          break;
        case 'Hard':
          speed = 100;
          break;
      }
      _restartTimer();
    });
  }

  void startGame() {
    snake = [
      const Offset(10, 10),
      const Offset(10, 11),
      const Offset(10, 12),
    ];
    food = getRandomFoodPosition();
    direction = 'up';
    gameOver = false;
    score = 0;
    isPaused = false;
    _restartTimer();
  }

  void _restartTimer() {
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(milliseconds: speed), (timer) {
      if (!isPaused) {
        setState(() {
          moveSnake();
          checkGameOver();
        });
      }
    });
  }

  Offset getRandomFoodPosition() {
    Random random = Random();
    int foodX;
    int foodY;

    do {
      foodX = random.nextInt(columns);
      foodY = random.nextInt(rows);
    } while (snake.contains(Offset(foodX.toDouble(), foodY.toDouble())));

    return Offset(foodX.toDouble(), foodY.toDouble());
  }

  void moveSnake() {
    Offset newHead = snake.first;

    switch (direction) {
      case 'up':
        newHead = Offset(newHead.dx, newHead.dy - 1);
        break;
      case 'down':
        newHead = Offset(newHead.dx, newHead.dy + 1);
        break;
      case 'left':
        newHead = Offset(newHead.dx - 1, newHead.dy);
        break;
      case 'right':
        newHead = Offset(newHead.dx + 1, newHead.dy);
        break;
    }

    newHead = Offset(
      (newHead.dx + columns) % columns,
      (newHead.dy + rows) % rows,
    );

    snake.insert(0, newHead);

    if (newHead == food) {
      food = getRandomFoodPosition();
      score += 10;

      if (vibrationEnabled) {
        Vibration.vibrate();
      }

      if (score > highScore) {
        highScore = score;
        _saveHighScore();
      }
    } else {
      snake.removeLast();
    }
  }

  void checkGameOver() {
    Offset head = snake.first;
    for (int i = 1; i < snake.length; i++) {
      if (snake[i] == head) {
        endGame();
        break;
      }
    }
  }

  void endGame() {
    gameTimer?.cancel();
    setState(() {
      gameOver = true;
    });
    showGameOverDialog();
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 10,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Score: $score',
                  style: const TextStyle(fontSize: 24, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  'High Score: $highScore',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                _buildDialogButton(
                  label: 'Restart',
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                    startGame();
                  },
                ),
                const SizedBox(height: 10),
                _buildDialogButton(
                  label: 'Main Menu',
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void updateGameSettings(String difficulty) {
    _updateSpeed(difficulty);
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('highScore', highScore);
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snake Mania', style: const TextStyle(fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                isPaused = !isPaused;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Score: $score', style: const TextStyle(fontSize: 16)),
                Text('High Score: $highScore', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          boardWidth = constraints.maxWidth;
          boardHeight = constraints.maxHeight;
          columns = (boardWidth / squareSize).floor();
          rows = (boardHeight / squareSize).floor();

          return GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta! < 0 && direction != 'down') {
                direction = 'up';
              } else if (details.primaryDelta! > 0 && direction != 'up') {
                direction = 'down';
              }
            },
            onHorizontalDragUpdate: (details) {
              if (details.primaryDelta! < 0 && direction != 'right') {
                direction = 'left';
              } else if (details.primaryDelta! > 0 && direction != 'left') {
                direction = 'right';
              }
            },
            child: Stack(
              children: [
                buildGameBoard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildGameBoard() {
    return Expanded(
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(rows, (y) {
            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(columns, (x) {
                  Offset position = Offset(x.toDouble(), y.toDouble());

                  // Set the color of the snake head to constant grey
                  if (snake.isNotEmpty && position == snake.first) {
                    return Expanded(child: buildSquare(Colors.grey, squareSize)); // Snake head is grey
                  } else if (snake.contains(position)) {
                    return Expanded(child: buildSquare(
                        snakeColor == 'Green' ? Colors.lightGreen : snakeColor == 'Blue' ? Colors.blue : Colors.yellow,
                        squareSize));
                  } else if (position == food) {
                    return Expanded(child: buildSquare(
                        foodColor == 'Red' ? Colors.red : foodColor == 'Purple' ? Colors.purple : Colors.orange,
                        foodSize)); // Food square with dynamic color
                  } else {
                    return Expanded(child: buildSquare(Colors.black, squareSize));
                  }
                }),
              ),
            );
          }),
        ),
      ),
    );
  }


  Widget buildSquare(Color color, int size) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      width: size.toDouble(),
      height: size.toDouble(),
    );
  }
}
