import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/state_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/repositories/hive_repository.dart';

class PriorListController extends StateController {
  HiveRepository hiveRepository = HiveRepository('prior_list');

  final items = ValueNotifier<List<ItemModel>>([]);

  final nomeController = TextEditingController();
  final dateController = TextEditingController();
  final linkUrlController = TextEditingController();
  final priorityForm = ValueNotifier<String>('LOW');

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
        items.value = [];
      }
      completed();
      items.value = itemList;
    } catch (e) {
      error();
      items.value = [];
    }
  }

  Future<void> addItem() async {
    loading();
    final item = ItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: nomeController.text,
      createdAt: DateTime.now(),
      priorDate: dateController.text.isNotEmpty
          ? DateFormat('dd/MM/yyyy').parse(dateController.text)
          : null,
      linkUrl: linkUrlController.text,
      priorType: transformToPriotType[priorityForm.value] ?? PriorType.low,
    );
    try {
      List<ItemModel> currentList = items.value;
      currentList.add(item);
      String jsonString = json.encode(
        currentList.map((item) => item.toJson()).toList(),
      );
      await hiveRepository.create('prior_list', jsonString);

      nomeController.clear();
      dateController.clear();
      priorityForm.value = 'LOW';
      getList();
    } catch (e) {
      error();
    }
  }

  Future<void> deleteItem(String id) async {
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
