import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({required this.title, super.key});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric (horizontal: 8),
      decoration: BoxDecoration(color: Colors.blue[500]),

      child: Row(
        children: [
          const IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: null,
          ),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _number1Controller = TextEditingController();
  final _number2Controller = TextEditingController();


  void _performCalculation(String operator) {
    final number1 = double.tryParse(_number1Controller.text);
    final number2 = double.tryParse(_number2Controller.text);


    if (number1 == null || number2 == null || operator == '') {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Please enter correct your number and operator to calculate'),
          actions: [TextButton(onPressed: () => Navigator.pop(context),                                                           child: Text('OK'))],
        ),
      );
      return;
    }

    double result;
    String errorMessage = '';

    switch (operator) {
      case '+':
        result = number1 + number2;
        break;
      case '-':
        result = number1 - number2;
        break;
      case '*':
        result = number1 * number2;
        break;
      case '/':
        if (number2 != 0) {
          result = number1 / number2;
        } else {
          result = double.nan;
          errorMessage = 'Complex Infinity';
        }
        break;
      default:
        result = double.nan;
        errorMessage = 'Operator is undefined.';
        break;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(errorMessage.isNotEmpty ? 'Error' : 'Result'),
        content: Text(
          errorMessage.isNotEmpty
              ? errorMessage
              : 'Your result is $result',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _number1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Operand 1'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _number2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Operand 2'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () => _performCalculation('+'),
                    child: const Text('+')
                ),
                ElevatedButton(
                    onPressed: () => _performCalculation('-'),
                    child: const Text('-')
                ),
                ElevatedButton(
                    onPressed: () => _performCalculation('*'),
                    child: const Text('*')
                ),
                ElevatedButton(
                    onPressed: () => _performCalculation('/'),
                    child: const Text('/')
                ),
              ],
            )
          ],
        )
      )
    );
  }
}

void main() {
  runApp(
    const MaterialApp(
      title: 'My app',
      home: SafeArea(child: MyHomePage()),
    ),
  );
}