import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({required this.title, required this.backgroundColor, super.key});

  // Fields in a Widget subclass are always marked "final".

  final Widget title;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: backgroundColor),
      // Row is a horizontal, linear layout.
      child: Row(
        children: [
          const IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: null, // null disables the button
          ),
          // Expanded expands its child
          // to fill the available space.
          Expanded(child: title),
          const IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed: null,
          ),
        ],
      ),
    );
  }
}

class MyScaffold extends StatefulWidget {
  final Color initialColor;
  
  const MyScaffold({super.key, required this.initialColor});

  @override
  State<MyScaffold> createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  late Color baseColor;
  late Color darkerColor;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    baseColor = widget.initialColor;
    darkerColor = _generateDarkerColor(baseColor);

    _loadPreferences();
  }

  bool isPrefsReady = false;

  Future<void> _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();

    int? savedColor = prefs.getInt("backgroundColor");
    int? savedAppBarColor = prefs.getInt("appBarColor");

    if (savedColor != null && savedAppBarColor != null) {
      setState(() {
        baseColor = Color(savedColor);
        darkerColor = _generateDarkerColor(baseColor);
      });
    }
  }

  Color _generateRandomColor(Color color) {
    return Color.fromARGB(
        255,
        128 + Random().nextInt(128),
        128 + Random().nextInt(128),
        128 + Random().nextInt(128),
    );
  }

  Color _generateDarkerColor(Color color) {
    return Color.fromARGB(
        255,
        (color.red * 0.5).toInt().clamp(0, 255),
        (color.green * 0.5).toInt().clamp(0, 255),
        (color.blue * 0.5).toInt().clamp(0, 255),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      color: baseColor,
      // Column is a vertical, linear layout.
      child: Column(
        children: [
          MyAppBar(
            backgroundColor: darkerColor,
            title: Text(
              'Change Background',
              style:
              Theme.of(context) //
                  .primaryTextTheme
                  .titleLarge,
            ),
          ),
          Expanded(
              child: Center(
                  child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          baseColor = _generateRandomColor(baseColor);
                          darkerColor = _generateDarkerColor(baseColor);

                          if (isPrefsReady) {
                            prefs.setInt("backgroundColor", baseColor.value);
                            prefs.setInt("appBarColor", darkerColor.value);
                          }
                        });
                      },
                      child: const Text('Click here to change the color!'),
                  ),
              )
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      title: 'My app', // used by the OS task switcher
      home: SafeArea(child: MyScaffold(initialColor: Colors.white,)),
    ),
  );
}