import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/widgets/item_form.dart';

class EditItemPage extends StatefulWidget {
  final ItemModel item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  final priorListController = autoInjector.get<PriorListController>();
  final coinsController = autoInjector.get<CoinsController>();

  @override
  void initState() {
    super.initState();
    priorListController.populateForEdit(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_item'.tr()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ItemForm(
  submitLabel: 'edit'.tr(),
  cost: coinsController.costToEditItem,
  isSubmitEnabled: coinsController.hasEnoughToEditItem,
  onSubmit: () async {
    await priorListController.editItem(widget.item);
    if (context.mounted) Navigator.of(context).pop();
  },
),

            const Gap(24),

            /// 🔹 DELETE BUTTON (continua fora do form)
            OutlinedButton(
              onPressed: coinsController.hasEnoughToRemoveItem
                  ? () async {
                      await priorListController.deleteItem(
                        widget.item.id,
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('delete'.tr()),
                  const Gap(20),
                  Text(coinsController.costToRemoveItem.toString()),
                  const Gap(5),
                  SvgPicture.asset(
                    'assets/icons/coin.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}