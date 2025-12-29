import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'widgets/event_category_row.dart';
import 'widgets/event_page_shimmer.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'package:plaro_3/ViewModel/event_provider.dart';
import 'widgets/plaro_app_bar.dart';
import 'widgets/event_search_card.dart';
import 'dart:async';
import 'create_events_page.dart';
import '../Model/event.dart';
import '../Model/filter_options.dart';

class DummyEventsPage extends StatefulWidget {
  const DummyEventsPage({super.key});

  @override
  State<DummyEventsPage> createState() => _DummyEventsPageState();
}

class _DummyEventsPageState extends State<DummyEventsPage> {
  String _searchQuery = '';
  FilterOptions _filterOptions = const FilterOptions();

  late List<Event> _dummyEvents;

  @override
  void initState() {
    super.initState();
    _dummyEvents = _getDummyEvents();
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building DummyEventsPage');

    // Dummy data
    final dummyEvents = _dummyEvents;

    // Apply search filter
    final filteredEvents =
        _searchQuery.isEmpty
            ? dummyEvents
            : dummyEvents.where((event) {
              final query = _searchQuery.toLowerCase();
              return event.title.toLowerCase().contains(query) ||
                  event.description.toLowerCase().contains(query) ||
                  event.organizationName.toLowerCase().contains(query) ||
                  (event.category?.toLowerCase().contains(query) ?? false) ||
                  (event.location?.toLowerCase().contains(query) ?? false) ||
                  event.tags.any((tag) => tag.toLowerCase().contains(query));
            }).toList();

    // Apply category filters
    final filteredByCategory =
        filteredEvents.where((event) {
          if (_filterOptions.eventTypes.isEmpty) return true;
          return _filterOptions.eventTypes.any(
            (type) => event.tags.contains(type),
          );
        }).toList();

    // Apply team size filters
    final finalFilteredEvents =
        filteredByCategory.where((event) {
          if (_filterOptions.teamSizes.isEmpty) return true;
          if (_filterOptions.teamSizes.contains('Individual') &&
              !event.isTeamEvent)
            return true;
          if (_filterOptions.teamSizes.contains('2-4 Members') &&
              event.isTeamEvent &&
              event.minTeamSize != null &&
              event.minTeamSize! >= 2 &&
              event.maxTeamSize != null &&
              event.maxTeamSize! <= 4)
            return true;
          if (_filterOptions.teamSizes.contains('5+ Members') &&
              event.isTeamEvent &&
              event.maxTeamSize != null &&
              event.maxTeamSize! >= 5)
            return true;
          return false;
        }).toList();

    final categories = [
      {
        'title': 'Trending',
        'events':
            finalFilteredEvents
                .where((e) => e.tags.contains('Trending'))
                .toList(),
      },
      {
        'title': 'Hackathons',
        'events':
            finalFilteredEvents
                .where((e) => e.tags.contains('Hackathon'))
                .toList(),
      },
      {
        'title': 'Competitions',
        'events':
            finalFilteredEvents
                .where((e) => e.tags.contains('Competition'))
                .toList(),
      },
      {
        'title': 'Workshops',
        'events':
            finalFilteredEvents
                .where((e) => e.tags.contains('Workshop'))
                .toList(),
      },
      {
        'title': 'Career & Networking',
        'events':
            finalFilteredEvents
                .where(
                  (e) =>
                      e.tags.contains('Career Fair') ||
                      e.tags.contains('Internship') ||
                      e.tags.contains('Jobs') ||
                      e.tags.contains('Networking'),
                )
                .toList(),
      },
    ];

    final hasResults = categories.any(
      (cat) => (cat['events'] as List).isNotEmpty,
    );
    print('📋 Dummy Categories with results: $hasResults');
    categories.forEach((cat) {
      print('  - ${cat['title']}: ${(cat['events'] as List).length} events');
    });

    return Scaffold(
      appBar: PlaroAppBar(
        onSearch: (query) {
          setState(() {
            _searchQuery = query;
          });
          print('Dummy search: $query');
        },
        onFilter: () async {
          final selectedFilters = await showModalBottomSheet<FilterOptions>(
            context: context,
            builder: (_) => FilterBottomSheet(initialFilters: _filterOptions),
          );
          if (selectedFilters != null) {
            setState(() {
              _filterOptions = selectedFilters;
            });
            print('Dummy filter applied: $selectedFilters');
          }
        },
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Dummy refresh
          await Future.delayed(const Duration(seconds: 1));
          print('Dummy refresh');
        },
        child:
            _searchQuery.isNotEmpty
                ? finalFilteredEvents.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No events found',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: finalFilteredEvents.length,
                      itemBuilder: (context, index) {
                        return EventSearchCard(
                          event: finalFilteredEvents[index],
                          searchQuery: _searchQuery,
                        );
                      },
                    )
                : hasResults
                ? _AnimatedCategoryList(
                  categories: categories,
                  searchQuery: _searchQuery,
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No dummy events found',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  List<Event> _getDummyEvents() {
    final now = DateTime.now();
    final random = now.millisecondsSinceEpoch % 100; // Simple pseudo-random

    return [
      // Hackathons
      Event(
        eventId: '1',
        organizerId: 'org1',
        title: 'Flutter Global Hackathon 2025',
        description:
            'Join developers worldwide to build the next generation of Flutter apps in 48 hours. Prizes worth \$50,000!',
        organizationName: 'Flutter Community',
        organizationLogo: '',
        tags: ['Hackathon', 'Technology', 'Trending', 'Mobile'],
        startDate: now.add(Duration(days: 7 + (random % 3))),
        endDate: now.add(Duration(days: 9 + (random % 3))),
        isTeamEvent: true,
        minTeamSize: 2,
        maxTeamSize: 5,
        isRegistered: false,
        challenges: [],
        latitude: 37.7749,
        longitude: -122.4194,
        category: 'Hackathon',
        location: 'San Francisco, CA',
        registrationDeadline: now.add(Duration(days: 5 + (random % 2))),
        bannerUrl: '',
        registeredCount: 876 + (random * 5),
        contactEmail: 'organizer@flutterhack.com',
        contactPhone: '+1 (555) 123-4567',
        prizes: [
          '1st Place: \$20,000 + Certificate of Achievement',
          '2nd Place: \$10,000',
          '3rd Place: \$5,000',
        ],
      ),
      Event(
        eventId: '5',
        organizerId: 'org5',
        title: 'AI & ML Winter Hack',
        description:
            'Build cutting-edge AI solutions using machine learning frameworks. Perfect for data scientists and engineers.',
        organizationName: 'DataTech Institute',
        organizationLogo: '',
        tags: ['Hackathon', 'AI', 'Machine Learning', 'Data Science'],
        startDate: now.add(const Duration(days: 14)),
        endDate: now.add(const Duration(days: 16)),
        isTeamEvent: true,
        minTeamSize: 3,
        maxTeamSize: 6,
        isRegistered: true,
        challenges: [],
        latitude: 42.3601,
        longitude: -71.0589,
        category: 'Hackathon',
        location: 'Boston, MA',
        registrationDeadline: now.add(const Duration(days: 10)),
        bannerUrl: '',
        registeredCount: 342,
        contactEmail: 'contact@datatech.edu',
        contactPhone: '+1 (555) 987-6543',
        prizes: [
          '1st Place: \$15,000 + Certificate of Achievement',
          '2nd Place: \$8,000',
          '3rd Place: \$4,000',
        ],
      ),

      // Competitions
      Event(
        eventId: '2',
        organizerId: 'org2',
        title: 'Global AI Coding Championship',
        description:
            'Showcase your AI and machine learning skills in this prestigious international competition.',
        organizationName: 'AI Research Labs',
        organizationLogo: '',
        tags: ['Competition', 'AI', 'Technology', 'Trending'],
        startDate: now.add(Duration(days: 21 + (random % 5))),
        endDate: now.add(Duration(days: 22 + (random % 5))),
        isTeamEvent: false,
        minTeamSize: 1,
        maxTeamSize: 1,
        isRegistered: true,
        challenges: [],
        latitude: 40.7128,
        longitude: -74.0060,
        category: 'Competition',
        location: 'New York, NY',
        registrationDeadline: now.add(Duration(days: 18 + (random % 3))),
        bannerUrl: '',
        registeredCount: 1250,
        contactEmail: 'organizer@aicoding.com',
        contactPhone: '+1 (555) 222-3333',
        prizes: [
          '1st Place: \$25,000 + Certificate of Achievement',
          '2nd Place: \$15,000',
          '3rd Place: \$10,000',
        ],
      ),
      Event(
        eventId: '6',
        organizerId: 'org6',
        title: 'Cybersecurity Challenge 2025',
        description:
            'Test your ethical hacking skills in this comprehensive cybersecurity competition.',
        organizationName: 'CyberSec Academy',
        organizationLogo: '',
        tags: ['Competition', 'Cybersecurity', 'Security', 'Trending'],
        startDate: now.add(const Duration(days: 30)),
        endDate: now.add(const Duration(days: 31)),
        isTeamEvent: true,
        minTeamSize: 2,
        maxTeamSize: 4,
        isRegistered: false,
        challenges: [],
        latitude: 38.9072,
        longitude: -77.0369,
        category: 'Competition',
        location: 'Washington, DC',
        registrationDeadline: now.add(const Duration(days: 25)),
        bannerUrl: '',
        registeredCount: 56,
        contactEmail: 'security@cybersec.org',
        contactPhone: '+1 (555) 999-8888',
        prizes: [
          '1st Place: \$12,000 + Certificate of Achievement',
          '2nd Place: \$7,000',
          '3rd Place: \$3,000',
        ],
      ),

      // Workshops
      Event(
        eventId: '3',
        organizerId: 'org3',
        title: 'Advanced React & Next.js Workshop',
        description:
            'Master modern web development with hands-on experience in React, Next.js, and advanced JavaScript concepts.',
        organizationName: 'WebDev Academy',
        organizationLogo: '',
        tags: ['Workshop', 'Web Development', 'React', 'JavaScript'],
        startDate: now.add(Duration(days: 3 + (random % 2))),
        endDate: now.add(Duration(days: 3 + (random % 2), hours: 6)),
        isTeamEvent: false,
        minTeamSize: 1,
        maxTeamSize: 1,
        isRegistered: false,
        challenges: [],
        latitude: 34.0522,
        longitude: -118.2437,
        category: 'Workshop',
        location: 'Los Angeles, CA',
        registrationDeadline: now.add(Duration(days: 1 + (random % 2))),
        bannerUrl: '',
        registeredCount: 120,
        contactEmail: 'info@webdevacademy.com',
        contactPhone: '+1 (555) 444-5555',
      ),
      Event(
        eventId: '7',
        organizerId: 'org7',
        title: 'Blockchain Development Bootcamp',
        description:
            'Learn to build decentralized applications using Solidity, Web3.js, and modern blockchain technologies.',
        organizationName: 'BlockChain Institute',
        organizationLogo: '',
        tags: ['Workshop', 'Blockchain', 'Web3', 'Cryptocurrency'],
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 12)),
        isTeamEvent: false,
        minTeamSize: 1,
        maxTeamSize: 1,
        isRegistered: false,
        challenges: [],
        latitude: 25.7617,
        longitude: -80.1918,
        category: 'Workshop',
        location: 'Miami, FL',
        registrationDeadline: now.add(const Duration(days: 8)),
        bannerUrl: '',
        registeredCount: 45,
        contactEmail: 'hello@blockchain.io',
        contactPhone: '+1 (555) 777-6666',
      ),

      // More Hackathons
      Event(
        eventId: '4',
        organizerId: 'org4',
        title: 'IoT Innovation Hackathon',
        description:
            'Create innovative Internet of Things solutions for smart cities and connected devices.',
        organizationName: 'IoT Solutions Inc',
        organizationLogo: '',
        tags: ['Hackathon', 'IoT', 'Innovation', 'Hardware'],
        startDate: now.add(Duration(days: 25 + (random % 4))),
        endDate: now.add(Duration(days: 27 + (random % 4))),
        isTeamEvent: true,
        minTeamSize: 2,
        maxTeamSize: 5,
        isRegistered: false,
        challenges: [],
        latitude: 41.8781,
        longitude: -87.6298,
        category: 'Hackathon',
        location: 'Chicago, IL',
        registrationDeadline: now.add(Duration(days: 20 + (random % 3))),
        bannerUrl: '',
        registeredCount: 210,
        contactEmail: 'innovate@iotsolutions.com',
        contactPhone: '+1 (555) 888-2222',
        prizes: [
          '1st Place: \$18,000 + Certificate of Achievement',
          '2nd Place: \$9,000',
          '3rd Place: \$4,500',
        ],
      ),
      Event(
        eventId: '8',
        organizerId: 'org8',
        title: 'Game Jam: Retro Edition',
        description:
            'Build classic-style games in 48 hours using modern engines. Theme: "Back to the 80s".',
        organizationName: 'Indie Game Studios',
        organizationLogo: '',
        tags: ['Hackathon', 'Gaming', 'Game Development', 'Creative'],
        startDate: now.add(const Duration(days: 18)),
        endDate: now.add(const Duration(days: 20)),
        isTeamEvent: true,
        minTeamSize: 1,
        maxTeamSize: 4,
        isRegistered: true,
        challenges: [],
        latitude: 47.6062,
        longitude: -122.3321,
        category: 'Hackathon',
        location: 'Seattle, WA',
        registrationDeadline: now.add(const Duration(days: 15)),
        bannerUrl: '',
        registeredCount: 89,
        contactEmail: 'jam@indiegames.studio',
        contactPhone: '+1 (555) 111-2222',
        prizes: [
          '1st Place: \$8,000 + Certificate of Achievement',
          '2nd Place: \$4,000',
          '3rd Place: \$2,000',
        ],
      ),

      // More Competitions
      Event(
        eventId: '9',
        organizerId: 'org9',
        title: 'Data Science Olympics',
        description:
            'Compete in real-world data science challenges with industry datasets and problems.',
        organizationName: 'Data Science League',
        organizationLogo: '',
        tags: ['Competition', 'Data Science', 'Analytics', 'Trending'],
        startDate: now.add(const Duration(days: 35)),
        endDate: now.add(const Duration(days: 36)),
        isTeamEvent: false,
        minTeamSize: 1,
        maxTeamSize: 1,
        isRegistered: false,
        challenges: [],
        latitude: 37.4419,
        longitude: -122.1430,
        category: 'Competition',
        location: 'Palo Alto, CA',
        registrationDeadline: now.add(const Duration(days: 30)),
        bannerUrl: '',
        registeredCount: 3300,
        contactEmail: 'data@datascienceleague.org',
        contactPhone: '+1 (555) 333-4444',
        prizes: [
          '1st Place: \$30,000 + Certificate of Achievement',
          '2nd Place: \$20,000',
          '3rd Place: \$10,000',
        ],
      ),

      // Internship/Job Fairs
      Event(
        eventId: '10',
        organizerId: 'org10',
        title: 'Tech Career Fair 2025',
        description:
            'Connect with top tech companies for internships and full-time opportunities. Meet recruiters from FAANG and startups.',
        organizationName: 'CareerTech Network',
        organizationLogo: '',
        tags: ['Career Fair', 'Internship', 'Jobs', 'Networking', 'Trending'],
        startDate: now.add(const Duration(days: 12)),
        endDate: now.add(const Duration(days: 12)),
        isTeamEvent: false,
        minTeamSize: 1,
        maxTeamSize: 1,
        isRegistered: false,
        challenges: [],
        latitude: 39.7392,
        longitude: -104.9903,
        category: 'Career Fair',
        location: 'Denver, CO',
        registrationDeadline: now.add(const Duration(days: 10)),
        bannerUrl: '',
        registeredCount: 500,
        contactEmail: 'careers@techfair.com',
        contactPhone: '+1 (555) 000-1111',
      ),
    ];
  }
}

