import 'package:flutter/material.dart';
import 'package:snake_game/setting_screen.dart';



class MainMenuScreen extends StatefulWidget {
  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInFadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeInFadeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 10),
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [Colors.green, Colors.black],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _fadeInFadeOut,
                    child: const Text(
                      'Snake Mania',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 4),
                            blurRadius: 15,
                            color: Colors.black38,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.1),
                  _buildAnimatedMenuButton(
                    context,
                    icon: Icons.play_arrow,
                    label: 'Play',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen()),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  _buildAnimatedMenuButton(
                    context,
                    icon: Icons.settings,
                    label: 'Settings',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  _buildAnimatedMenuButton(
                    context,
                    icon: Icons.info,
                    label: 'Info',
                    onPressed: () {
                      _showInfoDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedMenuButton(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onPressed}) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.9, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.elasticOut,
        ),
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 30, color: Colors.black),
        onPressed: onPressed,
        label: Text(label,
            style: const TextStyle(fontSize: 20, color: Colors.black)),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          backgroundColor: Colors.grey[300],
          elevation: 10,
          shadowColor: Colors.black38,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              // Adding a dynamic background with gradient
              gradient: LinearGradient(
                colors: [Colors.green, Colors.black], // Dynamic two colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info, color: Colors.yellow, size: 40),
                      SizedBox(width: 8),
                      Text(
                        'Game Information',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const ListTile(
                    leading: Icon(Icons.videogame_asset, color: Colors.white),
                    title: Text(
                      'How to Play',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Control the snake using gestures.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.developer_mode, color: Colors.white),
                    title: Text(
                      'Credits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'Developer: Muhammad Uwaim Qureshi',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.verified_user, color: Colors.white),
                    title: Text(
                      'Legal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      'All rights reserved.',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 12.0),
                      ),
                      child: const Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
