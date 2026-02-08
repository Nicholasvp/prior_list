import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:prior_list/controllers/ad_mob_controller.dart';
import 'package:prior_list/controllers/coins_controller.dart';

class MenuCoins extends StatelessWidget {
  const MenuCoins({
    super.key,
    required this.coinsController,
    required this.adMobController,
  });

  final CoinsController coinsController;
  final AdMobController adMobController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: adMobController.isLoadingNotifier,
      builder: (context, isLoading, _) {
        final isReady = adMobController.isAdReady;

        return Row(
          children: [
            const Gap(20),
            SvgPicture.asset(
              'assets/icons/coin.svg',
              width: 32,
              height: 32,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ValueListenableBuilder(
                valueListenable: coinsController.coins,
                builder: (_, value, __) {
                  return Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),

            /// 🎯 ESTADOS DO REWARD
            if (isReady)
              IconButton(
                onPressed: () {
                  adMobController.showRewardedAd(
                    onUserEarnedReward: () {
                      coinsController.addCoins(coinsController.reward);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'message_reward'.tr(
                              namedArgs: {
                                'coins': coinsController.reward.toString(),
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const HugeIcon(
                  icon: HugeIconsStrokeRounded.addCircle,
                  color: Colors.black,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}