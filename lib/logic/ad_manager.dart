import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AdManager {
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;

  // Tu ID de Video Recompensado
  static const String rewardedId = "ca-app-pub-9272507949753552/7159352634";

  // Carga el anuncio en segundo plano
  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _rewardedAd = null;
          // Reintenta cargar después de 10 segundos si falla
          Future.delayed(const Duration(seconds: 10), () => loadRewardedAd());
        },
      ),
    );
  }

  // Lógica principal: Muestra el video o entrega la recompensa
  static void showRewardedAd({required Function onRewardEarned}) {
    var settingsBox = Hive.box('settings');
    bool isPremium = settingsBox.get('isPremium', defaultValue: false);

    // Si es Premium, no hay videos
    if (isPremium) {
      onRewardEarned();
      return;
    }

    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          loadRewardedAd(); // Pre-carga el siguiente
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          loadRewardedAd();
          onRewardEarned(); // Si falla el anuncio, damos el número para no frustrar al usuario
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onRewardEarned(); // Aquí se entrega la suerte
      });
    } else {
      // Si el anuncio aún no carga, damos el número por esta vez
      onRewardEarned();
      loadRewardedAd();
    }
  }
}