import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/state_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/main.dart';
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
    final coinscontroller = autoInjector.get<CoinsController>();
    if (!coinscontroller.spentToCreate()) {
      return;
    }

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
      return;
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
    final coinscontroller = autoInjector.get<CoinsController>();
    if (!coinscontroller.spentToEdit()) {
      return;
    }

    loading();
    try {
      List<ItemModel> currentList = items.value;
      final idx = currentList.indexWhere((element) => element.id == id);
      if (idx == -1) {
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
      return;
    }
  }

  Future<void> deleteItem(String id, BuildContext context) async {
    final coinsController = autoInjector.get<CoinsController>();

    if (coinsController.coins.value < coinsController.costToRemoveItem) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('not_enough_coins_delete'.tr()),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'confirm_deletion'.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'delete_item_question'.tr(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/coin.svg',
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'delete_cost'.tr(
                    namedArgs: {
                      'cost': coinsController.costToRemoveItem.toString(),
                    },
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: Colors.red[50],
            ),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Debita as moedas
      final success = await coinsController.spentToRemove();
      if (!success) {
        // Caso raro de race condition (moedas mudaram entre dialog e confirmação)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('not_enough_coins_anymore'.tr())),
        );
        return;
      }

      // Mostra loading (seu método loading())
      loading();

      try {
        List<ItemModel> currentList = items.value;
        currentList.removeWhere((item) => item.id == id);

        String jsonString = json.encode(
          currentList.map((item) => item.toJson()).toList(),
        );

        await hiveRepository.create('prior_list', jsonString);
        getList();

        // Feedback de sucesso (opcional)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('item_deleted'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        debugPrint('Erro ao deletar item: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('error_deleting_item'.tr())));
      }
    }
  }
}
