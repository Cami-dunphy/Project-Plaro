enum EventSortOrder { relevance, date, popularity }

class FilterOptions {
  final Set<String> eventTypes; // e.g., {'Hackathon', 'Competition'}
  final Set<String> teamSizes; // e.g., {'Individual', '2-4 members'}
  final EventSortOrder sortOrder;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final bool? isRegistered;
  final bool? isTeamEvent;

  const FilterOptions({
    this.eventTypes = const {},
    this.teamSizes = const {},
    this.sortOrder = EventSortOrder.relevance,
    this.startDate,
    this.endDate,
    this.location,
    this.isRegistered,
    this.isTeamEvent,
  });

  FilterOptions copyWith({
    Set<String>? eventTypes,
    Set<String>? teamSizes,
    EventSortOrder? sortOrder,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    bool? isRegistered,
    bool? isTeamEvent,
  }) {
    return FilterOptions(
      eventTypes: eventTypes ?? this.eventTypes,
      teamSizes: teamSizes ?? this.teamSizes,
      sortOrder: sortOrder ?? this.sortOrder,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      isRegistered: isRegistered ?? this.isRegistered,
      isTeamEvent: isTeamEvent ?? this.isTeamEvent,
    );
  }
}
