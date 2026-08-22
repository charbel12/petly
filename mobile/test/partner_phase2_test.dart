import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petly/core/widgets/status_chip.dart';
import 'package:petly/data/models/listing_hours.dart';
import 'package:petly/data/repositories/partners_repository.dart';
import 'package:petly/features/auth/presentation/register_screen.dart';
import 'package:petly/features/partner/presentation/partner_dashboard_screen.dart';
import 'package:petly/features/partner/providers/partner_providers.dart';
import 'support/localized_app.dart';

void main() {
  testWidgets('StatusChip labels pending, approved, and rejected', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusChip(status: 'pending'),
              StatusChip(status: 'approved'),
              StatusChip(status: 'rejected'),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Rejected'), findsOneWidget);
  });

  test('ListingHours parses weekly JSON and templates Beirut hours', () {
    final parsed = ListingHours.fromJson({
      'timezone': 'Asia/Beirut',
      'weekly': [
        {'day': 0, 'closed': true},
        {'day': 1, 'open': '09:00', 'close': '18:00'},
      ],
    });
    expect(parsed.entryFor(0).summary, 'Closed');
    expect(parsed.entryFor(1).summary, '09:00–18:00');
    expect(parsed.entryFor(2).closed, isTrue);

    final template = ListingHours.template();
    expect(template.timezone, 'Asia/Beirut');
    expect(template.weekly, hasLength(7));
    expect(template.entryFor(0).closed, isTrue);
    expect(template.entryFor(1).open, '09:00');
  });

  testWidgets('partner dashboard empty state offers add clinic and store',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          partnerListingsProvider.overrideWith(
            (ref) async => const PartnerListings(vets: [], stores: []),
          ),
        ],
        child: const MaterialApp(home: PartnerDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No listings yet'), findsOneWidget);
    expect(find.text('Add clinic'), findsOneWidget);
    expect(find.text('Add store'), findsOneWidget);
  });

  testWidgets('register screen includes partner role toggle', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: localizedApp(home: const RegisterScreen()),
      ),
    );
    await tester.pump();
    expect(find.text("I'm a clinic or store owner"), findsOneWidget);
  });
}
