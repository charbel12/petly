import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/providers/theme_provider.dart';
import 'package:petly/core/theme/app_theme.dart';
import 'package:petly/core/widgets/empty_state.dart';
import 'package:petly/core/widgets/listing_image.dart';

void main() {
  test('parseThemeMode round-trips', () {
    expect(parseThemeMode('light'), ThemeMode.light);
    expect(parseThemeMode('dark'), ThemeMode.dark);
    expect(parseThemeMode(null), ThemeMode.system);
    expect(encodeThemeMode(ThemeMode.dark), 'dark');
    expect(themeModeLabel(ThemeMode.system), 'System');
  });

  testWidgets('empty search copy is visible', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: EmptyState(
          title: 'No clinics match “Hamra”',
          message: 'Try another area or clear filters.',
        ),
      ),
    );
    expect(find.text('No clinics match “Hamra”'), findsOneWidget);
    expect(find.text('Try another area or clear filters.'), findsOneWidget);
  });

  testWidgets('listing placeholder renders instead of a broken image',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ListingImage(
            imageUrl: null,
            height: 80,
            placeholderIcon: Icons.local_hospital_rounded,
          ),
        ),
      ),
    );
    expect(find.byIcon(Icons.local_hospital_rounded), findsOneWidget);
  });

  test('dark theme uses a distinct surface from light', () {
    expect(
      AppTheme.dark.scaffoldBackgroundColor,
      isNot(AppTheme.light.scaffoldBackgroundColor),
    );
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.brightness, Brightness.light);
  });
}
