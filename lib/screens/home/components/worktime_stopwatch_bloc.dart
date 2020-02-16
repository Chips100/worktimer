import 'dart:async';

/// Implements business logic for measuring worktime with a stopwatch.
class WorktimeStopwatchBloc {
  //ignore: close_sinks
  final StreamController<MeasurementState> _measurement = StreamController<MeasurementState>();
  //ignore: cancel_subscriptions
  StreamSubscription<void> _tickSubscription;
  DateTime _measurementStartDate;

  /// Can be specified to change how the current time is determined
  /// when starting or stopping a measurement (intended for faking in unit tests).
  final DateTime Function() currentTimeProvider;

  /// Creates a [WorktimeStopwatchBloc] that updates its measurement state
  /// with every tick of the specified [tickSource].
  WorktimeStopwatchBloc(Stream<void> tickSource, this.currentTimeProvider) {
    this._tickSubscription = tickSource.listen((_) { this._updateMeasurement(); });
  }

  /// Provides the state of the current measurement with the stopwatch.
  Stream<MeasurementState> get measurement
    // Distinct to not push repeated updates while the stopwatch 
    // did not change (because of its second-precision).
    => _measurement.stream.distinct();

  /// Starts the stopwatch measuring worktime.
  void startMeasurement() {
    this._measurementStartDate = this.currentTimeProvider();
    this._updateMeasurement();
  }

  /// Stops the stopwatch measuring worktime.
  void stopMeasurement() {
    this._measurementStartDate = null;
    this._updateMeasurement();
  }

  void _updateMeasurement() {
    if (this._measurementStartDate == null) {
      this._measurement.add(MeasurementState.off);
    } else {
      this._measurement.add(MeasurementState.running(
        this.currentTimeProvider().difference(this._measurementStartDate)
      ));
    }
  }

  /// Disposes of underlying resources.
  void dispose() {
    this._measurement.close();
    this._tickSubscription.cancel();
  }
}

/// Defines the state of a worktime measurement with the stopwatch.
class MeasurementState {
  /// True, if the stopwatch is currently running a measurement; otherwise false.
  final bool isMeasuring;

  /// Gets the current duration that the stopwatch has been running.
  final Duration measuredDuration;

  const MeasurementState._(this.isMeasuring, this.measuredDuration);

  /// Creates a state representing a stopped stopwatch.
  static const MeasurementState off =
    MeasurementState._(false, Duration.zero);

  /// Creates a state representing a snapshot of a running stopwatch.
  factory MeasurementState.running(Duration duration) {
    // Enforce second-precision of stopwatch measurements.
    var durationWithSecondsPrecision = Duration(
      hours: duration.inHours,
      minutes: duration.inMinutes.remainder(Duration.minutesPerHour),
      seconds: duration.inSeconds.remainder(Duration.secondsPerMinute));

    return MeasurementState._(true, durationWithSecondsPrecision);
  }

  /// Gets the text that should be displayed by the stopwatch for the current measurement.
  String get displayText {
    var minutes = measuredDuration.inMinutes.remainder(Duration.minutesPerHour);
    var seconds = measuredDuration.inSeconds.remainder(Duration.secondsPerMinute);

    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(measuredDuration.inHours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  }
  
  @override
  bool operator ==(Object other) => other is MeasurementState 
    && other.isMeasuring == this.isMeasuring
    && other.measuredDuration == this.measuredDuration;

  @override
  int get hashCode => measuredDuration.hashCode;
}
