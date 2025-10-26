class Hospital {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String? phone;
  final double? rating;
  final bool hasBloodBank;
  final double? distance; // in kilometers

  Hospital({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phone,
    this.rating,
    required this.hasBloodBank,
    this.distance,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Hospital',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      address: json['address'] ?? 'No address',
      phone: json['phone'],
      rating: json['rating']?.toDouble(),
      hasBloodBank: json['hasBloodBank'] ?? false,
    );
  }
}
