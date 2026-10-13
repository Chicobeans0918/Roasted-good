import '../models/coffee_bean.dart';

/// Maps every catalogue bean to one of the bundled photorealistic bean
/// photos in assets/beans/. Assignment cycles through roast-appropriate
/// photos so no two adjacent catalogue beans share the same photo.
/// Unknown ids (e.g. future Firestore beans) fall back by roast level.
const Map<String, String> _photoByBeanId = {
  // Light roast.
  'bbcr-ethiopia': 'light_roast_beans.jpg',
  'bbcr-brazil': 'light_roast_bowl.jpg',
  'bbcr-mexico': 'light_roast_texture.jpg',
  // Medium roast.
  'bbcr-house-blend': 'medium_roast_beans.jpg',
  'bbcr-espresso-blend': 'medium_roast_burlap.jpg',
  'bbcr-guatemala': 'medium_roast_scatter.jpg',
  'bbcr-tanzania-peaberry': 'beans_pouring.jpg',
  // Medium-dark roast.
  'bbcr-colombia': 'medium_dark_beans.jpg',
  'bbcr-sweet-spot': 'medium_dark_beans.jpg',
  'bbcr-decaf-colombia': 'medium_dark_beans.jpg',
  // Dark roast.
  'bbcr-dark-roast': 'dark_roast_beans.jpg',
  'bbcr-sumatra': 'dark_roast_bowl.jpg',
};

/// Asset path of the photo for [bean], e.g. 'assets/beans/dark_roast_beans.jpg'.
String beanPhotoAsset(CoffeeBean bean) {
  final file = _photoByBeanId[bean.id] ?? _fallbackForRoast(bean.roastLevel);
  return 'assets/beans/$file';
}

String _fallbackForRoast(String roastLevel) {
  switch (roastLevel.toLowerCase()) {
    case 'light':
      return 'light_roast_beans.jpg';
    case 'dark':
      return 'dark_roast_beans.jpg';
    case 'medium-dark':
      return 'medium_dark_beans.jpg';
    default:
      return 'medium_roast_beans.jpg';
  }
}