class _AnimatedCategoryList extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final String searchQuery;
  const _AnimatedCategoryList({
    required this.categories,
    required this.searchQuery,
  });

  @override
  State<_AnimatedCategoryList> createState() => _AnimatedCategoryListState();
}

class _AnimatedCategoryListState extends State<_AnimatedCategoryList>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.categories.length, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });
    _fadeAnimations =
        _controllers
            .map(
              (c) => Tween<double>(
                begin: 0,
                end: 1,
              ).animate(CurvedAnimation(parent: c, curve: Curves.easeIn)),
            )
            .toList();
    _slideAnimations =
        _controllers
            .map(
              (c) => Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
            )
            .toList();
    _runStaggeredAnimations();
  }

  Future<void> _runStaggeredAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: widget.categories.length,
      itemBuilder: (context, i) {
        final cat = widget.categories[i];
        return AnimatedBuilder(
          animation: _controllers[i],
          builder:
              (context, child) => Opacity(
                opacity: _fadeAnimations[i].value,
                child: SlideTransition(
                  position: _slideAnimations[i],
                  child: child,
                ),
              ),
          child: EventCategoryRow(
            title: cat['title'],
            events: cat['events'],
            searchQuery: widget.searchQuery,
          ),
        );
      },
    );
  }
}
