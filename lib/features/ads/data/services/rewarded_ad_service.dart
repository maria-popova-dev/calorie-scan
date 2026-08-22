import 'dart:io';
import 'package:yandex_mobileads/mobile_ads.dart';

class RewardedAdService {
  static const _androidAdUnitId = 'R-M-19784464-1';
  static const _iosAdUnitId = 'R-M-19785277-2';

  static String get _adUnitId => Platform.isIOS ? _iosAdUnitId : _androidAdUnitId;

  final _adLoader = RewardedAdLoader();

  Future<bool> loadAndShow({required void Function() onReward}) async {
    try {
      final ad = await _adLoader.loadAd(
        adRequest: AdRequest(adUnitId: _adUnitId),
      );

      ad.setAdEventListener(
        eventListener: RewardedAdEventListener(
          onAdShown: () {},
          onAdFailedToShow: (_) {},
          onAdDismissed: () {},
          onAdClicked: () {},
          onAdImpression: (_) {},
          onRewarded: (Reward reward) => onReward(),
        ),
      );

      await ad.show();
      await ad.waitForDismiss();
      return true;
    } on AdRequestError {
      return false;
    }
  }
}