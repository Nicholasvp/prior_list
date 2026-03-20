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
    final docRef = _usersRef.doc(user.id);
    final doc = await docRef.get();

    if (doc.exists) return;

    await docRef.set({
      ...user.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
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
    await _tasksRef.doc(taskId).delete();
  }

  Future<ItemModel?> getTask(String taskId) async {
    final doc = await _tasksRef.doc(taskId).get();
    if (!doc.exists) return null;
    return ItemModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  // =====================================================
  // 🔄 STREAMS (PERFEITO PARA VALUE NOTIFIER)
  // =====================================================

  Stream<List<ItemModel>> streamTasks(UserModel user) {
    // Verifica se user.teams é nulo e substitui por uma lista vazia
    final teams = user.teams ?? [];

    // Faz a consulta com whereIn, garantindo que teams seja uma lista válida
    final query = _tasksRef.where("teamId", whereIn: teams);

    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => ItemModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList(),
    );
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

  Future<void> deleteUser(String userId) async {
    await _usersRef.doc(userId).delete();
  }
}
