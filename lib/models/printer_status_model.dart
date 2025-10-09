class PrinterStatus {
  int? id;
  String? date; // дата переноса
  String? title;
  String? description; // наименование + инв. номерок
  int? type; // 0 - находится в сети и работает, 1 - в процессе печати, 2 - в очереди (подготовка данных), 3 - принтер не в сети, 4 - ошибка печати, 5 - печать завершена

  PrinterStatus({
    this.id,
    this.title = '',
    this.date = '',
    this.description = '',
    this.type = 0,
  });

  PrinterStatus.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString()) ?? 0;
    date = json['date']?.toString() ?? '';
    title = json['name']?.toString() ?? '';
    description = json['inventory_item']?.toString() ?? '';
    type = int.tryParse(json['type'].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) data['id'] = id;
    data['date'] = date;
    data['name'] = title;
    data['inventoryItem'] = description;
    data['type'] = type;
    return data;
  }

  // --- copyWith для частичного обновления ---
  PrinterStatus copyWith({
    int? id,
    String? date,
    String? inventoryItem,
    String? fromWhere,
    int? type,
  }) {
    return PrinterStatus(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: inventoryItem ?? this.description,
      type: type ?? this.type,
    );
  }
}
