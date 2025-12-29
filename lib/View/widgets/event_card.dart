import 'package:flutter/material.dart';
import '../../Model/event.dart';
import '../event_detail_page.dart';
import 'package:intl/intl.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final String searchQuery;
  const EventCard({super.key, required this.event, this.searchQuery = ''});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    final secondaryColor = isDark ? Colors.white70 : Colors.black87;
    final tertiaryColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      // No margin here as spacing is handled by the list separator
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.withOpacity(0.1),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Section
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: isDark ? Colors.white10 : Colors.grey[100],
                image:
                    event.bannerUrl != null && event.bannerUrl!.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(event.bannerUrl!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  event.bannerUrl == null || event.bannerUrl!.isEmpty
                      ? Center(
                        child: Icon(
                          _getEventIcon(event.tags),
                          size: 32,
                          color: isDark ? Colors.white30 : Colors.grey[400],
                        ),
                      )
                      : null,
            ),

            // Bottom Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        _highlightText(
                          event.title,
                          searchQuery,
                          textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            height: 1.2,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Organization
                        Text(
                          event.organizationName,
                          style: textTheme.bodySmall!.copyWith(
                            color: secondaryColor,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // Footer: Date + Status/Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 10,
                              color: tertiaryColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                DateFormat(
                                  'MMM d, yyyy',
                                ).format(event.startDate),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: tertiaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Mini Badge
                        if (event.tags.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.blue[900]!.withOpacity(0.5)
                                      : Colors.blue[50],
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  isDark
                                      ? Border.all(color: Colors.blue[300]!)
                                      : null,
                            ),
                            child: Text(
                              event.tags.first,
                              style: TextStyle(
                                fontSize: 9,
                                color:
                                    isDark
                                        ? Colors.blue[100]
                                        : Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _highlightText(String text, String query, TextStyle style) {
    if (query.isEmpty)
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );

    final lower = text.toLowerCase();
    final q = query.toLowerCase();
    final start = lower.indexOf(q);

    if (start == -1)
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );

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
