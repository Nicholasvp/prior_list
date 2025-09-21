import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/widgets/text_form_primary.dart';

class ButtomSheetItemForm extends StatelessWidget {
  const ButtomSheetItemForm({super.key});

  @override
  Widget build(BuildContext context) {
    final priorListController = autoInjector.get<PriorListController>();

    return BottomSheet(
      onClosing: () {},
      animationController: AnimationController(
        vsync: Scaffold.of(context),
        duration: const Duration(milliseconds: 300),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Item',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Gap(20),
              TextFormPrimary(
                label: 'Name',
                hintText: 'Enter the name',
                controller: priorListController.nomeController,
              ),
              Gap(10),
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date',
                  hintText: 'Select a date',
                ),
                controller: priorListController.dateController,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    priorListController.dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(pickedDate);
                  }
                },
              ),
              Gap(15),
              Text('Priority'),
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
                          label: Text(priorType.name.toUpperCase()),
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
              ElevatedButton(
                onPressed: () {
                  priorListController.addItem();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text('Submit'),
              ),
              Gap(80),
            ],
          ),
        );
      },
    );
  }
}
