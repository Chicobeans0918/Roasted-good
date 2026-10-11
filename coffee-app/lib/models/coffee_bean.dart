/// A coffee bean entry in the catalogue.
class CoffeeBean {
  const CoffeeBean({
    required this.id,
    required this.name,
    required this.origin,
    required this.roastLevel,
    this.tastingNotes = const [],
    this.rating,
    this.description = '',
    this.local = false,
    this.roaster,
    this.decaf = false,
  });

  final String id;
  final String name;
  final String origin;

  /// e.g. 'Light', 'Medium', 'Dark', 'Medium-Dark'.
  final String roastLevel;
  final List<String> tastingNotes;

  /// The community/seed rating, 0–5. Null when unrated.
  final double? rating;

  /// One-line description shown in catalogue search results.
  final String description;

  /// True for beans from Gatineau-Ottawa roasters.
  final bool local;

  /// Roaster name for local beans, e.g. 'Happy Goat Coffee Co.'
  final String? roaster;

  /// True for decaffeinated beans.
  final bool decaf;

  Map<String, dynamic> toMap() => {
        'name': name,
        'origin': origin,
        'roastLevel': roastLevel,
        'tastingNotes': tastingNotes,
        if (rating != null) 'rating': rating,
        'description': description,
        'local': local,
        if (roaster != null) 'roaster': roaster,
        'decaf': decaf,
      };

  factory CoffeeBean.fromMap(Map<String, dynamic> map, String id) {
    return CoffeeBean(
      id: id,
      name: (map['name'] ?? '') as String,
      origin: (map['origin'] ?? '') as String,
      roastLevel: (map['roastLevel'] ?? 'Medium') as String,
      tastingNotes: [
        for (final n in (map['tastingNotes'] as List? ?? [])) n as String
      ],
      rating: (map['rating'] as num?)?.toDouble(),
      description: (map['description'] ?? '') as String,
      local: (map['local'] ?? false) as bool,
      roaster: map['roaster'] as String?,
      decaf: (map['decaf'] ?? false) as bool,
    );
  }
}
