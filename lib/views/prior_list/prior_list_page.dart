import 'package:flutter/material.dart';
import 'package:prior_list/controllers/prior_list_controller.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';

class PriorListPage extends StatelessWidget {
  const PriorListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final priorListController = autoInjector.get<PriorListController>();
    return FutureBuilder(
      future: priorListController.getList(),
      builder: (context, snapshot) {
        return ValueListenableBuilder(
          valueListenable: priorListController.state,
          builder: (context, value, child) {
            if (priorListController.isLoadingNotifier.value) {
              return const Center(child: CircularProgressIndicator());
            } else if (priorListController.hasErrorNotifier.value) {
              return const Center(child: Text('Error loading data'));
            } else if (priorListController.isEmptyNotifier.value) {
              return const Center(child: Text('No items found'));
            } else {
              List<ItemModel> items = snapshot.data as List<ItemModel>;
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index].title),
                    subtitle: Text(
                      items[index].priorDate != null
                          ? 'Due: ${items[index].priorDate}'
                          : 'No due date',
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        priorListController.deleteItem(items[index].id);
                      },
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
