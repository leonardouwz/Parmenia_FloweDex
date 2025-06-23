class Plant {
  final String id;
  final String name;
  final String species;
  final String imageUrl;
  final DateTime lastWatered;
  final int wateringFrequency; // días
  final String notes;
  final String userId;

  Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.imageUrl,
    required this.lastWatered,
    required this.wateringFrequency,
    required this.notes,
    required this.userId,
  });

  factory Plant.fromMap(Map<String, dynamic> map, String id) {
    return Plant(
      id: id,
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      lastWatered: DateTime.fromMillisecondsSinceEpoch(map['lastWatered']),
      wateringFrequency: map['wateringFrequency'] ?? 7,
      notes: map['notes'] ?? '',
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'imageUrl': imageUrl,
      'lastWatered': lastWatered.millisecondsSinceEpoch,
      'wateringFrequency': wateringFrequency,
      'notes': notes,
      'userId': userId,
    };
  }

  bool get needsWatering {
    return DateTime.now().difference(lastWatered).inDays >= wateringFrequency;
  }
}