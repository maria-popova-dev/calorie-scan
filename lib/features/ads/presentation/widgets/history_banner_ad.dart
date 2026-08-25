import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

class HistoryBannerAd extends StatefulWidget {
  const HistoryBannerAd({super.key});

  @override
  State<HistoryBannerAd> createState() => _HistoryBannerAdState();
}

class _HistoryBannerAdState extends State<HistoryBannerAd> {
  static const _androidAdUnitId = 'R-M-19784464-2';
  static const _iosAdUnitId = 'R-M-19785277-1';

  static String get _adUnitId => Platform.isIOS ? _iosAdUnitId : _androidAdUnitId;

  BannerAd? _banner;
  StreamSubscription<BannerAdLoadState>? _loadStateSubscription;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanner());
    }
  }

  void _loadBanner() {
    if (!mounted) return;
    final windowWidth = MediaQuery.of(context).size.width;
    final adSize = BannerAdSize.sticky(width: windowWidth.toInt());

    final banner = BannerAd(adSize: adSize);
    _loadStateSubscription = banner.loadStateStream.listen((state) {
      debugPrint('BANNER STATE: $state');
      if (state is BannerAdLoadStateError) {
        debugPrint('BANNER ERROR: ${state.error.code} - ${state.error.description}');
      }
    });

    // Показываем AdWidget сразу, не дожидаясь Loaded — иначе баннер
    // физически не может начать грузиться (нужен platform view из AdWidget).
    setState(() => _banner = banner);
    banner.load(AdRequest(adUnitId: _adUnitId));
  }

  @override
  void dispose() {
    _loadStateSubscription?.cancel();
    final banner = _banner;
    if (banner != null) {
      banner.destroy().catchError((_) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (banner == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
      child: AdWidget(bannerAd: banner),
    );
  }
}