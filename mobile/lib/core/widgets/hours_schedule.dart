import 'package:flutter/material.dart';
import '../../data/models/listing_hours.dart';
import '../theme/app_tokens.dart';
import 'soft_card.dart';

class HoursScheduleCard extends StatelessWidget {
  const HoursScheduleCard({super.key, required this.hours});

  final ListingHours hours;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hours · ${hours.timezone}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 12),
          for (var day = 0; day <= 6; day++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      WeeklyHours.dayNames[day],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: tokens.onCardMuted,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      hours.entryFor(day).summary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
