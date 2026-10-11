/// A coffee shop / roastery that carries beans.
class CoffeeShop {
  const CoffeeShop({
    required this.id,
    required this.name,
    required this.address,
    this.latitude,
    this.longitude,
    this.approximate = false,
  });

  final String id;
  final String name;
  final String address;
  final double? latitude;
  final double? longitude;

  /// True when the pin is an approximate neighbourhood location,
  /// not the exact storefront.
  final bool approximate;

  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'approximate': approximate,
      };

  factory CoffeeShop.fromMap(Map<String, dynamic> map, String id) {
    return CoffeeShop(
      id: id,
      name: (map['name'] ?? '') as String,
      address: (map['address'] ?? '') as String,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      approximate: (map['approximate'] ?? false) as bool,
    );
  }
}
