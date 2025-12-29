import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../Model/event.dart';
import '../ViewModel/event_provider.dart';
import 'event_registration_page.dart';
import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

class EventDetailPage extends ConsumerStatefulWidget {
  final Event event;
  const EventDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  Completer<GoogleMapController> _controller = Completer();
  late Set<Marker> _markers;
  late bool _isRegistered;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _isRegistered = widget.event.isRegistered;
  }

  void _initializeMarkers() {
    _markers = {
      Marker(
        markerId: const MarkerId('event_location'),
        position: LatLng(widget.event.latitude, widget.event.longitude),
        infoWindow: InfoWindow(
          title: widget.event.title,
          snippet: widget.event.organizationName,
        ),
      ),
    };
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller.complete(controller);
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.event.latitude, widget.event.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Banner Section
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      colorScheme.primary.withOpacity(0.8),
                      colorScheme.primary.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            backgroundBlendMode: BlendMode.multiply,
                          ),
                        ),
                      ),
                    ),
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Event Banner Image or Icon
                          if (widget.event.bannerUrl != null &&
                              widget.event.bannerUrl!.isNotEmpty)
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  widget.event.bannerUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        _getEventIcon(widget.event.tags),
                                        size: 48,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            )
                          else
                            Icon(
                              _getEventIcon(widget.event.tags),
                              size: 64,
                              color: Colors.white,
                            ),
                          const SizedBox(height: 16),
                          Text(
                            widget.event.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.event.organizationName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags Section
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.event.tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: colorScheme.primary.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 24),

                  // Date & Time Card
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date & Time',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.play_arrow,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDate(widget.event.startDate)} at ${_formatTime(widget.event.startDate)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.stop, size: 16, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(
                              '${_formatDate(widget.event.endDate)} at ${_formatTime(widget.event.endDate)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (widget.event.registrationDeadline != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.alarm,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Registration Deadline: ${_formatDate(widget.event.registrationDeadline!)}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location Card
                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Location',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.location ?? 'Location not specified',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Coordinates: ${widget.event.latitude.toStringAsFixed(4)}, ${widget.event.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Team Information (if applicable)
                  if (widget.event.isTeamEvent) ...[
                    _buildInfoCard(
                      icon: Icons.group,
                      title: 'Team Information',
                      content: Text(
                        'Team Size: ${widget.event.minTeamSize ?? 1} - ${widget.event.maxTeamSize ?? 1} members',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description Card
                  _buildInfoCard(
                    icon: Icons.description,
                    title: 'About This Event',
                    content: Text(
                      widget.event.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Prize Pool Card (if prizes exist)
                  if (widget.event.prizes != null &&
                      widget.event.prizes!.isNotEmpty) ...[
                    _buildInfoCard(
                      icon: Icons.emoji_events,
                      title: 'Prize Pool',
                      content: Column(
                        children: [
                          ...widget.event.prizes!.asMap().entries.map((entry) {
                            final index = entry.key;
                            final prize = entry.value;
                            final place =
                                index == 0
                                    ? '1st'
                                    : index == 1
                                    ? '2nd'
                                    : '3rd';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          index == 0
                                              ? Colors.amber
                                              : index == 1
                                              ? Colors.grey[400]
                                              : Colors.brown[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      place,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      prize,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'All participants receive Certificate of Participation',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.8,
                                      ),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Organizer Card
                  _buildInfoCard(
                    icon: Icons.business,
                    title: 'Organizer',
                    content: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              widget.event.organizationLogo.isNotEmpty
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      widget.event.organizationLogo,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.business,
                                          color: colorScheme.primary,
                                          size: 30,
                                        );
                                      },
                                    ),
                                  )
                                  : Icon(
                                    Icons.business,
                                    color: colorScheme.primary,
                                    size: 30,
                                  ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.event.organizationName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Event Organizer',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Contact Information Card
                  if (widget.event.contactEmail != null ||
                      widget.event.contactPhone != null)
                    _buildInfoCard(
                      icon: Icons.contact_mail,
                      title: 'Contact Information',
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.event.contactEmail != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.event.contactEmail!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.event.contactPhone != null)
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 16,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  widget.event.contactPhone!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                        ],
                      ),
                    )
                  else
                    Consumer(
                      builder: (context, ref, child) {
                        final contactsAsync = ref.watch(
                          eventContactsProvider(widget.event.eventId),
                        );
                        return contactsAsync.when(
                          data: (contacts) {
                            if (contacts.isEmpty)
                              return const SizedBox.shrink();
                            return _buildInfoCard(
                              icon: Icons.contact_mail,
                              title: 'Contact Information',
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    contacts.map((contact) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (contact['name']?.isNotEmpty ==
                                                true) ...[
                                              Text(
                                                contact['name'],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                            if (contact['role']?.isNotEmpty ==
                                                true) ...[
                                              Text(
                                                contact['role'],
                                                style: TextStyle(
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.7),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                            ],
                                            if (contact['email']?.isNotEmpty ==
                                                true) ...[
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.email,
                                                    size: 16,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    contact['email'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                            if (contact['phone']?.isNotEmpty ==
                                                true) ...[
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone,
                                                    size: 16,
                                                    color: Colors.green,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    contact['phone'],
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (error, stack) => const SizedBox.shrink(),
                        );
                      },
                    ),

                  const SizedBox(height: 24),

                  // Map Section
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.event.latitude,
                            widget.event.longitude,
                          ),
                          zoom: 14,
                        ),
                        markers: _markers,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        compassEnabled: false,
                        mapToolbarEnabled: false,
                        mapType: MapType.normal,
                        scrollGesturesEnabled: true,
                        zoomGesturesEnabled: true,
                        rotateGesturesEnabled: true,
                        tiltGesturesEnabled: true,
                        gestureRecognizers:
                            <Factory<OneSequenceGestureRecognizer>>{
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            },
                      ),
                    ),
                  ),

                  const SizedBox(height: 100), // Space for bottom action
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for Registration
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Consumer(
          builder: (context, ref, child) {
            return FloatingActionButton.extended(
              onPressed:
                  _isRegistered
                      ? () async {
                        // Handle unregistration
                        final notifier = ref.read(eventFeedProvider.notifier);
                        final success = await notifier.unregisterFromEvent(
                          widget.event.eventId,
                        );

                        if (success && mounted) {
                          setState(() {
                            _isRegistered = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Unregistered from event'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                      : () {
                        // Navigate to registration page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    EventRegistrationPage(event: widget.event),
                          ),
                        ).then((result) {
                          // Assuming registration page returns true if registered
                          if (result == true && mounted) {
                            setState(() {
                              _isRegistered = true;
                            });
                          }
                        });
                      },
              backgroundColor:
                  _isRegistered ? Colors.orange : colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: Icon(_isRegistered ? Icons.cancel : Icons.check),
              label: Text(
                _isRegistered ? 'Unregister' : 'Register Now',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  IconData _getEventIcon(List<String> tags) {
    if (tags.contains('Hackathon')) return Icons.code;
    if (tags.contains('Competition')) return Icons.emoji_events;
    if (tags.contains('Workshop')) return Icons.school;
    if (tags.contains('Career Fair') || tags.contains('Internship'))
      return Icons.business_center;
    if (tags.contains('Gaming')) return Icons.games;
    if (tags.contains('AI') || tags.contains('Machine Learning'))
      return Icons.smart_toy;
    if (tags.contains('Blockchain')) return Icons.account_balance_wallet;
    return Icons.event;
  }
}
