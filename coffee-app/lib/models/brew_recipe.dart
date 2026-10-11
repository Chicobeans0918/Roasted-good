/// A saved brewing recipe attached to a bean (or the user's shelf).
class BrewRecipe {
  const BrewRecipe({
    required this.id,
    required this.name,
    required this.method,
    required this.ratio,
    required this.grind,
    required this.temperatureC,
    required this.brewTime,
    this.beanId,
  });

  final String id;
  final String name;
  final String method;
  final String ratio;
  final String grind;
  final String temperatureC;
  final String brewTime;

  /// Optional link to a bean this recipe was dialed in for.
  final String? beanId;
}
