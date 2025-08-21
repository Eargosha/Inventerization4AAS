class InvNotification {
  final String? id;
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final List<dynamic> destinationRoles;

  InvNotification({
    this.id,
    required this.title,
    required this.body,
    this.isRead = false,
    String? createdAt,
    required this.destinationRoles,
  }) : createdAt = createdAt ?? '';

  InvNotification copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    String? createdAt,
    List<dynamic>? destinationRoles,
  }) {
    return InvNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      destinationRoles: destinationRoles ?? this.destinationRoles,
    );
  }

  InvNotification.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String?,
      title = json['title'] as String? ?? '',
      body = json['body'] as String? ?? '',
      isRead = _parseBool(json['isRead']) ?? false,
      createdAt = json['createdAt'] ?? '',
      destinationRoles = json['destinationRoles'] is List
          ? List<dynamic>.from(json['destinationRoles'])
          : (json['destinationRoles'] as String?)?.split(',') ?? [];

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      return lower == '1' || lower == 'true' || lower == 'yes';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'isRead': isRead,
      'createdAt': createdAt,
      'destinationRoles': destinationRoles,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id?.hashCode ?? Object.hash(title, createdAt);
}
