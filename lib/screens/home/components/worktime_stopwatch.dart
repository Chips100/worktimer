import 'package:flutter/material.dart';
import 'package:worktimer/screens/home/components/worktime_stopwatch_bloc.dart';

/// A widget that allows the user to measure durations by starting and stopping a stopwatch.
class WorktimeStopwatch extends StatelessWidget {
  final WorktimeStopwatchBloc bloc;

  WorktimeStopwatch(this.bloc);

  void _start() {
    this.bloc.startMeasurement();
  }
  
  void _stop() {
    this.bloc.stopMeasurement();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: StreamBuilder(
      initialData: MeasurementState.off,
      stream: bloc.measurement,
      builder: (BuildContext context, AsyncSnapshot<MeasurementState> snapshot) =>
          Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            snapshot.data.displayText,
            style: Theme.of(context).textTheme.display3,
          ),
          RaisedButton(
            child: Text(snapshot.data.isMeasuring ? "Stop" : "Start"), 
            onPressed: snapshot.data.isMeasuring ? _stop :_start)
        ],
      ),
    ));
  }
}
