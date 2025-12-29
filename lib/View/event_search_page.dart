import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../Model/event.dart';
import '../Model/filter_options.dart';
import '../ViewModel/event_provider.dart';
import 'widgets/event_search_card.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/plaro_app_bar.dart';

class EventSearchPage extends ConsumerStatefulWidget {
  final String initialQuery;
  const EventSearchPage({super.key, this.initialQuery = ''});

  @override
  ConsumerState<EventSearchPage> createState() => _EventSearchPageState();
}

class _EventSearchPageState extends ConsumerState<EventSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    _searchController.addListener(_onSearchChanged);
    if (widget.initialQuery.isNotEmpty) {
      _onSearchChanged();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      ref.read(eventFeedProvider.notifier).setSearchQuery('');
    } else {
      ref.read(eventFeedProvider.notifier).setSearchQuery(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventFeedProvider);
    final notifier = ref.watch(eventFeedProvider.notifier);

    // Collect all filtered events for search results
    final allFilteredEvents =
        [
          ...notifier.filteredTrendingEvents,
          ...notifier.filteredUpcomingHackathons,
          ...notifier.filteredTrendingCompetitions,
        ].toSet().toList(); // Remove duplicates

    return Scaffold(
      appBar: PlaroAppBar(
        onSearch: (query) {
          _searchController.text = query;
          _onSearchChanged();
        },
        onFilter: () async {
          final selectedFilters = await showModalBottomSheet<FilterOptions>(
            context: context,
            builder:
                (_) => FilterBottomSheet(initialFilters: state.filterOptions),
          );
          if (selectedFilters != null) {
            notifier.applyFilters(selectedFilters);
          }
        },
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                suffixIcon:
                    _isSearching
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
              ),
            ),
          ),
          // Results
          Expanded(
            child:
                state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : state.error != null
                    ? Center(child: Text("Error: ${state.error}"))
                    : allFilteredEvents.isEmpty
                    ? const Center(child: Text('No events found'))
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: allFilteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = allFilteredEvents[index];
                        return EventSearchCard(
                          event: event,
                          searchQuery: state.searchQuery,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
