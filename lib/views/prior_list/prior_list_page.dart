import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:prior_list/controllers/ad_mob_controller.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/views/prior_list/prior_list_builder.dart';
import 'package:prior_list/models/item_model.dart';

class PriorListPage extends StatefulWidget {
  const PriorListPage({super.key});

  @override
  State<PriorListPage> createState() => _PriorListPageState();
}

class _PriorListPageState extends State<PriorListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final priorListController = autoInjector.get<PriorListController>();
  final adMobController = autoInjector.get<AdMobController>();
  final coinsController = autoInjector.get<CoinsController>();

  @override
  void didChangeDependencies() {
    coinsController.fetchCoins();
    adMobController.loadRewardedAd();
    super.didChangeDependencies();
  }

  void _openSortModal() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    priorListController.sortItems('date');
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedArrangeByLettersAZ,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    priorListController.sortItems('alphabetical');
                    Navigator.pop(context);
                  },
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedTemperature,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    priorListController.sortItems('priority');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (priorListController.items.value.isEmpty &&
        !priorListController.isLoadingNotifier.value) {
      priorListController.getList();
    }

    return SafeArea(
      child: Column(
        children: [
          MenuCoins(coinsController: coinsController, adMobController: adMobController),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'search'.tr(),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedSearchCircle,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() => _query = val);
                      priorListController.search(_query);
                    },
                  ),
                ),
                IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedFilter,
                    color: Colors.black,
                  ),
                  onPressed: _openSortModal,
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: priorListController.state,
              builder: (context, value, child) {
                if (priorListController.isLoadingNotifier.value) {
                  return const Center(child: CircularProgressIndicator());
                } else if (priorListController.hasErrorNotifier.value) {
                  return Center(child: Text('error_loading_data'.tr()));
                } else if (priorListController.items.value.isEmpty) {
                  return Center(child: Text('no_items_found'.tr()));
                } else {
                  List<ItemModel> items = priorListController.items.value;
                  if (items.isEmpty) {
                    return Center(child: Text('no_items_match_search'.tr()));
                  }
                  return PriorListBuilder(items: items);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Row(
      children: [
        Gap(20),
        SvgPicture.asset('assets/icons/coin.svg', width: 32, height: 32),
        Padding(
          padding: const EdgeInsets.all(12),
          child: ValueListenableBuilder(
            valueListenable: coinsController.coins,
            builder: (context, value, child) {
              return Text(
                coinsController.coins.value.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        IconButton(
          onPressed: () {
            adMobController.showRewardedAd(
              onUserEarnedReward: () {
                coinsController.addCoin(5);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Você ganhou 5 moedas!')),
                );
              },
            );
          },
          icon: const HugeIcon(
            icon: HugeIconsStrokeRounded.addCircle,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
