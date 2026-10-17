import 'package:google_mobile_ads/google_mobile_ads.dart' as ads;
import 'package:shared_preferences/shared_preferences.dart';

import 'ad_config.dart';

/// Capped interstitial ads: shown at most once per calendar day and at
/// most once per app session, only at natural break points (e.g. right
/// after a tasting is logged). Preloads the next ad after each show or
/// failure so one is usually ready.
class InterstitialManager {
  InterstitialManager._();

  static final InterstitialManager instance = InterstitialManager._();

  static const _lastShownKey = 'roasted_interstitial_last_shown';

  ads.InterstitialAd? _ad;
  bool _shownThisSession = false;
  bool _loading = false;

  /// Starts preloading. Called once at startup.
  void preload() => _load();

  void _load() {
    if (_loading || _ad != null) return;
    _loading = true;
    ads.InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const ads.AdRequest(),
      adLoadCallback: ads.InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loading = false;
          _ad = ad;
          ad.fullScreenContentCallback = ads.FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _ad = null;
              _load();
            },
            onAdFailedToShowFullScreenContent: (ad, _) {
              ad.dispose();
              _ad = null;
              _load();
            },
          );
        },
        onAdFailedToLoad: (_) => _loading = false,
      ),
    );
  }

  /// Shows the interstitial if the caps allow it. Safe to call from any
  /// break point — it no-ops when capped or when no ad is ready.
  Future<void> maybeShow() async {
    if (_shownThisSession) return;
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final last = prefs.getString(_lastShownKey);
    if (last != null) {
      final parsed = DateTime.tryParse(last);
      if (parsed != null &&
          parsed.year == today.year &&
          parsed.month == today.month &&
          parsed.day == today.day) {
        return; // already shown today
      }
    }
    final ad = _ad;
    if (ad == null) {
      _load();
      return;
    }
    _ad = null;
    _shownThisSession = true;
    await prefs.setString(_lastShownKey, today.toIso8601String());
    try {
      ad.show();
    } catch (_) {
      ad.dispose();
    }
    _load();
  }
}
