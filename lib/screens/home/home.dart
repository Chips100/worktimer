import 'package:flutter/material.dart';
import 'package:worktimer/screens/home/components/worktime_stopwatch_bloc.dart';

import 'components/worktime_stopwatch.dart';

class Home extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Stopwatch"),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: WorktimeStopwatch(
            // TODO: Some kind of BLOC Provider.
            WorktimeStopwatchBloc(
              Stream.periodic(Duration(milliseconds: 250)), () => DateTime.now())),
        ) // This trailing comma makes auto-formatting nicer for build methods.
      );
  }
}
