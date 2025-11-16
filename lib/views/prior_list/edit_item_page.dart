import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/enums/enums.dart';

class EditItemPage extends StatefulWidget {
  final ItemModel item;

  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late final PriorListController controller;

  @override
  void initState() {
    super.initState();
    controller = autoInjector.get<PriorListController>();
    // populate controllers with item data
    controller.populateForEdit(widget.item);
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
              controller: controller.nomeController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              controller: controller.dateController,
              decoration: const InputDecoration(labelText: 'Date (dd/MM/yyyy)'),
              onTap: () async {
                DateTime initialDate = DateTime.now();
                if (controller.dateController.text.isNotEmpty) {
                  try {
                    initialDate = DateFormat(
                      'dd/MM/yyyy',
                    ).parse(controller.dateController.text);
                  } catch (_) {}
                }
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.dateController.text = DateFormat(
                    'dd/MM/yyyy',
                  ).format(picked);
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.linkUrlController,
              decoration: const InputDecoration(labelText: 'Link URL'),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: controller.priorityForm,
              builder: (context, value, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prioridade'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: PriorType.values.map((priorType) {
                      final name = priorType.name; // low, medium, high
                      return ChoiceChip(
                        label: Text(name.toUpperCase()),
                        selected: value == name,
                        onSelected: (selected) {
                          if (selected) {
                            controller.priorityForm.value = name;
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Chama método de edição no controller
                await controller.editItem(widget.item.id);
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
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
