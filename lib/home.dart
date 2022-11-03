import 'package:addmode/service.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BannerAd? _banner;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _rewardedScore = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createBannerAd();
    _createInterstitialAd();
    _createRewardedAd();
  }

//_createBannerAd here
  _createBannerAd() async {
    _banner = BannerAd(
      size: AdSize.fullBanner,
      adUnitId: AdModService.bannerAdUnitId!,
      listener: AdModService.bannerAdListener,
      request: const AdRequest(),
    )..load();
  }
  //end

  //_createInterstitialAd start here
  void _createInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdModService.interstitialAdUnitId!,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (LoadAdError error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createInterstitialAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createInterstitialAd();
      });
      _interstitialAd!.show();
    }
  }
  //end here

  //_createRewardedAd start here
  void _createRewardedAd() {
    RewardedAd.load(
      adUnitId: AdModService.rewardedAdUnitId!,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => setState(() => _rewardedAd = ad),
        onAdFailedToLoad: (error) => setState(() => _rewardedAd = null),
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback =
          FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _createRewardedAd();
      }, onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _createRewardedAd();
      });
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) => setState(
          () => _rewardedScore++,
        ),
      );
      _rewardedAd = null;
    }
  }

//end
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(
              height: 30,
            ),
            Text("Rewarded Score is: $_rewardedScore"),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                _showInterstitialAd();
              },
              child: Text('Interstitial Ad: $_rewardedScore'),
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: () {
                _showRewardedAd();
              },
              child: const Text('Get 1 free Score'),
            ),
            const Spacer(),
            _banner == null
                ? Container()
                : Container(
                    height: 52,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: AdWidget(
                      ad: _banner!,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
