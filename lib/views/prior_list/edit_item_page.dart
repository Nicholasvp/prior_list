import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/widgets/color_picker_widget.dart';

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
      appBar: AppBar(title: Text('edit_item'.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: priorListController.nomeController,
              decoration: InputDecoration(labelText: 'title'.tr()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: priorListController.dateController,
              decoration: InputDecoration(
                labelText: 'form.notification.label'.tr(),
                hintText: 'form.notification.hint'.tr(),
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: Colors.black,
                  ),
                ),
              ),
              onTap: () async {
                final now = DateTime.now();

                DateTime initialDateTime = now;
                if (priorListController.dateController.text.isNotEmpty) {
                  try {
                    initialDateTime = DateFormat(
                      'dd/MM/yyyy HH:mm',
                    ).parse(priorListController.dateController.text);
                  } catch (_) {}
                }

                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDateTime,
                  firstDate: now,
                  lastDate: DateTime(2100),
                );

                if (pickedDate == null) return;

                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(initialDateTime),
                );

                if (pickedTime == null) return;

                final selectedDateTime = DateTime(
                  pickedDate.year,
                  pickedDate.month,
                  pickedDate.day,
                  pickedTime.hour,
                  pickedTime.minute,
                );

                if (selectedDateTime.isBefore(now)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('form.date.validation_future'.tr())),
                  );
                  return;
                }

                priorListController.dateController.text = DateFormat(
                  'dd/MM/yyyy HH:mm',
                ).format(selectedDateTime);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priorListController.linkUrlController,
              decoration: const InputDecoration(labelText: 'Link URL'),
            ),
            const SizedBox(height: 12),
            Text('form.priority.label'.tr()),
            Gap(5),
            ValueListenableBuilder(
              valueListenable: priorListController.priorityForm,
              builder: (context, priority, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: PriorType.values.map((priorType) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text('priority.${priorType.name}'.tr()),
                        selected: priority == priorType.name,
                        onSelected: (bool selected) {
                          priorListController.priorityForm.value =
                              priorType.name;
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            Gap(12),
            ColorPickerWidget(controller: priorListController),
            Gap(24),
            ElevatedButton(
              onPressed: coinsController.hasEnoughToEditItem
                  ? () async {
                      await priorListController.editItem(widget.item);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('edit'.tr()),
                  Gap(20),
                  Text(coinsController.costToEditItem.toString()),
                  Gap(5),
                  SvgPicture.asset(
                    'assets/icons/coin.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ),
            ),
            Gap(12),
            OutlinedButton(
              onPressed: coinsController.hasEnoughToRemoveItem
                  ? () async {
                      await priorListController.deleteItem(
                        widget.item.id,
                        context,
                      );
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('delete'.tr()),
                  Gap(20),
                  Text(coinsController.costToRemoveItem.toString()),
                  Gap(5),
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
