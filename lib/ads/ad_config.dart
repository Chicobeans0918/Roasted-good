/// AdMob configuration.
///
/// Currently wired with Google's official TEST ids, so banners load
/// immediately during development. To monetize:
///   1. Create an AdMob account (admob.com) and register the Roasted iOS app.
///   2. Create a banner ad unit and replace the two ids below.
///   3. Put the real app id in ios/Runner/Info.plist (GADApplicationIdentifier).
abstract final class AdConfig {
  /// Test only — replace with the real AdMob app id.
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';

  /// Test only — replace with the real banner ad unit id.
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/2934735716';

  /// Test only — replace with the real interstitial ad unit id.
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/4411468910';

  /// True while the ids above are Google's test ids.
  static const bool usingTestAds = true;
}
