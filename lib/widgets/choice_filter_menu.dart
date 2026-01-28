import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';

class ChoiceFilterMenu extends StatelessWidget {
  const ChoiceFilterMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final priorListController = autoInjector.get<PriorListController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18,),
      child: ValueListenableBuilder<List<ItemModel>>(
        valueListenable: priorListController.items,
        builder: (context, itemsList, child) {
          final total = priorListController.totalItems;
          final completed = priorListController.completedItems;
          final pending = priorListController.pendingItems;

          return ValueListenableBuilder<String>(
            valueListenable: priorListController.statusFilter,
            builder: (context, activeFilter, child) {
              return Wrap(
                spacing: 12,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text('${'status_filters.all'.tr()} ($total)'),
                    selected: activeFilter == 'all',
                    selectedColor: Colors.blue[100],
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: activeFilter == 'all'
                          ? Colors.blue[900]
                          : Colors.black87,
                      fontWeight: activeFilter == 'all'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 10,
                    ),
                    onSelected: (_) => priorListController.changeStatus('all'),
                  ),

                  ChoiceChip(
                    label: Text('${'status_filters.pending'.tr()} ($pending)'),
                    selected: activeFilter == 'pending',
                    selectedColor: Colors.orange[100],
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: activeFilter == 'pending'
                          ? Colors.orange[900]
                          : Colors.black87,
                      fontWeight: activeFilter == 'pending'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 10,
                    ),
                    onSelected: (_) =>
                        priorListController.changeStatus('pending'),
                  ),

                  ChoiceChip(
                    label: Text(
                      '${'status_filters.completed'.tr()} ($completed)',
                    ),
                    selected: activeFilter == 'completed',
                    selectedColor: Colors.green[100],
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                      color: activeFilter == 'completed'
                          ? Colors.green[900]
                          : Colors.black87,
                      fontWeight: activeFilter == 'completed'
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 10,
                    ),
                    onSelected: (_) =>
                        priorListController.changeStatus('completed'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
