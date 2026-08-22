import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/widgets/star_rating.dart';

void main() {
  group('StarRatingInput', () {
    testWidgets('tapping star N calls onChanged(N)', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(
              value: 0,
              onChanged: (value) => tapped = value,
            ),
          ),
        ),
      );

      final starButtons = find.byType(IconButton);
      expect(starButtons, findsNWidgets(5));

      // Tap the 4th star (index 3).
      await tester.tap(starButtons.at(3));
      await tester.pump();

      expect(tapped, 4);
    });

    testWidgets('renders filled stars up to value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRatingInput(value: 3, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(2));
    });
  });

  group('StarRatingDisplay', () {
    testWidgets('renders without a callback and shows the count',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 4.2, count: 23),
          ),
        ),
      );

      expect(find.text('(23)'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(1));
    });

    testWidgets('shows a fallback message when there are no reviews',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StarRatingDisplay(rating: 0, count: 0),
          ),
        ),
      );

      expect(find.text('No reviews yet'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });
  });
}
