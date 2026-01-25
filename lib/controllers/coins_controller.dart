import 'package:flutter/foundation.dart';
import 'package:prior_list/repositories/hive_repository.dart';

class CoinsController {
  ValueNotifier<int> coins = ValueNotifier<int>(0);

  HiveRepository hiveRepository = HiveRepository('coins');

  int costToAddItem = 3;
  int costToRemoveItem = 1;
  int costToEditItem = 2;
  
  int reward = 10;

  bool get hasEnoughToAddItem => coins.value >= costToAddItem;
  bool get hasEnoughToRemoveItem => coins.value >= costToRemoveItem;
  bool get hasEnoughToEditItem => coins.value >= costToEditItem;

  void fetchCoins() async {
    coins.value = await hiveRepository.read('coins') ?? 0;
  }
  void addCoins(int value) {
    hiveRepository.create('coins', coins.value + value);
    fetchCoins();
  }
  bool spentToCreate() {
    if(coins.value < costToAddItem) {
      return false;
    }
    hiveRepository.create('coins', coins.value - costToAddItem);
    fetchCoins();
    return true;
  }
  bool spentToRemove() {
    if(coins.value < costToRemoveItem) {
      return false;
    }
    hiveRepository.create('coins', coins.value - costToRemoveItem);
    fetchCoins();
    return true;
  }
  bool spentToEdit() {
    if(coins.value < costToEditItem) {
      return false;
    }
    hiveRepository.create('coins', coins.value - costToEditItem);
    fetchCoins();
    return true;
  }
  
}