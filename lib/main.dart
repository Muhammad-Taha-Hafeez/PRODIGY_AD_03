import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stopwatch App',
      theme: ThemeData(
        brightness: Brightness.light,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.tealAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: StopwatchPage(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  final void Function() toggleTheme;
  final bool isDarkMode;

  StopwatchPage({required this.toggleTheme, required this.isDarkMode});

  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage>
    with SingleTickerProviderStateMixin {
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  List<String> _laps = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startStopwatch() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
        setState(() {});
      });
    }
  }

  void _pauseStopwatch() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer.cancel();
    }
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {
      _laps.clear();
    });
  }

  void _lapStopwatch() {
    setState(() {
      _laps.add(_formattedTime);
    });
  }

  void _deleteLap(int index) {
    setState(() {
      _laps.removeAt(index);
    });
  }

  String get _formattedTime {
    final int milliseconds = _stopwatch.elapsedMilliseconds;
    final int seconds = milliseconds ~/ 1000;
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final int remainingMilliseconds = milliseconds % 1000;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${remainingSeconds.toString().padLeft(2, '0')}:'
        '${(remainingMilliseconds / 10).toStringAsFixed(0).padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[600],
        actions: [
          IconButton(
            icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.toggleTheme,
            color: Colors.white,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'Stopwatch',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          SizedBox(height: 40),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: _stopwatch.isRunning
                        ? (_stopwatch.elapsedMilliseconds % 1000) / 1000.0
                        : 0.0,
                    strokeWidth: 6.0,
                  ),
                ),
                Text(
                  _formattedTime,
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _laps.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: ListTile(
                    title: Text('Lap ${index + 1}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_laps[index]),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteLap(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              onPressed:
              _stopwatch.isRunning ? _pauseStopwatch : _startStopwatch,
              child:
              Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow),
            ),
            FloatingActionButton(
              onPressed: _resetStopwatch,
              child: Icon(Icons.stop),
            ),
            FloatingActionButton(
              onPressed: _lapStopwatch,
              child: Icon(Icons.flag),
            ),
          ],
        ),
      ),
    );
  }
}
