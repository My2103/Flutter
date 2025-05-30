import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({required this.title, super.key});
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56, // in logical pixels
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.lightGreen[500]),
      // Row is a horizontal, linear color
      child: Row(
        children: [
          const IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: null, // null disables the button
          ),
          // Expanded expands its child
          // to fill the available space
          Expanded(child: title),
          const IconButton(
              icon: Icon(Icons.search),
              tooltip: 'Search',
              onPressed: null,
          ),
        ],
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  void calculateBMI() {
    final heightCm = double.tryParse(_heightController.text);
    final weightKg = double.tryParse(_weightController.text);

    if (heightCm == null || weightKg == null) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Please enter correct your height and weight'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
          ),
      );
      return;
    }

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    String classification;
    if (bmi < 18.5) {
      classification = "Thin";
    } else if (bmi <= 24.9) {
      classification = "Normal";
    } else if (bmi <= 29.9) {
      classification = "Overweight";
    } else {
      classification = "Obese";
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Result"),
        content: Text('Your BMI is ${bmi.toStringAsFixed(2)}\nClassification: $classification'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          MyAppBar(
              title: Text(
                'BMI Calculator',
                style: Theme.of(context).primaryTextTheme.titleLarge,
              ),
          ),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Height (cm)'),
                    ),
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Weight (kg)'),
                    ),
                    SizedBox(height: 20,),
                    ElevatedButton(
                        onPressed: calculateBMI,
                        child: Text('Compute BMI'),
                    ),
                  ],
                )
              ),
          ),
        ]
      )
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      title: 'My app', // used by the OS task switcher
      home: SafeArea(child: MyHomePage()),
    ),
  );
}