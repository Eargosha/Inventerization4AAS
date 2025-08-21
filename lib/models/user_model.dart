class User {
  int? id;
  String? login;
  String? firstName;
  String? patronymic;
  String? lastName;
  List<dynamic>? roles;

  User({
    this.id,
    this.login = '',
    this.firstName = '',
    this.patronymic = '',
    this.lastName = '',
    this.roles = const [],
  });

  User.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString()) ?? 0;
    login = json['login']?.toString() ?? '';
    firstName = json['firstName']?.toString() ?? '';
    patronymic = json['patronymic']?.toString() ?? '';
    lastName = json['lastName']?.toString() ?? '';

    if (json['roles'] is String) {
      roles = json['roles'].split(',').map((s) => s.trim()).toList();
    } else if (json['roles'] is List) {
      roles = List<String>.from(json['roles']);
    } else {
      roles = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id; // Dart знает, что это int
    data['login'] = login;
    data['firstName'] = firstName;
    data['patronymic'] = patronymic;
    data['lastName'] = lastName;
    data['roles'] = roles!.join(',');
    return data;
  }

  // --- copyWith для частичного обновления ---
  User copyWith({
    int? id,
    String? login,
    String? firstName,
    String? patronymic,
    String? lastName,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      firstName: firstName ?? this.firstName,
      patronymic: patronymic ?? this.patronymic,
      lastName: lastName ?? this.lastName,
      roles: roles ?? this.roles,
    );
  }
}
