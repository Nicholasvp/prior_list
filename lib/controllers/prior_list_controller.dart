import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:prior_list/controllers/coins_controller.dart';
import 'package:prior_list/controllers/state_controller.dart';
import 'package:prior_list/enums/enums.dart';
import 'package:prior_list/main.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/repositories/auth_repository.dart';
import 'package:prior_list/repositories/database_repository.dart';
import 'package:prior_list/repositories/notification_repository.dart';

class PriorListController extends StateController {
  final authRepository = autoInjector.get<AuthRepository>();
  final databaseRepository = autoInjector.get<DatabaseRepository>();
  final coinsController = autoInjector.get<CoinsController>();

  final items = ValueNotifier<List<ItemModel>>([]);
  List<ItemModel> _allItems = [];

  final nomeController = TextEditingController();
  final dateController = TextEditingController();
  final linkUrlController = TextEditingController();
  final priorityForm = ValueNotifier<String>('low');
  final selectedColor = ValueNotifier<String?>(null);

  final sortType = ValueNotifier<String>('none');
  final statusFilter = ValueNotifier<String>('all');

  int get totalItems => _allItems.length;

  int get completedItems => _allItems.where((item) => item.completed).length;

  int get pendingItems => totalItems - completedItems;

  // =============================
  // 🔄 LISTEN FIREBASE
  // =============================
  Stream<List<ItemModel>>? _tasksStream;

  void listenTasks() {
    final userId = authRepository.currentUser?.uid;
    if (userId == null) return;

    loading();

    _tasksStream = databaseRepository.streamTasks(userId);

    _tasksStream!.listen((list) {
      _allItems = list;
      applyFiltersAndSort();
      completed();
    });
  }

  // =============================
  // 📊 FILTERS
  // =============================

  void applyFiltersAndSort() {
    List<ItemModel> result = List<ItemModel>.from(_allItems);

    switch (statusFilter.value) {
      case 'pending':
        result = result.where((item) => !item.completed).toList();
        break;
      case 'completed':
        result = result.where((item) => item.completed).toList();
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
    }

    items.value = result;
  }

  void changeStatus(String newStatus) {
    statusFilter.value = newStatus;
    applyFiltersAndSort();
  }

  void changeSort(String newSort) {
    sortType.value = newSort;
    applyFiltersAndSort();
  }

  // =============================
  // ➕ ADD
  // =============================

  Future<void> addItem({String? teamId}) async {
    if (!coinsController.spentToCreate()) return;

    loading();

    final now = DateTime.now();

    final item = ItemModel(
      id: databaseRepository.generateTaskId(),
      ownerId: authRepository.currentUser!.uid,
      teamId: teamId,
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
      await databaseRepository.createTask(item);

      if (item.priorDate != null) {
        NotificationRepository().scheduleNotification(
          title: 'reminder'.tr(),
          body: item.title,
          year: item.priorDate!.year,
          month: item.priorDate!.month,
          day: item.priorDate!.day,
          hour: item.priorDate!.hour,
          minute: item.priorDate!.minute,
        );
      }

      clearForm();
      completed();
    } catch (e) {
      debugPrint('Erro ao adicionar item: $e');
      error();
    }
  }

  // =============================
  // ✏️ EDIT
  // =============================

  Future<void> editItem(ItemModel originalItem) async {
    if (!coinsController.spentToEdit()) return;

    loading();

    try {
      final updated = originalItem.copyWith(
        title: nomeController.text,
        priorDate: dateController.text.isNotEmpty
            ? DateFormat('dd/MM/yyyy HH:mm').parse(dateController.text)
            : null,
        linkUrl: linkUrlController.text,
        priorType: transformToPriotType[priorityForm.value] ?? PriorType.low,
        color: selectedColor.value,
      );

      await databaseRepository.updateTask(updated);

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
      completed();
    } catch (e) {
      debugPrint('Erro ao editar item: $e');
      error();
    }
  }

  // =============================
  // ✅ COMPLETE
  // =============================

  Future<void> completeItem(ItemModel item) async {
    final updated = item.copyWith(completed: true, completedAt: DateTime.now());

    await databaseRepository.updateTask(updated);
  }

  Future<void> uncompleteItem(ItemModel item) async {
    final updated = item.copyWith(completed: false, completedAt: null);

    await databaseRepository.updateTask(updated);
  }

  // =============================
  // 🗑 DELETE
  // =============================

  Future<void> deleteItem(String id) async {
    if (!coinsController.spentToRemove()) return;
    await databaseRepository.deleteTask(id);
  }

  // =============================
  // 🧹 FORM
  // =============================

  void clearForm() {
    nomeController.clear();
    dateController.clear();
    linkUrlController.clear();
    priorityForm.value = 'low';
    selectedColor.value = null;
  }

  void populateForEdit(ItemModel item) {
    nomeController.text = item.title;
    dateController.text = item.priorDate != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(item.priorDate!)
        : '';
    linkUrlController.text = item.linkUrl ?? '';
    priorityForm.value = item.priorType.name;
    selectedColor.value = item.color;
  }

  Future<void> search(String query) async {
    try {
      final q = query.trim().toLowerCase();

      if (q.isEmpty) {
        applyFiltersAndSort();
        return;
      }

      final filtered = _allItems.where((item) {
        final titleMatch = item.title.toLowerCase().contains(q);
        final linkMatch = (item.linkUrl ?? '').toLowerCase().contains(q);

        return titleMatch || linkMatch;
      }).toList();

      items.value = filtered;
      completed();
    } catch (e) {
      debugPrint('Erro na busca: $e');
      error();
    }
  }
}
