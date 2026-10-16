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
    this.imageUrl,
    this.barcode,
    this.whereToBuy,
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

  /// Optional remote photo URL (e.g. from Firestore). When set, the app
  /// shows this image instead of the bundled photo — so bean pictures can
  /// be updated without a new build.
  final String? imageUrl;

  /// Optional retail barcode (UPC/EAN) printed on the bag. When set,
  /// scanning the bag resolves straight to this bean.
  final String? barcode;

  /// Where the beans can be bought, e.g. a shop name or website.
  /// Shown in the bean detail sheet.
  final String? whereToBuy;

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
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (barcode != null) 'barcode': barcode,
        if (whereToBuy != null) 'whereToBuy': whereToBuy,
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
      imageUrl: map['imageUrl'] as String?,
      barcode: map['barcode'] as String?,
      whereToBuy: map['whereToBuy'] as String?,
    );
  }
}
