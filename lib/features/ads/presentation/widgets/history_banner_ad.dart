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
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadBanner());
    }
  }

  Future<void> _loadBanner() async {
    if (!mounted) return;
    final windowWidth = MediaQuery.of(context).size.width;
    final adSize = BannerAdSize.sticky(width: windowWidth.toInt());

    if (!mounted) return;
    final banner = BannerAd(adSize: adSize);
    _loadStateSubscription = banner.loadStateStream.listen((state) {
      debugPrint('BANNER STATE: $state');
      if (!mounted) return;
      if (state is BannerAdLoadStateLoaded) {
        setState(() => _loaded = true);
      } else if (state is BannerAdLoadStateError) {
        setState(() => _loaded = false);
        debugPrint('BANNER ERROR: ${state.error.code} - ${state.error.description}');
      }
    });

    if (!mounted) {
      banner.destroy();
      return;
    }

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
    if (_banner == null || !_loaded) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.center,
      child: AdWidget(bannerAd: _banner!),
    );
  }
}