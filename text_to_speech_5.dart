import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main () => runApp(MyApp());

// Create UI AppBar
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TTS Demo',
      home: MyHomePage(),
    );
  }
}

// Build the main UI: MyHomePage
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Input the text
  TextEditingController _textEditingController = TextEditingController();

  // Create Flutter Object
  final FlutterTts flutterTts = FlutterTts();

  // Declare string to store the text
  String displayedText = " ";

  // Free up unnecessary resources to help the application run smoother
  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  List<String> words = [];
  String currentWord = " ";

  int? _currentWordStart, _currentWordEnd;
  int _currentIndex = 0;
  Timer? _timer;

  List<Map> _voices = [];
  Map? _currentVoices;

  // Variable history list of text
  List<String> historyText = [];

  @override
  void initState() {
    super.initState();
    initTTS();
    flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        currentWord = word;
      });
    });
  }

  void initTTS() {
    flutterTts.getVoices.then((data) {
      try {
        _voices = List<Map>.from(data);
        setState(() {
          if (_voices.isNotEmpty) {
            _currentVoices = _voices.first;
            setVoice(_currentVoices!);
          }
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice (Map voice) {
    flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  // Display and highlight text function
  void displayAndHighlight() {
    // Display text
    displayedText = (_textEditingController.text);
    words = displayedText.split(" ");

    List<int> wordPositions = [];
    int tempIndex = 0;

    for (String word in words) {
      int pos = displayedText.indexOf(word, tempIndex);
      wordPositions.add(pos);
      tempIndex = pos + word.length;
    }

    // Identify the start and end position of each word
    _currentIndex = 0;
    _currentWordStart = null;
    _currentWordEnd = null;
    _timer?.cancel();

    _timer = Timer.periodic(Duration (milliseconds: 500), (timer){
      if (_currentIndex < words.length) {
        setState(() {
          _currentWordStart = wordPositions[_currentIndex];
          _currentWordEnd = _currentWordStart! + words[_currentIndex].length;
        });
        _currentIndex++;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          displayAndHighlight(); // Sets up text and visuals
          final text = _textEditingController.text.trim();
          if (text.isNotEmpty) {
            setState(() {
              historyText.insert(0, text); // Sử dụng đúng biến State
            });
          }
          await flutterTts.speak(text); // Starts the speech
        },
        child: const Icon(Icons.speaker_phone),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6.0,
          child: SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text("Home"),
                ),
                SizedBox(width: 40,),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryPage(historyTexts: historyText)),
                    );
                  },
                  child: Text("History"),
                ),
              ],
            ),
          )
      ),
    );
  }

  Widget _buildUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EL TTS Demo'), // Title for app bar
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => HistoryPage(historyTexts: historyText)),
              );

              if (result != null && result.trim().isNotEmpty) {
                setState(() {
                  _textEditingController.text = result;
                  displayedText = result;
                });
                words = result.split(" "); // gán thủ công nếu cần
                displayAndHighlight();
                await flutterTts.speak(result);
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textEditingController,
              decoration: const InputDecoration(labelText: 'Enter some text'),
            ),
            const SizedBox(height: 16.0,),
            _speakerSelector(),
            // _speechOption(),
            const SizedBox(height: 16.0,),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                  color: Colors.black,
                ),
                children: <TextSpan> [
                  TextSpan(
                    text: displayedText.substring(0, _currentWordStart ?? 0),
                  ),
                  if (_currentWordStart != null && _currentWordEnd != null)
                    TextSpan(
                      text: displayedText.substring(_currentWordStart!, _currentWordEnd!),
                      style: const TextStyle(
                        color: Colors.white,
                        backgroundColor: Colors.purpleAccent,
                      ),
                    ),
                  TextSpan(
                    text: displayedText.substring(_currentWordEnd ?? 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _speakerSelector() {
    return Center(
      child: DropdownButton<Map?>(
        value: _currentVoices,
        hint: Text("Select a voice"),
        items: _voices.map(
              (_voice) => DropdownMenuItem(
            value: _voice,
            child: Text(_voice['name']),
          ),
        ).toList(),
        onChanged: (value) {
          setState(() {
            _currentVoices = value;
            if (_currentVoices != null) {
              setVoice(_currentVoices!);
            }
          });
        },
      ),
    );
  }

  double _speechRate = 0.5; // Default speed

  Widget _speechOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Speech rate',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Slow'),
            Text('Fast'),
          ],
        ),
        Slider(
          value: _speechRate,
          onChanged: (newRate) {
            setState(() {
              _speechRate = newRate;
            });
            flutterTts.setSpeechRate(_speechRate);
          },
          min: 0.1,
          max: 1.0,
          divisions: 9,
          label: "${_speechRate.toStringAsFixed(1)}x",
        ),
      ],
    );
  }
}

class HistoryPage extends StatefulWidget {
  final List<String> historyTexts;

  HistoryPage({required this.historyTexts});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History")),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: widget.historyTexts.length,
        itemBuilder: (context, index, animation) {
          final item = widget.historyTexts[index];
          return SizeTransition(
              sizeFactor: animation,
            child: ListTile(
              title: Text(item),
              onTap: () {
                Navigator.pop(context, item); // Trả item về MyHomePage
              },
            ),
          );
        }
      )
    );
  }
}

