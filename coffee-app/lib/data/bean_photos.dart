import '../models/coffee_bean.dart';

/// Maps every catalogue bean to one of the bundled photorealistic bean
/// photos in assets/beans/. Assignment cycles through roast-appropriate
/// photos so no two adjacent catalogue beans share the same photo.
/// Unknown ids (e.g. future Firestore beans) fall back by roast level.
const Map<String, String> _photoByBeanId = {
  // Light roast.
  'yirgacheffe-dawn': 'light_roast_beans.jpg',
  'kenya-aa': 'light_roast_bowl.jpg',
  'costa-rica-tarrazu': 'light_roast_texture.jpg',
  'huila-pink-bourbon': 'light_roast_bowl.jpg',
  'kilimbi-hill': 'light_roast_texture.jpg',
  'happy-goat-yirgacheffe': 'light_roast_beans.jpg',
  'brown-bag-ethiopian': 'light_roast_bowl.jpg',
  'morning-owl-ethiopian-natural': 'light_roast_texture.jpg',
  'kafia-guji': 'light_roast_beans.jpg',
  // Medium roast.
  'huila-reserve': 'medium_roast_beans.jpg',
  'brazil-cerrado': 'medium_roast_burlap.jpg',
  'guatemala-antigua': 'medium_roast_scatter.jpg',
  'decaf-colombia': 'medium_roast_beans.jpg',
  'kona-peaberry': 'medium_roast_burlap.jpg',
  'blue-mountain': 'medium_roast_scatter.jpg',
  'chiapas-cloud': 'medium_roast_beans.jpg',
  'happy-goat-huila': 'medium_roast_burlap.jpg',
  'morning-owl-colombian': 'medium_roast_scatter.jpg',
  'artery-colombia-rwanda': 'medium_roast_beans.jpg',
  'aladdin-house-blend': 'medium_roast_burlap.jpg',
  'poppa-bean-seasonal': 'beans_pouring.jpg',
  // Medium-dark.
  'brown-bag-espresso-blend': 'medium_dark_beans.jpg',
  // Dark roast.
  'sumatra-night': 'dark_roast_beans.jpg',
  'santos-gold': 'dark_roast_bowl.jpg',
  'harrar-bold': 'dark_roast_beans.jpg',
  'celebes-kalosi': 'dark_roast_bowl.jpg',
  'kafia-sumatra': 'dark_roast_beans.jpg',
  'aladdin-sumatra-dark': 'dark_roast_bowl.jpg',
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
