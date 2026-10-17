/// AdMob configuration.
///
/// Live production ids (Marc-André's AdMob account, Oct 16 2026).
/// To go back to test ads, restore Google's test ids and set
/// [usingTestAds] back to true.
abstract final class AdConfig {
  /// Roasted iOS app id (AdMob).
  static const String appId = 'ca-app-pub-3048189417999433~2981230944';

  /// Banner ad unit id.
  static const String bannerAdUnitId =
      'ca-app-pub-3048189417999433/4850961792';

  /// Interstitial ad unit id.
  static const String interstitialAdUnitId =
      'ca-app-pub-3048189417999433/4583368482';

  /// True while the ids above are Google's test ids.
  static const bool usingTestAds = false;
}
