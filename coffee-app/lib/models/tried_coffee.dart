/// A logged tasting of a coffee bean: which brew method was used,
/// the 1–5 star rating, whether the user liked it overall, and a note.
class TriedCoffee {
  const TriedCoffee({
    required this.id,
    required this.beanId,
    required this.brewMethod,
    required this.rating,
    required this.liked,
    this.note = '',
    required this.date,
  });

  /// Client-generated id, also used as the Firestore document id.
  final String id;
  final String beanId;
  final String brewMethod;

  /// Star rating, 1–5.
  final double rating;

  /// Whether the user liked the coffee overall.
  final bool liked;

  final String note;
  final DateTime date;

  /// Brewing methods offered in the tasting form.
  static const List<String> brewMethods = [
    'V60',
    'French press',
    'Espresso',
    'AeroPress',
    'Moka pot',
    'Drip',
    'Other',
  ];

  /// Generates a unique tasting id for a new log entry.
  static String newId() => 't_${DateTime.now().microsecondsSinceEpoch}';

  Map<String, dynamic> toMap() => {
        'beanId': beanId,
        'brewMethod': brewMethod,
        'rating': rating,
        'liked': liked,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory TriedCoffee.fromMap(Map<String, dynamic> map, String id) {
    return TriedCoffee(
      id: id,
      beanId: (map['beanId'] ?? '') as String,
      brewMethod: (map['brewMethod'] ?? 'Other') as String,
      rating: ((map['rating'] as num?) ?? 0).toDouble(),
      liked: (map['liked'] ?? true) as bool,
      note: (map['note'] ?? '') as String,
      date: DateTime.tryParse((map['date'] ?? '') as String) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
