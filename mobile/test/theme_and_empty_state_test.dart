import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/providers/theme_provider.dart';
import 'package:petly/core/theme/app_theme.dart';
import 'package:petly/core/theme/app_tokens.dart';
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

  test('teal/slate palette is wired into light and dark themes', () {
    expect(AppTheme.light.scaffoldBackgroundColor, const Color(0xFFF8FAFC));
    expect(AppTokens.light.card, const Color(0xFFFFFFFF));
    expect(AppTokens.light.card, isNot(AppTokens.light.background));
    expect(AppTheme.light.colorScheme.primary, const Color(0xFF0D8275));
    expect(AppTheme.dark.scaffoldBackgroundColor, const Color(0xFF0B0F19));
    expect(AppTheme.dark.colorScheme.primary, const Color(0xFF2DD4BF));
    expect(AppTokens.dark.card, const Color(0xFF1E293B));
    expect(AppTokens.dark.danger, const Color(0xFFFB7185));
    expect(
      AppTheme.dark.scaffoldBackgroundColor,
      isNot(AppTheme.light.scaffoldBackgroundColor),
    );
    expect(AppTheme.dark.brightness, Brightness.dark);
    expect(AppTheme.light.brightness, Brightness.light);
  });
}
