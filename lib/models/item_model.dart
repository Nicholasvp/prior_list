import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prior_list/enums/enums.dart';

class ItemModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? priorDate;
  final String? linkUrl;
  final PriorType priorType;
  final String? color;
  final bool completed;
  final DateTime? completedAt;
  final String ownerId;
  final String? teamId;
  final DateTime? updatedAt;
  final bool isDeleted;

  ItemModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.priorDate,
    this.linkUrl,
    required this.priorType,
    this.color,
    this.completed = false,
    this.completedAt,
    required this.ownerId,
    this.teamId,
    this.updatedAt,
    this.isDeleted = false,
  });

  ItemModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? priorDate,
    String? linkUrl,
    PriorType? priorType,
    String? color,
    bool? completed,
    DateTime? completedAt,
    String? ownerId,
    String? teamId,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      priorDate: priorDate ?? this.priorDate,
      linkUrl: linkUrl ?? this.linkUrl,
      priorType: priorType ?? this.priorType,
      color: color ?? this.color,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      ownerId: ownerId ?? this.ownerId,
      teamId: teamId ?? this.teamId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'priorDate': priorDate?.millisecondsSinceEpoch,
      'linkUrl': linkUrl,
      'priorType': priorType.name,
      'color': color,
      'completed': completed,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'ownerId': ownerId,
      'teamId': teamId,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
  id: map['id'] as String,
  title: map['title'] as String,
  createdAt: (map['createdAt'] is Timestamp
      ? (map['createdAt'] as Timestamp).toDate()
      : DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)),
  priorDate: map['priorDate'] != null
      ? (map['priorDate'] is Timestamp
          ? (map['priorDate'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(map['priorDate'] as int))
      : null,
  linkUrl: map['linkUrl'] as String?,
  priorType: map['priorType'] != null
      ? transformToPriotType[map['priorType']]!
      : PriorType.low,
  color: map['color'] as String?,
  completed: map['completed'] as bool? ?? false,
  completedAt: map['completedAt'] != null
      ? (map['completedAt'] is Timestamp
          ? (map['completedAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(map['completedAt'] as int))
      : null,
  ownerId: map['ownerId'] as String,
  teamId: map['teamId'] as String?,
  updatedAt: map['updatedAt'] != null
      ? (map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int))
      : null,
  isDeleted: map['isDeleted'] as bool? ?? false,
);
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ItemModel(id: $id, title: $title, ownerId: $ownerId, '
        'teamId: $teamId, completed: $completed)';
  }

  @override
  bool operator ==(covariant ItemModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.createdAt == createdAt &&
        other.priorDate == priorDate &&
        other.linkUrl == linkUrl &&
        other.priorType == priorType &&
        other.color == color &&
        other.completed == completed &&
        other.completedAt == completedAt &&
        other.ownerId == ownerId &&
        other.teamId == teamId &&
        other.updatedAt == updatedAt &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        createdAt.hashCode ^
        priorDate.hashCode ^
        linkUrl.hashCode ^
        priorType.hashCode ^
        color.hashCode ^
        completed.hashCode ^
        completedAt.hashCode ^
        ownerId.hashCode ^
        teamId.hashCode ^
        updatedAt.hashCode ^
        isDeleted.hashCode;
  }
}
