import 'package:flutter_test/flutter_test.dart';
import 'package:worktimer/stopwatch/stopwatch_widget.dart';
import '../test_utils.dart';

void main() {
  testWidgets('Stopwatch starts smoke test', (WidgetTester tester) async {
    var fakeStartTime = DateTime.now();
    var fakeCurrentTime = fakeStartTime;
    DateTime startedTime;

    await pumpTestWidget(tester, StopwatchWidget(
      // Fake the current time used when starting and stopping the stopwatch.
      currentTimeProvider: () => fakeCurrentTime,
      onStart: (start) { startedTime = start; },
    ));

    // Verify that our stopwatch starts in a stopped state (displaying 00:00:00).
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Stop'), findsNothing);

    // Tap the Start button and trigger a frame.
    await tester.tap(find.text('Start'));

    // Jump forward in time for an elapsed second.
    var waitDuration = new Duration(milliseconds: 1001);
    fakeCurrentTime = fakeCurrentTime.add(waitDuration);
    await tester.pump(waitDuration);

    // Verify that the stopwatch measured a second.
    //expect(find.text('00:00:01'), findsOneWidget);
    expect(find.text('00:00:01'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Start'), findsNothing);

    // Verify that the stopwatch notified about the started measurement by "onStart".
    expect(startedTime, equals(fakeStartTime));
  });
  
  testWidgets('Stopwatch starts and stops smoke test', (WidgetTester tester) async {
    var fakeCurrentTime = DateTime.now();
    var measuredDuration = Duration.zero;

    await pumpTestWidget(tester, StopwatchWidget(
      // Fake the current time used when starting and stopping the stopwatch.
      currentTimeProvider: () => fakeCurrentTime,
      onStop: (start, duration) { measuredDuration = duration; },
    ));

    // Tap the start button and wait for 04:30:20.
    await tester.tap(find.text('Start'));
    var waitDuration = new Duration(hours: 4, minutes: 30, seconds: 20, milliseconds: 1);
    fakeCurrentTime = fakeCurrentTime.add(waitDuration);
    await tester.pump(waitDuration);

    // Check current stopwatch display and stop measurement.
    expect(find.text('04:30:20'), findsOneWidget);
    await tester.tap(find.text('Stop'));
    await tester.pump();
    
    // Verify the notification from the stopwatch provided by "onStop".
    expect(find.text('00:00:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(measuredDuration, equals(waitDuration));
  });

  testWidgets('Stopwatch can be recreated in a running state', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await pumpTestWidget(tester, StopwatchWidget(
      // Tell the stopwatch to resume a measurement startet 01:30:20 ago.
      startTime: DateTime.now().add(-Duration(hours: 1, minutes: 30, seconds: 20))
    ));
    
    await tester.pump();

    // Verify that our stopwatch starts in a running state (displaying 01:30:20).
    expect(find.text('01:30:20'), findsOneWidget);
    expect(find.text('Stop'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });
}
