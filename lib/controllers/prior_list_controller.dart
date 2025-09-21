import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/state_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/repositories/hive_repository.dart';

class PriorListController extends StateController {
  HiveRepository hiveRepository = HiveRepository('prior_list');

  final nomeController = TextEditingController();
  final dateController = TextEditingController();
  final priorityForm = ValueNotifier<String>('LOW');

  Future<List<ItemModel>> getList() async {
    loading();
    try {
      final data = await hiveRepository.read('prior_list');
      if (data == null) {
        empty();
        return [];
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
        return [];
      }
      completed();
      return itemList;
    } catch (e) {
      error();
      return [];
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
      priorType: transformToPriotType[priorityForm.value]!,
    );
    try {
      List<ItemModel> currentList = await getList();
      currentList.add(item);
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
