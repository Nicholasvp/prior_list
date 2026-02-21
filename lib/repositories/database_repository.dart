import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prior_list/models/user_model.dart';
import '../models/item_model.dart';

class DatabaseRepository {
  final FirebaseFirestore _firestore;

  DatabaseRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 🔹 COLLECTIONS
  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _tasksRef => _firestore.collection('tasks');

  // =====================================================
  // 👤 USERS
  // =====================================================

Future<void> createUser(UserModel user) async {
  await _usersRef.doc(user.id).set(user.toJson()..addAll({
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      }));
}

  Future<UserModel?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    return UserModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  // 🔹 USERS - Coins
Future<int> getUserCoins(String userId) async {
  final doc = await _usersRef.doc(userId).get();
  if (!doc.exists) return 0;
  final data = doc.data() as Map<String, dynamic>;
  return data['coins'] != null ? data['coins'] as int : 0;
}

Future<void> updateUserCoins(String userId, int coins) async {
  await _usersRef.doc(userId).update({'coins': coins});
}

  // =====================================================
  // 📝 TASKS
  // =====================================================

Future<void> createTask(ItemModel item) async {
  final now = DateTime.now().millisecondsSinceEpoch;

  await _tasksRef.doc(item.id).set({
    ...item.toMap(),
    'isDeleted': false,
    'createdAt': item.createdAt,
    'updatedAt': now,
    'teamId': item.teamId,
  });
}

  Future<void> updateTask(ItemModel item) async {
  await _tasksRef.doc(item.id).update({
    ...item.toMap(),
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  });
}

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).update({
      'isDeleted': true,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<ItemModel?> getTask(String taskId) async {
    final doc = await _tasksRef.doc(taskId).get();
    if (!doc.exists) return null;
    return ItemModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // =====================================================
  // 🔄 STREAMS (PERFEITO PARA VALUE NOTIFIER)
  // =====================================================

  Stream<List<ItemModel>> streamTasks(String userId, {String? teamId}) {
  Query query = _tasksRef.where('isDeleted', isEqualTo: false);

  // Tarefas do usuário
  query = query.where('ownerId', isEqualTo: userId);

  // Se quiser incluir tarefas do time, faz um where para teamId
  if (teamId != null) {
    query = _tasksRef
        .where('isDeleted', isEqualTo: false)
        .where('teamId', isEqualTo: teamId);
  }

  return query.snapshots().map((snapshot) => snapshot.docs
      .map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>))
      .toList());
}

  // =====================================================
  // 🤝 SHARE
  // =====================================================

  Future<void> shareTask({
    required String taskId,
    required String userId,
  }) async {
    await _tasksRef.doc(taskId).update({
      'sharedWith': FieldValue.arrayUnion([userId]),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> removeShare({
    required String taskId,
    required String userId,
  }) async {
    await _tasksRef.doc(taskId).update({
      'sharedWith': FieldValue.arrayRemove([userId]),
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  String generateTaskId() {
    return _tasksRef.doc().id;
  }


}
