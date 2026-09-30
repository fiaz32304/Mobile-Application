import 'package:flutter_test/flutter_test.dart';
import 'package:student/main.dart';

void main() {
  testWidgets('Student Dashboard loads', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentCampusApp());

    expect(find.text('Campus Dashboard'), findsOneWidget);
    expect(find.text('Fiaz Ahmad'), findsOneWidget);
  });
}