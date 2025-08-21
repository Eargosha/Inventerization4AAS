class Transfer {
  int? id;
  String? date; // дата переноса
  String? name;
  String? inventoryItem; // наименование + инв. номерок
  String? fromWhere; // откуда
  String? toWhere; // куда
  String? reason; // причина
  String? author;

  Transfer({
    this.id,
    this.name = '',
    this.date = '',
    this.inventoryItem = '',
    this.fromWhere = '',
    this.toWhere = '',
    this.reason = '',
    this.author = '',
  });

  Transfer.fromJson(Map<String, dynamic> json) {
    print("[++++++++++++] JSON ДЛЯ КАЖДОГО TRANSFER");
    print(json);
    id = int.tryParse(json['id'].toString()) ?? 0;
    date = json['date']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    inventoryItem = json['inventory_item']?.toString() ?? '';
    fromWhere = json['from_where']?.toString() ?? '';
    toWhere = json['to_where']?.toString() ?? '';
    reason = json['reason']?.toString() ?? '';
    author = json['author']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['date'] = date;
    data['name'] = name;
    data['inventoryItem'] = inventoryItem;
    data['fromWhere'] = fromWhere;
    data['toWhere'] = toWhere;
    data['reason'] = reason;
    data['author'] = author;
    return data;
  }

  // --- copyWith для частичного обновления ---
  Transfer copyWith({
    int? id,
    String? date,
    String? inventoryItem,
    String? fromWhere,
    String? toWhere,
    String? name,
    String? reason,
    String? author,
  }) {
    return Transfer(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      inventoryItem: inventoryItem ?? this.inventoryItem,
      fromWhere: fromWhere ?? this.fromWhere,
      toWhere: toWhere ?? this.toWhere,
      reason: reason ?? this.reason,
      author: author ?? this.author,
    );
  }
}
