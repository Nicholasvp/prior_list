import 'package:flutter/foundation.dart'; // para debugPrint
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobController  { // opcional: use ChangeNotifier se quiser rebuild UI ao carregar
  RewardedAd? _rewardedAd;
  final isLoadingNotifier = ValueNotifier(false);
  bool get isLoading => isLoadingNotifier.value;
  set isLoading(bool value) => isLoadingNotifier.value = value;

  // Getter para checar se o ad está pronto
  bool get isAdReady => _rewardedAd != null;

  void loadRewardedAd() {
    if (isLoading) return; // evita load duplicado
    isLoading = true;

    RewardedAd.load(
      adUnitId: kDebugMode
          ? 'ca-app-pub-4279139452834583/5099046608' // test ID
          : 'ca-app-pub-4279139452834583/5099046608', // troque quando for publicar
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('Rewarded ad loaded successfully');
          _rewardedAd = ad;
          isLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('Rewarded ad failed to load: $error');
          _rewardedAd = null;
          isLoading = false;
          // Opcional: tente recarregar após delay
          Future.delayed(const Duration(seconds: 1), loadRewardedAd);
        },
      ),
    );
  }

  void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdDismissed, // opcional
  }) {
    if (_rewardedAd == null) {
      debugPrint('Rewarded ad not loaded yet. Loading...');
      loadRewardedAd();
      return;
    }

    // Configura callbacks de lifecycle
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad showed full screen');
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('Rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        showRewardedAd(onUserEarnedReward: onUserEarnedReward, onAdDismissed: onAdDismissed); // tenta novamente
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // preload próximo
        onAdDismissed?.call();
      },
      onAdImpression: (RewardedAd ad) => debugPrint('Ad impression recorded'),
    );

    // Mostra o ad e dá recompensa só se o usuário completar
    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward(); // ex: addCoin(5)
      },
    );

    _rewardedAd = null; // limpa após show (não reuse)
  }

  void disposeAds() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}