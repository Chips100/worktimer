import 'dart:async';
import 'package:flutter/material.dart';

/// A widget that allows the user to measure durations by starting and stopping a stopwatch.
class StopwatchWidget extends StatefulWidget {
  /// Creates a widget that allows the user to measure durations by starting and stopping a stopwatch.
  StopwatchWidget({this.startTime, this.onStart, this.onStop, DateTime Function() currentTimeProvider})
    : currentTimeProvider = (currentTimeProvider ?? () => DateTime.now());

  /// When specified, the stopwatch will start in a running state
  /// for a measurement that started at the given time.
  final DateTime startTime;

  /// Will be called when a measurement has been started,
  /// providing the start of the measurement.
  final Function(DateTime) onStart;

  /// Will be called when a measurement has been stopped, 
  /// providing the start of the measurement and the duration.
  final Function(DateTime, Duration) onStop;

  /// Can be specified to change how the current time is determined
  /// when starting or stopping a measurement (intended for faking in unit tests).
  final DateTime Function() currentTimeProvider;

  @override
  _StopwatchState createState() => _StopwatchState(startTime);
}

/// State of the StopwatchWidget.
class _StopwatchState extends State<StopwatchWidget> {
  Timer _updateTimer;
  DateTime _startTime;
  String _text;

  _StopwatchState(this._startTime);

  @override
  void initState() {
    super.initState();
    _configureTimer();
  }

  /// Indicates if the stopwatch is currently running a measurement.
  bool isRunning() => _startTime != null;

  /// Toggles the running state of the stopwatch,
  /// either starting or stopping a measurement.
  void _toggle() {
    if (isRunning()) {
      var start = _startTime;
      var duration = widget.currentTimeProvider().difference(start);
      
      _startTime = null;
      this.widget.onStop?.call(_startTime, duration);
    }
    else {
      _startTime = widget.currentTimeProvider();
      this.widget.onStart?.call(_startTime);
    }

    _configureTimer();
  }

  /// Configures the timer that updates the UI with the current measurement time.
  void _configureTimer() {
    _updateTime(); // Ensure correct display of time immediately.

    if (isRunning() && _updateTimer == null) {
      _updateTimer = Timer.periodic(new Duration(milliseconds: 500), (t) {
        _updateTime();
      });
    }
    else if (!isRunning() && _updateTimer != null) {
      _updateTimer.cancel();
      _updateTimer = null;
    }
  }

  /// Updates the UI to show the duration of the current measurement.
  void _updateTime() {
    setState(() {
      var duration = !isRunning()
        ? Duration.zero
        : widget.currentTimeProvider().difference(_startTime);
      
      var minutes = duration.inMinutes.remainder(Duration.minutesPerHour);
      var seconds = duration.inSeconds.remainder(Duration.secondsPerMinute);

      String twoDigits(int n) => n.toString().padLeft(2, "0");
      _text = "${twoDigits(duration.inHours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_text',
              style: Theme.of(context).textTheme.display3,
            ),
            RaisedButton(
              child: Text(isRunning() ? "Stop" : "Start"),
              onPressed: _toggle
            )
          ],
        ),
      );
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
