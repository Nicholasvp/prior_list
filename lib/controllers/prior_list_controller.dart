import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/state_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/repositories/hive_repository.dart';
import 'package:prior_list/repositories/notification_repository.dart';

class PriorListController extends StateController {
  HiveRepository hiveRepository = HiveRepository('prior_list');

  final items = ValueNotifier<List<ItemModel>>([]);

  // keep a master copy of the full list so searches can filter and
  // be reset to the full list when the query is empty
  List<ItemModel> _allItems = [];

  final nomeController = TextEditingController();
  final dateController = TextEditingController();
  final linkUrlController = TextEditingController();
  final priorityForm = ValueNotifier<String>('low');
  final selectedColor = ValueNotifier<String?>(null);

  Future<void> getList() async {
    loading();
    try {
      final data = await hiveRepository.read('prior_list');
      if (data == null) {
        empty();
        items.value = [];
      }
      List<ItemModel> itemList = [];
      if (data is String) {
        // Se for String, assume JSON
        final decoded = json.decode(data);
        if (decoded is List) {
          itemList = decoded
              .map<ItemModel>((item) => ItemModel.fromJson(item))
              .toList();
        }
      } else if (data is List) {
        itemList = data
            .map<ItemModel>((item) => ItemModel.fromJson(item))
            .toList();
      } else if (data is Map) {
        itemList = (data).values
            .map<ItemModel>((item) => ItemModel.fromJson(item))
            .toList();
      }
      if (itemList.isEmpty) {
        empty();
        _allItems = [];
        items.value = [];
      } else {
        // store full list for search resets
        _allItems = List<ItemModel>.from(itemList);
        completed();
        items.value = itemList;
      }
    } catch (e) {
      error();
      items.value = [];
    }
  }

  void sortItems(String criteria) {
    loading();
    List<ItemModel> sortedItems = List<ItemModel>.from(items.value);
    if (criteria == 'date') {
      sortedItems.sort(
        (a, b) =>
            (a.priorDate ?? DateTime(0)).compareTo(b.priorDate ?? DateTime(0)),
      );
    } else if (criteria == 'alphabetical') {
      sortedItems.sort((a, b) => a.title.compareTo(b.title));
    } else if (criteria == 'priority') {
      sortedItems.sort(
        (a, b) => a.priorType.index.compareTo(b.priorType.index),
      );
    }
    items.value = sortedItems;
    completed();
  }

  Future<void> search(String query) async {
    loading();
    try {
      final q = query.trim();
      if (q.isEmpty) {
        items.value = List<ItemModel>.from(_allItems);
        completed();
        return;
      }

      final filtered = _allItems.where((item) {
        final title = item.title;
        return title.toLowerCase().contains(q.toLowerCase());
      }).toList();

      items.value = filtered;
      completed();
    } catch (e) {
      error();
    }
  }

  void clearForm() {
    nomeController.clear();
    dateController.clear();
    linkUrlController.clear();
  }

  Future<void> addItem() async {
    loading();
    final now = DateTime.now();
    final item = ItemModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: nomeController.text,
      createdAt: now,
      priorDate: dateController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy HH:mm').parse(dateController.text)
          : null,
      linkUrl: linkUrlController.text,
      priorType: transformToPriotType[priorityForm.value] ?? PriorType.low,
      color: selectedColor.value,
    );
    try {
      List<ItemModel> currentList = items.value;
      currentList.add(item);
      String jsonString = json.encode(
        currentList.map((item) => item.toJson()).toList(),
      );
      await hiveRepository.create('prior_list', jsonString);
      priorityForm.value = 'low';
      selectedColor.value = null;
      if (item.priorDate != null) {
        NotificationRepository().scheduleNotification(
          title: 'Reminder',
          body: item.title,
          year: item.priorDate!.year,
          month: item.priorDate!.month,
          day: item.priorDate!.day,
          hour: item.priorDate!.hour,
          minute: item.priorDate!.minute,
        );
      }
      getList();
    } catch (e) {
      error();
    }
  }

  void populateForEdit(ItemModel item) {
    nomeController.text = item.title;
    dateController.text = item.priorDate != null
        ? DateFormat('dd/MM/yyyy').format(item.priorDate!)
        : '';
    linkUrlController.text = item.linkUrl ?? '';
    priorityForm.value = item.priorType.name.toLowerCase();
    selectedColor.value = item.color;
  }

  Future<void> editItem(String id) async {
    loading();
    try {
      List<ItemModel> currentList = items.value;
      final idx = currentList.indexWhere((element) => element.id == id);
      if (idx == -1) {
        error();
        return;
      }

      final updated = currentList[idx].copyWith(
        title: nomeController.text,
        priorDate: dateController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy').parse(dateController.text)
            : null,
        linkUrl: linkUrlController.text,
        priorType: transformToPriotType[priorityForm.value] ?? PriorType.low,
        color: selectedColor.value,
      );

      currentList[idx] = updated;

      String jsonString = json.encode(
        currentList.map((item) => item.toJson()).toList(),
      );
      await hiveRepository.create('prior_list', jsonString);

      // limpa campos
      nomeController.clear();
      dateController.clear();
      linkUrlController.clear();
      priorityForm.value = 'low';
      selectedColor.value = null;

      getList();
    } catch (e) {
      error();
    }
  }

  Future<void> deleteItem(String id, BuildContext context) async {
    bool confim = false;
    confim =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confim) {
      loading();
      try {
        List<ItemModel> currentList = items.value;
        currentList.removeWhere((item) => item.id == id);
        String jsonString = json.encode(
          currentList.map((item) => item.toJson()).toList(),
        );
        await hiveRepository.create('prior_list', jsonString);
        getList();
      } catch (e) {
        error();
      }
    }
  }
}
