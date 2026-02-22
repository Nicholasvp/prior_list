import 'package:flutter/foundation.dart';
import 'package:prior_list/repositories/auth_repository.dart';
import 'package:prior_list/repositories/database_repository.dart';

class CoinsController {
  final DatabaseRepository databaseRepository;
  final AuthRepository authRepository;

  ValueNotifier<int> coins = ValueNotifier<int>(0);

  int costToAddItem = 3;
  int costToRemoveItem = 1;
  int costToEditItem = 2;
  int reward = 10;

  CoinsController({
    required this.databaseRepository,
    required this.authRepository,
  });

  String get userId => authRepository.currentUser!.uid;

  bool get hasEnoughToAddItem => coins.value >= costToAddItem;
  bool get hasEnoughToRemoveItem => coins.value >= costToRemoveItem;
  bool get hasEnoughToEditItem => coins.value >= costToEditItem;

  Future<void> fetchCoins() async {
    coins.value = await databaseRepository.getUserCoins(userId);
  }

  Future<void> addCoins(int value) async {
    final newCoins = coins.value + value;
    await databaseRepository.updateUserCoins(userId, newCoins);
    coins.value = newCoins;
  }

  Future<bool> spentToCreate() async {
    if (coins.value < costToAddItem) return false;
    final newCoins = coins.value - costToAddItem;
    await databaseRepository.updateUserCoins(userId, newCoins);
    coins.value = newCoins;
    return true;
  }

  Future<bool> spentToRemove() async {
    if (coins.value < costToRemoveItem) return false;
    final newCoins = coins.value - costToRemoveItem;
    await databaseRepository.updateUserCoins(userId, newCoins);
    coins.value = newCoins;
    return true;
  }

  Future<bool> spentToEdit() async {
    if (coins.value < costToEditItem) return false;
    final newCoins = coins.value - costToEditItem;
    await databaseRepository.updateUserCoins(userId, newCoins);
    coins.value = newCoins;
    return true;
  }
}