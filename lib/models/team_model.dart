class TeamModel {
  final String id;
  final String name;
  final String ownerId;
  final List<String> members;
  final DateTime createdAt;

  TeamModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.members,
    required this.createdAt,
  });

  /// ================= COPY =================
  TeamModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<String>? members,
    DateTime? createdAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// ================= MAP =================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'members': members,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['createdAt'] ?? 0,
      ),
    );
  }
}