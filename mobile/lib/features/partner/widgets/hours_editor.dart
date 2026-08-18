import 'package:flutter/material.dart';
import '../../../data/models/listing_hours.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/soft_card.dart';

class HoursEditor extends StatefulWidget {
  const HoursEditor({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final ListingHours value;
  final ValueChanged<ListingHours> onChanged;

  @override
  State<HoursEditor> createState() => _HoursEditorState();
}

class _HoursEditorState extends State<HoursEditor> {
  late final List<TextEditingController> _open;
  late final List<TextEditingController> _close;
  late final List<bool> _closed;

  @override
  void initState() {
    super.initState();
    _open = List.generate(7, (day) {
      return TextEditingController(text: widget.value.entryFor(day).open ?? '09:00');
    });
    _close = List.generate(7, (day) {
      return TextEditingController(text: widget.value.entryFor(day).close ?? '18:00');
    });
    _closed = List.generate(7, (day) => widget.value.entryFor(day).closed);
  }

  @override
  void dispose() {
    for (final controller in [..._open, ..._close]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      ListingHours(
        timezone: widget.value.timezone.isEmpty ? 'Asia/Beirut' : widget.value.timezone,
        weekly: [
          for (var day = 0; day <= 6; day++)
            WeeklyHours(
              day: day,
              closed: _closed[day],
              open: _closed[day] ? null : _open[day].text.trim(),
              close: _closed[day] ? null : _close[day].text.trim(),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hours',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Timezone ${widget.value.timezone.isEmpty ? 'Asia/Beirut' : widget.value.timezone}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.onCardMuted,
                ),
          ),
          const SizedBox(height: 12),
          for (var day = 0; day <= 6; day++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    WeeklyHours.dayNames[day],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Switch(
                  value: !_closed[day],
                  onChanged: (open) {
                    setState(() => _closed[day] = !open);
                    _emit();
                  },
                ),
              ],
            ),
            if (!_closed[day])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _open[day],
                        decoration: const InputDecoration(labelText: 'Open'),
                        onChanged: (_) => _emit(),
                        validator: (value) {
                          if (_closed[day]) return null;
                          if (!_isHhMm(value)) return 'Use HH:mm';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _close[day],
                        decoration: const InputDecoration(labelText: 'Close'),
                        onChanged: (_) => _emit(),
                        validator: (value) {
                          if (_closed[day]) return null;
                          if (!_isHhMm(value)) return 'Use HH:mm';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

bool _isHhMm(String? value) {
  return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(value?.trim() ?? '');
}
