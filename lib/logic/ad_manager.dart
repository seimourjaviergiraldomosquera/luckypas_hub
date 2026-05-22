import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AdManager {
  static RewardedAd? _rewardedAd;
  static bool _isAdLoaded = false;
  static bool _isLoading = false; // AÑADIDO: Evita solicitudes de carga duplicadas

  // =========================================================================
  // MODO DESARROLLO SEGURO
  // Deja esto en 'true' para hacer pruebas sin riesgos en emulador o celular.
  // Cámbialo a 'false' únicamente cuando vayas a subir la app final a la Play Store.
  static const bool isDevelopmentMode = true;
  // =========================================================================

  // ID de Video Recompensado (Alterna automáticamente según el modo)
  static const String rewardedId = isDevelopmentMode
      ? "ca-app-pub-3940256099942544/5224354917"  // ID de prueba universal de Google
      : "ca-app-pub-9272507949753552/7159352634"; // Tu ID real de LuckyPass Hub

  // Carga el anuncio en segundo plano
  static void loadRewardedAd() {
    if (_isLoading || _rewardedAd != null) return; // AÑADIDO: Control de hilos seguro
    _isLoading = true;

    RewardedAd.load(
      adUnitId: rewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isAdLoaded = true;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isAdLoaded = false;
          _rewardedAd = null;
          _isLoading = false;
          // Reintenta cargar después de 10 segundos si falla
          Future.delayed(const Duration(seconds: 10), () => loadRewardedAd());
        },
      ),
    );
  }

  // MODIFICADO: Lógica principal blindada. Ahora requiere el callback obligatorio si no hay anuncio disponible.
  static void showRewardedAd({
    required Function onRewardEarned,
    required Function onAdNotAvailable // AÑADIDO: Callback de bloqueo estricto
  }) {
    var settingsBox = Hive.box('settings');
    bool isPremium = settingsBox.get('isPremium', defaultValue: false);

    // Si es Premium, saltamos los videos de inmediato
    if (isPremium) {
      onRewardEarned();
      return;
    }

    if (_isAdLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isAdLoaded = false;
          _rewardedAd = null;
          loadRewardedAd(); // Pre-carga el siguiente
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
          _rewardedAd = null;
          onAdNotAvailable(); // MODIFICADO: Si se cae la red a mitad de camino, bloqueamos.
          loadRewardedAd();
        },
      );

      _rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        onRewardEarned(); // Aquí se entrega la suerte tras ver el video entero
      });
    } else {
      // MODIFICADO: Si apagan datos o el video no está listo, disparamos el bloqueo estricto
      onAdNotAvailable();
      loadRewardedAd();
    }
  }
}