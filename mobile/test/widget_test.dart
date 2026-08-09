import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/main.dart';

void main() {
  testWidgets('Petly app builds', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: PetlyApp()));
    await tester.pump();
    // Allow async user/location providers to settle without hanging on GPS.
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Hi,'), findsOneWidget);
  });
}
