import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/widgets/color_picker_widget.dart';
import 'package:prior_list/widgets/text_form_primary.dart';

class ItemForm extends StatelessWidget {
  final VoidCallback onSubmit;
  final String submitLabel;
  final bool isSubmitEnabled;
  final int? cost;

  const ItemForm({
    super.key,
    required this.onSubmit,
    required this.submitLabel,
    required this.isSubmitEnabled,
    this.cost,
  });

  @override
  Widget build(BuildContext context) {
    final priorListController = autoInjector.get<PriorListController>();
    final formKey = GlobalKey<FormState>();

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 NOME
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

          const Gap(10),

          /// 🔹 DATA / NOTIFICAÇÃO
          TextFormField(
            readOnly: true,
            controller: priorListController.dateController,
            decoration: InputDecoration(
              labelText: 'form.notification.label'.tr(),
              hintText: 'form.notification.hint'.tr(),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(16.0),
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

          const Gap(10),

          /// 🔹 LINK
          TextFormPrimary(
            label: 'form.link.label'.tr(),
            hintText: 'form.link.hint'.tr(),
            controller: priorListController.linkUrlController,
          ),

          const Gap(15),

          /// 🔹 PRIORIDADE
          Text('form.priority.label'.tr()),
          const Gap(5),

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

          const Gap(20),

          /// 🔹 COLOR PICKER
          ColorPickerWidget(controller: priorListController),

          const Gap(20),

          /// 🔹 SUBMIT BUTTON COM COINS
          ElevatedButton(
            onPressed: isSubmitEnabled
                ? () {
                    if (formKey.currentState?.validate() ?? false) {
                      onSubmit();
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(submitLabel),
                if (cost != null) ...[
                  const Gap(20),
                  Text(cost.toString()),
                  const Gap(5),
                  SvgPicture.asset(
                    'assets/icons/coin.svg',
                    width: 20,
                    height: 20,
                  ),
                ],
              ],
            ),
          ),

          const Gap(10),
        ],
      ),
    );
  }
}