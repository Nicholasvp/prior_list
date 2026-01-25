import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
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
  
  final  priorListController = autoInjector.get<PriorListController>();
  final coinsController = autoInjector.get<CoinsController>();

  @override
  void initState() {
    super.initState();

    priorListController.populateForEdit(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: priorListController.nomeController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              readOnly: true,
              controller: priorListController.dateController,
              decoration: InputDecoration(
                labelText: 'form.date.label'.tr(),
                hintText: 'form.date.hint'.tr(),
                suffixIcon: const Icon(Icons.calendar_today),
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
            ValueListenableBuilder<String>(
              valueListenable: priorListController.priorityForm,
              builder: (context, value, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PriorType.values.map((priorType) {
                      final name = priorType.name;
                      return ChoiceChip(
                        label: Text(name.toUpperCase()),
                        selected: value == name,
                        onSelected: (selected) {
                          if (selected) {
                            priorListController.priorityForm.value = name;
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ColorPickerWidget(controller: priorListController),
            const SizedBox(height: 24),
            ElevatedButton(
              
              onPressed: coinsController.hasEnoughToEditItem? () async {
                await priorListController.editItem(widget.item.id);
                Navigator.of(context).pop();
              } : null,
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
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
