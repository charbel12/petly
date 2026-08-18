class WeeklyHours {
  const WeeklyHours({
    required this.day,
    this.closed = false,
    this.open,
    this.close,
  });

  /// `0 = Sunday` … `6 = Saturday`.
  final int day;
  final bool closed;
  final String? open;
  final String? close;

  static const dayNames = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String get dayName => (day >= 0 && day < dayNames.length) ? dayNames[day] : 'Day $day';

  String get summary {
    if (closed || open == null || close == null) return 'Closed';
    return '$open–$close';
  }

  factory WeeklyHours.fromJson(Map<String, dynamic> json) {
    return WeeklyHours(
      day: json['day'] as int? ?? 0,
      closed: json['closed'] as bool? ?? false,
      open: json['open'] as String?,
      close: json['close'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        if (closed) 'closed': true,
        if (!closed && open != null) 'open': open,
        if (!closed && close != null) 'close': close,
      };
}

class ListingHours {
  const ListingHours({
    this.timezone = 'Asia/Beirut',
    this.weekly = const [],
  });

  final String timezone;
  final List<WeeklyHours> weekly;

  static ListingHours template() {
    return ListingHours(
      timezone: 'Asia/Beirut',
      weekly: [
        const WeeklyHours(day: 0, closed: true),
        for (var day = 1; day <= 6; day++)
          WeeklyHours(day: day, open: '09:00', close: day == 6 ? '14:00' : '18:00'),
      ],
    );
  }

  WeeklyHours entryFor(int day) {
    for (final entry in weekly) {
      if (entry.day == day) return entry;
    }
    return WeeklyHours(day: day, closed: true);
  }

  factory ListingHours.fromJson(Map<String, dynamic> json) {
    final weekly = (json['weekly'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(WeeklyHours.fromJson)
        .toList();
    return ListingHours(
      timezone: (json['timezone'] as String?)?.trim().isNotEmpty == true
          ? json['timezone'] as String
          : 'Asia/Beirut',
      weekly: weekly,
    );
  }

  static ListingHours? tryParse(dynamic raw) {
    if (raw is Map<String, dynamic>) return ListingHours.fromJson(raw);
    if (raw is Map) {
      return ListingHours.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'timezone': timezone,
        'weekly': weekly.map((e) => e.toJson()).toList(),
      };
}
