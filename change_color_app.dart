import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MaterialApp(title: 'Change Color Background', home: ChangeBackground(initialColor: Colors.white)));
}

class ChangeBackground extends StatefulWidget {
  final Color initialColor;

  const ChangeBackground({super.key, required this.initialColor});

  @override
  State<ChangeBackground> createState() => _ChangeBackground();
}

class _ChangeBackground extends State<ChangeBackground> {
  late Color baseColor;
  late Color darkerColor;

  @override
  void initState() {
    super.initState();
    baseColor = widget.initialColor;
    darkerColor = _generateDarkerColor(baseColor);
  }

  Color _generateRandomColor() {
    return Color.fromARGB(
      255,
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
    );
  }

  Color _generateDarkerColor(Color color) {
    return Color.fromARGB(
      color.alpha,
      (color.red * 0.7).toInt().clamp(0, 255),
      (color.green * 0.7).toInt().clamp(0, 255),
      (color.blue * 0.7).toInt().clamp(0, 255),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold is a layout for
    // the major Material Components.
    return Scaffold(
      backgroundColor: baseColor,
      appBar: AppBar(
        backgroundColor: darkerColor,
        leading: const IconButton(
          icon: Icon(Icons.menu),
          tooltip: 'Navigation menu',
          onPressed: null,
        ),
        title: const Text('Change Color'),
        actions: const [
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: null,
          ),
        ],
      ),
      // body is the majority of the screen.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      baseColor = _generateRandomColor();
                      darkerColor = _generateDarkerColor(baseColor);
                    });
                  },
                  child: const Text('Click here to change the color!'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
