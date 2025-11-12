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

  // keep a master copy of the full list so searches can filter and
  // be reset to the full list when the query is empty
  List<ItemModel> _allItems = [];

  final nomeController = TextEditingController();
  final dateController = TextEditingController();
  final linkUrlController = TextEditingController();
  final priorityForm = ValueNotifier<String>('low');

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

  /// Search items by [query]. When [query] is empty or whitespace only,
  /// restore the full list. This method toggles loading state while
  /// performing the filter so UI can show a loader if desired.
  Future<void> search(String query) async {
    loading();
    try {
      final q = query.trim();
      if (q.isEmpty) {
        // return the full list
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
      priorityForm.value = 'low';
      getList();
    } catch (e) {
      error();
    }
  }

  /// Preenche os controllers com os dados do item para edição
  void populateForEdit(ItemModel item) {
    nomeController.text = item.title;
    dateController.text = item.priorDate != null
        ? DateFormat('dd/MM/yyyy').format(item.priorDate!)
        : '';
    linkUrlController.text = item.linkUrl ?? '';
    priorityForm.value = item.priorType.name.toLowerCase();
  }

  /// Edita um item existente identificado por [id] usando os valores
  /// atuais dos controllers e persiste no repositório.
  Future<void> editItem(String id) async {
    loading();
    try {
      List<ItemModel> currentList = items.value;
      final idx = currentList.indexWhere((element) => element.id == id);
      if (idx == -1) {
        // item não encontrado
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
