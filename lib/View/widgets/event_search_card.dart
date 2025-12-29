import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Model/event.dart';
import '../event_detail_page.dart';

class EventSearchCard extends StatelessWidget {
  final Event event;
  final String searchQuery;

  const EventSearchCard({
    super.key,
    required this.event,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section: Info + Image
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        _highlightText(
                          event.title,
                          searchQuery,
                          textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Organization
                        Text(
                          event.organizationName,
                          style: textTheme.bodyMedium!.copyWith(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Meta Info Row (Participation & Location)
                        // Meta Info Row (Participation | Location)
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getParticipationText(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),

                            // Pipe Separator
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              height: 12,
                              width: 1,
                              color: Colors.grey[400],
                            ),

                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Colors.grey[700],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location ?? 'Online',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right Image (Logo/Banner)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      image:
                          event.bannerUrl != null && event.bannerUrl!.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(event.bannerUrl!),
                                fit: BoxFit.cover,
                              )
                              : null,
                      color: Colors.grey[100],
                    ),
                    child:
                        event.bannerUrl == null || event.bannerUrl!.isEmpty
                            ? Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey[400],
                            )
                            : null,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tags Section
              if (event.tags.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        event.tags.take(4).map((tag) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),

              const SizedBox(height: 16),

              // Bottom Footer Section
              // Footer Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Primary Tag Badge
                  if (event.tags.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.tags.first,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isExpired() ? Colors.orange[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _isExpired() ? 'Expired' : 'Active',
                      style: TextStyle(
                        fontSize: 11,
                        color:
                            _isExpired()
                                ? Colors.orange[800]
                                : Colors.green[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Posted Date
                  Text(
                    "Posted ${DateFormat('MMM d, yyyy').format(event.startDate)}",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Registered Count (Mocked for visual match)
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.black87),
                      const SizedBox(width: 4),
                      Text(
                        "${event.registeredCount ?? 0} Registered",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Action Icons
                  Icon(Icons.share_outlined, size: 20, color: Colors.black54),
                  const SizedBox(width: 16),
                  Icon(Icons.favorite_border, size: 20, color: Colors.black54),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightText(String text, String query, TextStyle style) {
    if (query.isEmpty) return Text(text, style: style);

    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final start = lower.indexOf(q);

    if (start == -1) return Text(text, style: style);

    final end = start + q.length;

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: style, // Removed yellow background
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  String _getParticipationText() {
    if (event.isTeamEvent) {
      if (event.minTeamSize != null && event.maxTeamSize != null) {
        return '${event.minTeamSize} - ${event.maxTeamSize} Members';
      }
      return 'Team Participation';
    }
    return 'Individual Participation';
  }

  bool _isExpired() {
    return event.endDate.isBefore(DateTime.now());
  }
}
