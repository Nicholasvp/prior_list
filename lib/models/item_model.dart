// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:prior_list/enums/enums.dart';

class ItemModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime? priorDate;
  final String? linkUrl;
  final PriorType priorType;

  ItemModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.priorDate,
    this.linkUrl,
    required this.priorType,
  });

  ItemModel copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? priorDate,
    String? linkUrl,
    PriorType? priorType,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      priorDate: priorDate ?? this.priorDate,
      priorType: priorType ?? this.priorType,
      linkUrl: linkUrl ?? this.linkUrl,
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
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      priorDate: map['priorDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['priorDate'] as int)
          : null,
      linkUrl: map['linkUrl'] as String? ?? '',
      priorType: map['priorType'] != null
          ? transformToPriotType[map['priorType']]!
          : PriorType.low,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ItemModel(id: $id, title: $title, createdAt: $createdAt, priorDate: $priorDate, linkUrl: $linkUrl, priorType: $priorType)';
  }

  @override
  bool operator ==(covariant ItemModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.createdAt == createdAt &&
        other.priorDate == priorDate &&
        other.linkUrl == linkUrl &&
        other.priorType == priorType;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        createdAt.hashCode ^
        priorDate.hashCode ^
        linkUrl.hashCode ^
        priorType.hashCode;
  }
}
