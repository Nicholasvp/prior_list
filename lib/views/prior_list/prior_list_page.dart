import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:prior_list/controllers/ad_mob_controller.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/views/prior_list/prior_list_builder.dart';
import 'package:prior_list/widgets/app_drawer.dart';
import 'package:prior_list/widgets/choice_filter_menu.dart';
import 'package:prior_list/widgets/menu_coins.dart';
import 'package:prior_list/widgets/search_menu.dart';

class PriorListPage extends StatefulWidget {
  const PriorListPage({super.key});

  @override
  State<PriorListPage> createState() => _PriorListPageState();
}

class _PriorListPageState extends State<PriorListPage> {
  final TextEditingController searchController = TextEditingController();

  final priorListController = autoInjector.get<PriorListController>();
  final adMobController = autoInjector.get<AdMobController>();
  final coinsController = autoInjector.get<CoinsController>();

  @override
  void initState() {
    super.initState();

    coinsController.fetchCoins();
    adMobController.loadRewardedAd();

    // 🔥 agora usa stream do Firebase
    priorListController.listenTasks();

    priorListController.changeStatus('pending');
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MenuCoins(
                  coinsController: coinsController,
                  adMobController: adMobController,
                ),
                Builder(
                  builder: (context) {
                    return DrawerButton(
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    );
                  },
                ),
              ],
            ),

            SearchMenu(
              priorListController: priorListController,
              searchController: searchController,
              onSearchChanged: (val) {
                priorListController.search(val);
              },
            ),

            const Gap(8),
            ChoiceFilterMenu(),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: priorListController.state,
                builder: (context, value, child) {
                  if (priorListController.isLoadingNotifier.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (priorListController.hasErrorNotifier.value) {
                    return Center(child: Text('error_loading_data'.tr()));
                  }

                  final items = priorListController.items.value;

                  if (items.isEmpty) {
                    return Center(child: Text('no_items_found'.tr()));
                  }

                  return PriorListBuilder(items: items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}