import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/state_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/repositories/hive_repository.dart';
import 'package:prior_list/repositories/notification_repository.dart';

class PriorListController extends StateController {
  HiveRepository hiveRepository = HiveRepository('prior_list');

  final coinsController = autoInjector.get<CoinsController>();

  final items = ValueNotifier<List<ItemModel>>([]);
  List<ItemModel> _allItems = [];

  final nomeController = TextEditingController();
  final dateController = TextEditingController();
  final linkUrlController = TextEditingController();
  final priorityForm = ValueNotifier<String>('low');
  final selectedColor = ValueNotifier<String?>(null);
  final showOnlyCompleted = ValueNotifier<bool>(false);

  final sortType = ValueNotifier<String>('none');
  final statusFilter = ValueNotifier<String>('');

  int get totalItems => _allItems.length;
  int get completedItems => _allItems.where((item) => item.completed).length;
  int get pendingItems => _allItems.length - completedItems;

  Future<void> _saveListToHive() async {
    try {
      final jsonString = json.encode(
        items.value.map((item) => item.toJson()).toList(),
      );
      await hiveRepository.create('prior_list', jsonString);
    } catch (e) {
      debugPrint('Erro ao salvar lista no Hive: $e');
      error();
    }
  }

  Future<void> getList() async {
    loading();
    try {
      final data = await hiveRepository.read('prior_list');
      if (data == null) {
        empty();
        items.value = [];
        _allItems = [];
        return;
      }

      List<ItemModel> itemList = [];
      if (data is String) {
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
        itemList = data.values
            .map<ItemModel>((item) => ItemModel.fromJson(item))
            .toList();
      }

      if (itemList.isEmpty) {
        empty();
        _allItems = [];
        items.value = [];
      } else {
        _allItems = List<ItemModel>.from(itemList);
        items.value = itemList;
        completed();
      }
    } catch (e) {
      debugPrint('Erro ao carregar lista: $e');
      error();
      items.value = [];
    }
  }

  void applyFiltersAndSort() {
    loading();
    try {
      List<ItemModel> result = List<ItemModel>.from(_allItems);

      switch (statusFilter.value) {
        case 'pending':
          result = result.where((item) => !item.completed).toList();
          break;
        case 'completed':
          result = result.where((item) => item.completed).toList();
          break;
        case 'all':
        default:
          break;
      }

      switch (sortType.value) {
        case 'date':
          result.sort(
            (a, b) => (a.priorDate ?? DateTime(3000)).compareTo(
              b.priorDate ?? DateTime(3000),
            ),
          );
          break;
        case 'name':
          result.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'priority':
          result.sort((a, b) => b.priorType.index.compareTo(a.priorType.index));
          break;
        case 'none':
        default:
          break;
      }

      items.value = result;
      completed();
    } catch (e) {
      debugPrint('Erro ao aplicar filtros e ordenação: $e');
      error();
    }
  }

  void changeSort(String newSort) {
    sortType.value = newSort;
    applyFiltersAndSort();
  }

  void changeStatus(String newStatus) {
    statusFilter.value = newStatus;
    applyFiltersAndSort();
  }

