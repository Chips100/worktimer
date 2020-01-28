import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget via the specified WidgetTester,
/// ensuring a configured testing environment (i.e. Directionality widget is present).
Future pumpTestWidget(WidgetTester tester, Widget widget) async {
  // Wrap in MediaQuery and MaterialApp
  // to avoid errors like missing Directionality widget.
  await tester.pumpWidget(
    new MediaQuery(
      data: new MediaQueryData(),
      child: new MaterialApp(
        home: widget
      )
    )
  );
  
  await tester.pump();
}