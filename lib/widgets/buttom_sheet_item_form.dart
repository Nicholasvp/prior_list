import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/home_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/widgets/item_form.dart';

class BottomSheetItemForm extends StatelessWidget {
  const BottomSheetItemForm({super.key});

  @override
  Widget build(BuildContext context) {
    final coinsController = autoInjector.get<CoinsController>();
    final homeController = autoInjector.get<HomeController>();
    final priorListController = autoInjector.get<PriorListController>();

    return BottomSheet(
      onClosing: () {},
      builder: (_) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ItemForm(
  submitLabel: 'create'.tr(),
  cost: coinsController.costToAddItem,
  isSubmitEnabled: coinsController.hasEnoughToAddItem,
  onSubmit: () {
    priorListController.addItem();
    homeController.isAdding.value = false;
  },
)
        ),
      ),
    );
  }
}
