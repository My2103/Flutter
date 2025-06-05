import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:text_speech/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  FlutterTts _flutterTts = FlutterTts();
  List<Map> _voices = [];
  Map? _currentVoices;

  int? _currentWordStart, _currentWordEnd;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    initTTS();
  }

  void initTTS() {
    _flutterTts.getVoices.then((data) {
      try {
        _voices = List<Map>.from(data);
        setState(() {
          _voices = _voices.where((_voice) => _voice["name"].contains("en")).toList();
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

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  void speakWithFakeProgress() {
    _flutterTts.speak(TTS_INPUT);
    List<String> words = TTS_INPUT.split(" ");
    List<int> wordPositions = [];
    int tempIndex = 0;

    for (String word in words) {
      int pos = TTS_INPUT.indexOf(word, tempIndex);
      wordPositions.add(pos);
      tempIndex = pos + word.length;
    }

    _currentIndex = 0;
    _timer?.cancel();

    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
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
        onPressed: speakWithFakeProgress,
        child: const Icon(Icons.speaker_phone),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _speakerSelector(),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 20,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: TTS_INPUT.substring(0, _currentWordStart ?? 0),
                ),
                if (_currentWordStart != null && _currentWordEnd != null)
                  TextSpan(
                    text: TTS_INPUT.substring(_currentWordStart!, _currentWordEnd!),
                    style: const TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.purpleAccent,
                    ),
                  ),
                TextSpan(
                  text: TTS_INPUT.substring(_currentWordEnd ?? 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _speakerSelector() {
    return DropdownButton<Map?>(
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
    );
  }
}
