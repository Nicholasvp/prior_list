import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> createUser({
    required String userId,
    required String name,
    required String email,
  }) async {
    await _usersRef.doc(userId).set({
      'id': userId,
      'name': name,
      'email': email,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    final doc = await _usersRef.doc(userId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // =====================================================
  // 📝 TASKS
  // =====================================================

  Future<void> createTask(ItemModel item) async {
    await _tasksRef.doc(item.id).set(item.toMap());
  }

  Future<void> updateTask(ItemModel item) async {
    await _tasksRef.doc(item.id).update(item.toMap());
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

  Stream<List<ItemModel>> streamMyTasks(String userId) {
    return _tasksRef
        .where('ownerId', isEqualTo: userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<ItemModel>> streamSharedTasks(String userId) {
    return _tasksRef
        .where('sharedWith', arrayContains: userId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                ItemModel.fromMap(doc.data() as Map<String, dynamic>))
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
}
