class PlaceModel {
  final String title;
  final String id;
  final double latitude;
  final double longitude;
  final String address;

  PlaceModel({
    required this.title,
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      title: json['display_name']?.split(',')?.first ?? '',
      id: json['place_id'] ?? '',
      latitude: double.tryParse(json['lat'] ?? '0') ?? 0.0,
      longitude: double.tryParse(json['lon'] ?? '0') ?? 0.0,
      address: json['display_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': address,
      'place_id': id,
      'lat': latitude.toString(),
      'lon': longitude.toString(),
    };
  }
}