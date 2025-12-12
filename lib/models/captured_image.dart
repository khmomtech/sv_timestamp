class CapturedImage {
  final String id;
  final String imagePath;
  final DateTime timestamp;
  final Map<String, double>? location; // latitude, longitude
  final String? address;
  final Map<String, dynamic> additionalData;

  CapturedImage({
    required this.id,
    required this.imagePath,
    required this.timestamp,
    this.location,
    this.address,
    this.additionalData = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'address': address,
      'additionalData': additionalData,
    };
  }

  factory CapturedImage.fromMap(Map<String, dynamic> map) {
    return CapturedImage(
      id: map['id'],
      imagePath: map['imagePath'],
      timestamp: DateTime.parse(map['timestamp']),
      location: map['location'] != null
          ? Map<String, double>.from(map['location'])
          : null,
      address: map['address'],
      additionalData: Map<String, dynamic>.from(map['additionalData']),
    );
  }
}
