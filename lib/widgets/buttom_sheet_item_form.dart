import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/home_controller.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/widgets/color_picker_widget.dart';
import 'package:prior_list/widgets/text_form_primary.dart';

class ButtomSheetItemForm extends StatelessWidget {
  const ButtomSheetItemForm({super.key});

  @override
  Widget build(BuildContext context) {
    final priorListController = autoInjector.get<PriorListController>();
    final coinscontroller = autoInjector.get<CoinsController>();
    final homeController = autoInjector.get<HomeController>();

    final formKey = GlobalKey<FormState>();

    return BottomSheet(
      onClosing: () {},
      animationController: AnimationController(
        vsync: Scaffold.of(context),
        duration: const Duration(milliseconds: 300),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'form.title'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Gap(20),
                  TextFormPrimary(
                    label: 'form.name.label'.tr(),
                    hintText: 'form.name.hint'.tr(),
                    controller: priorListController.nomeController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'form.name.validation'.tr();
                      }
                      return null;
                    },
                  ),
                  Gap(10),
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
                          SnackBar(
                            content: Text(
                              'form.notification.validation_future'.tr(),
                            ),
                          ),
                        );
                        return;
                      }

                      priorListController.dateController.text = DateFormat(
                        'dd/MM/yyyy HH:mm',
                      ).format(selectedDateTime);
                    },
                  ),
                  Gap(10),
                  TextFormPrimary(
                    label: 'form.link.label'.tr(),
                    hintText: 'form.link.hint'.tr(),
                    controller: priorListController.linkUrlController,
                  ),
                  Gap(15),
                  Text('form.priority.label'.tr()),
                  Gap(5),
                  ValueListenableBuilder(
                    valueListenable: priorListController.priorityForm,
                    builder: (context, priority, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: PriorType.values.map((priorType) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                            ),
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
                  Gap(20),
                  ColorPickerWidget(controller: priorListController),
                  Gap(20),
                  ElevatedButton(
                    onPressed: coinscontroller.hasEnoughToAddItem
                        ? () {
                            if (formKey.currentState?.validate() ?? false) {
                              priorListController.addItem();
                              homeController.isAdding.value = false;
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('create'.tr()),
                        Gap(20),
                        Text(coinscontroller.costToAddItem.toString()),
                        Gap(5),
                        SvgPicture.asset(
                          'assets/icons/coin.svg',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  Gap(20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
