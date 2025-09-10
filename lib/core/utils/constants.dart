import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static final String locationIqApiKey = dotenv.env['LOCATION_IQ_KEY'].toString();
  static const String locationIqSearchBaseUrl = 'https://us1.locationiq.com/v1/search';
}