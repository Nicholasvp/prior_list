import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/ad_mob_controller.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/views/prior_list/prior_list_builder.dart';
import 'package:prior_list/models/item_model.dart';
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
  String query = '';
  final priorListController = autoInjector.get<PriorListController>();
  final adMobController = autoInjector.get<AdMobController>();
  final coinsController = autoInjector.get<CoinsController>();

  @override
  void didChangeDependencies() async {
    coinsController.fetchCoins();
    adMobController.loadRewardedAd();
    await priorListController.getList();
    priorListController.changeStatus('pending');
    super.didChangeDependencies();
  }

  void openSortModal() {
    showDialog(
      context: context,
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: priorListController.sortType,
          builder: (context, active, child) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Data
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedCalendar01,
                        color: active == 'date' ? Colors.blue : Colors.black,
                      ),
                      onPressed: () {
                        priorListController.changeSort('date');
                        Navigator.pop(context);
                      },
                    ),
                    // Nome (alfabética)
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrangeByLettersAZ,
                        color: active == 'name' ? Colors.blue : Colors.black,
                      ),
                      onPressed: () {
                        priorListController.changeSort('name');
                        Navigator.pop(context);
                      },
                    ),
                    // Prioridade
                    IconButton(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedTemperature,
                        color: active == 'priority'
                            ? Colors.blue
                            : Colors.black,
                      ),
                      onPressed: () {
                        priorListController.changeSort('priority');
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        endDrawer:  AppDrawer(),
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
                  }
                ),
              ],
            ),
            SearchMenu(
              priorListController: priorListController,
              searchController: searchController,
              onSearchChanged: (val) {
                setState(() => query = val);
                priorListController.search(query);
              },
              onFilterPressed: openSortModal,
            ),
            Gap(8),
            ChoiceFilterMenu(),
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
      ),
    );
  }
}




