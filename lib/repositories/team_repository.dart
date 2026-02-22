import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prior_list/models/team_model.dart';

class TeamRepository {
  final _firestore = FirebaseFirestore.instance;
  final _collection = 'teams';

  /// ================= CREATE =================
  Future<void> createTeam(TeamModel team) async {
    await _firestore.collection(_collection).doc(team.id).set(team.toMap());
  }

  /// ================= READ (LIST) =================
  Future<List<TeamModel>> getTeams(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('members', arrayContains: userId)
        .get();

    return snapshot.docs.map((doc) => TeamModel.fromMap(doc.data())).toList();
  }

  /// ================= STREAM =================
  Stream<List<TeamModel>> streamTeams(String userId) {
    return _firestore
        .collection(_collection)
        .where('members', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TeamModel.fromMap(doc.data()))
              .toList(),
        );
  }

  /// ================= UPDATE =================
  Future<void> updateTeam(TeamModel team) async {
    await _firestore.collection(_collection).doc(team.id).update(team.toMap());
  }

  /// ================= DELETE =================
  Future<void> deleteTeam(String teamId) async {
    await _firestore.collection(_collection).doc(teamId).delete();
  }

  /// ================= ADD MEMBER =================
  Future<void> addMember(String teamId, String userId) async {
    await _firestore.collection(_collection).doc(teamId).update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  /// ================= REMOVE MEMBER =================
  Future<void> removeMember(String teamId, String userId) async {
    await _firestore.collection(_collection).doc(teamId).update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }
}