  Future<void> search(String query) async {
    loading();
    try {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) {
        items.value = List<ItemModel>.from(_allItems);
        completed();
        return;
      }

      final filtered = _allItems.where((item) {
        return item.title.toLowerCase().contains(q);
      }).toList();

      items.value = filtered;
      completed();
    } catch (e) {
      debugPrint('Erro na busca: $e');
      error();
    }
  }

  void populateForEdit(ItemModel item) {
    nomeController.text = item.title.trim();
    dateController.text = item.priorDate != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(item.priorDate!)
        : '';
    linkUrlController.text = (item.linkUrl ?? '').trim();
    priorityForm.value = item.priorType.name.toLowerCase();
    selectedColor.value = item.color;
  }

  Future<void> addItem() async {
    final coinscontroller = autoInjector.get<CoinsController>();
    if (!coinscontroller.spentToCreate()) return;

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
      final currentList = List<ItemModel>.from(items.value)..add(item);
      items.value = currentList;

      _allItems.add(item);

      await _saveListToHive();

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

      clearForm();
      priorityForm.value = 'low';
      selectedColor.value = null;

      completed();
    } catch (e) {
      debugPrint('Erro ao adicionar item: $e');
      error();
    }
  }

  Future<void> editItem(ItemModel originalItem) async {
    final coinscontroller = autoInjector.get<CoinsController>();
    if (!coinscontroller.spentToEdit()) return;

    loading();

    try {
      final idx = items.value.indexWhere(
        (element) => element.id == originalItem.id,
      );
      if (idx == -1) return;

      final updated = items.value[idx].copyWith(
        title: nomeController.text,
        priorDate: dateController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy HH:mm').parse(dateController.text)
            : null,
        linkUrl: linkUrlController.text,
        priorType: transformToPriotType[priorityForm.value] ?? PriorType.low,
        color: selectedColor.value,
      );

      final newList = List<ItemModel>.from(items.value)..[idx] = updated;
      items.value = newList;

      final allIdx = _allItems.indexWhere((i) => i.id == originalItem.id);
      if (allIdx != -1) _allItems[allIdx] = updated;

      await _saveListToHive();

      if (updated.priorDate != null) {
        NotificationRepository().scheduleNotification(
          title: 'reminder'.tr(),
          body: updated.title,
          year: updated.priorDate!.year,
          month: updated.priorDate!.month,
          day: updated.priorDate!.day,
          hour: updated.priorDate!.hour,
          minute: updated.priorDate!.minute,
        );
      }

      clearForm();
      priorityForm.value = 'low';
      selectedColor.value = null;

      completed();
    } catch (e) {
      debugPrint('Erro ao editar item: $e');
      error();
    }
  }

  void completeItem(ItemModel item) {
    loading();

    try {
      final idx = items.value.indexWhere((i) => i.id == item.id);
      if (idx == -1 || items.value[idx].completed) {
        completed();
        return;
      }

      final now = DateTime.now();
      final updated = items.value[idx].copyWith(
        completed: true,
        completedAt: now,
      );

      final newList = List<ItemModel>.from(items.value)..[idx] = updated;
      items.value = newList;

      final allIdx = _allItems.indexWhere((i) => i.id == item.id);
      if (allIdx != -1) {
        _allItems[allIdx] = updated;
      }

      _saveListToHive();
      applyFiltersAndSort();
      completed();
    } catch (e) {
      debugPrint('Erro ao completar item: $e');
      error();
    }
  }

  void uncompleteItem(ItemModel item) {
    loading();

    try {
      final idx = items.value.indexWhere((i) => i.id == item.id);
      if (idx == -1 || !items.value[idx].completed) {
        completed();
        return;
      }

      final updated = items.value[idx].copyWith(
        completed: false,
        completedAt: null,
      );

      final newList = List<ItemModel>.from(items.value)..[idx] = updated;

      newList.sort(
        (a, b) => a.completed == b.completed ? 0 : (a.completed ? 1 : -1),
      );

      items.value = newList;

      final allIdx = _allItems.indexWhere((i) => i.id == item.id);
      if (allIdx != -1) {
        _allItems[allIdx] = updated;
        _allItems.sort(
          (a, b) => a.completed == b.completed ? 0 : (a.completed ? 1 : -1),
        );
      }

      _saveListToHive();
      applyFiltersAndSort();
      completed();
    } catch (e) {
      debugPrint('Erro ao desfazer complete: $e');
      error();
    }
  }

  void clearForm() {
    nomeController.clear();
    dateController.clear();
    linkUrlController.clear();
    priorityForm.value = 'low';
    selectedColor.value = null;
  }

  Future<void> deleteItem(String id, BuildContext context) async {
    final coinsController = autoInjector.get<CoinsController>();

    if (coinsController.coins.value < coinsController.costToRemoveItem) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'not_enough_coins_delete'.tr(
              namedArgs: {'cost': coinsController.costToRemoveItem.toString()},
            ),
          ),
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

    if (confirmed != true) return;

    final success = coinsController.spentToRemove();
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('not_enough_coins_anymore'.tr()),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    loading();

    try {
      final newList = List<ItemModel>.from(items.value)
        ..removeWhere((item) => item.id == id);

      items.value = newList;

      _allItems.removeWhere((item) => item.id == id);

      await _saveListToHive();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('item_deleted'.tr()),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      completed();
    } catch (e) {
      debugPrint('Erro ao deletar item: $e');
      error();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('error_deleting_item'.tr())));
    }
  }
}
