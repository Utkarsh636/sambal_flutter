import 'package:flutter_test/flutter_test.dart';
import 'package:sambal_flutter/app.dart';

void main() {
  testWidgets('Sambal app loads', (tester) async {
    await tester.pumpWidget(const SambalApp());

    expect(find.byType(SambalApp), findsOneWidget);
  });
}