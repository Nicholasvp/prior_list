import 'dart:convert';

import 'package:prior_list/controllers/state_controller.dart';
import 'package:prior_list/models/item_model.dart';
import 'package:prior_list/repositories/secure_storage_repository.dart';

class PriorListController extends StateController {
  SecureStorageRepository secureStorageRepository = SecureStorageRepository();

  Future<List<ItemModel>> getList() async {
    loading();
    try {
      String? data = await secureStorageRepository.readSecureData('prior_list');
      if (data == null || data.isEmpty) {
        empty();
        return [];
      } else {
        List resultList = json.decode(data);
        List<ItemModel> itemList = resultList.map((item) => ItemModel.fromJson(item)).toList();
        completed();
        return itemList;
      }
    } catch (e) {
      error();
      return [];
    }
  }
}
