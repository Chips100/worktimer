import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:worktimer/screens/home/components/worktime_stopwatch_bloc.dart';

void main() {
  StreamController<void> fakeTickSource;
  
  setUp(() {
    fakeTickSource = StreamController<void>(sync: true);
  });

  test('WorktimeStopwatchBloc starts measurement and updates its stopwatch state.', () {
    var fakeCurrentTime = DateTime.now();
    var sut = WorktimeStopwatchBloc(
      fakeTickSource.stream,
      () => fakeCurrentTime);

    // Start measurement, jump forward 1 second and trigger update.
    sut.startMeasurement();
    fakeCurrentTime = fakeCurrentTime.add(Duration(seconds: 1));
    fakeTickSource.add(null);

    // First event is immediately sent after starting to signalize running state.
    expectLater(sut.measurement, emitsInOrder([
      MeasurementState.running(Duration.zero),
      MeasurementState.running(Duration(seconds: 1))
    ]));
  });
  
  test('WorktimeStopwatchBloc surpresses updates that do not change the stopwatch state (because of its second-precision).', () {
    var fakeCurrentTime = DateTime.now();
    var sut = WorktimeStopwatchBloc(
      fakeTickSource.stream,
      () => fakeCurrentTime);

    // Start measurement, jump forward 1 second and trigger update.
    sut.startMeasurement();
    fakeCurrentTime = fakeCurrentTime.add(Duration(seconds: 1));
    fakeTickSource.add(null);
    
    // Jump forward half a second - does not change the stopwatch state.
    fakeCurrentTime = fakeCurrentTime.add(Duration(milliseconds: 500));
    fakeTickSource.add(null);

    // Expect only one update (after the immediate one after starting).
    sut.measurement.skip(1).listen(expectAsync1((_) { }, max: 1));
  });

  test('WorktimeStopwatchBloc starts and stops a measurement and updates its state inbetween.', () {
    var fakeCurrentTime = DateTime.now();
    var sut = WorktimeStopwatchBloc(
      fakeTickSource.stream,
      () => fakeCurrentTime);

    // Start measurement, jump forward 1 second and trigger update.
    sut.startMeasurement();
    fakeCurrentTime = fakeCurrentTime.add(Duration(seconds: 1));
    fakeTickSource.add(null);

    // Start measurement, jump forward 1 hour and trigger update.
    fakeCurrentTime = fakeCurrentTime.add(Duration(hours: 1));
    fakeTickSource.add(null);

    // Stop measurement.
    sut.stopMeasurement();

    // First event is immediately sent after starting to signalize running state.
    expectLater(sut.measurement, emitsInOrder([
      MeasurementState.running(Duration.zero),
      MeasurementState.running(Duration(seconds: 1)),
      MeasurementState.running(Duration(hours: 1, seconds: 1)),
      MeasurementState.off
    ]));
  });

  test('MeasurementState reduces the measured durations to second-precision.', () {
    var sut = MeasurementState.running(Duration(seconds: 5, milliseconds: 800));
    expect(sut.measuredDuration, equals(Duration(seconds: 5)));
  });

  test('MeasurementState provides a display value for the stopwatch.', () {
    var sut = MeasurementState.running(Duration(hours: 4, minutes: 15, seconds: 22));
    expect(sut.displayText, equals('04:15:22'));
  });

  tearDown(() {
    fakeTickSource.close();
  });
}
