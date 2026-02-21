class UserModel {
  final String id;
  final String? name;
  final String email;
  final List<String>? teams;
  final int coins;

  UserModel({
    required this.id,
    this.name,
    required this.email,
    this.teams,
    this.coins = 0, // valor padrão 0
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String,
      teams: (json['teams'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      coins: json['coins'] != null ? json['coins'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'name': name,
      'email': email,
      'coins': coins,
    };
    if (teams != null) data['teams'] = teams!;
    return data;
  }
}