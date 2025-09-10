import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../models/place_model.dart';

class PlaceListItem extends StatelessWidget {
  final PlaceModel place;
  final String query;

  const PlaceListItem({
    Key? key,
    required this.place,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      title: _buildHighlightedText(place.title, query, context),
      leading: const Icon(Icons.place_outlined),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildHighlightedText(place.address, query, context),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.directions),
        onPressed: () => _openInGoogleMaps(context),
      ),
    );
  }

  Widget _buildHighlightedText(String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return Text(text);
    }

    final baseStyle = DefaultTextStyle.of(context).style;
    final escapedQuery = RegExp.escape(query);
    final regExp = RegExp(escapedQuery, caseSensitive: false);
    final matches = regExp.allMatches(text);

    if (matches.isEmpty) {
      return Text(text, style: baseStyle);
    }

    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: baseStyle.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final coords = '${place.latitude},${place.longitude}';
    final String mapUrl = 'https://www.google.com/maps/dir/?api=1&destination=$coords';

    if (await canLaunchUrlString(mapUrl)) {
      await launchUrlString(mapUrl);
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Navigation Error'),
            content: const Text('Could not open maps. Please make sure you have a maps app installed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}