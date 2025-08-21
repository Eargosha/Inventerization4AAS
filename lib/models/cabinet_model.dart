class Cabinet {
  int? id;
  String? cabinetFloor;
  String? name;

  Cabinet({
    this.id,
    this.cabinetFloor = '',
    this.name = '',
  });

  Cabinet.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id'].toString()) ?? 0;
    cabinetFloor = json['cabinet_floor']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['cabinet_floor'] = cabinetFloor;
    data['name'] = name;
    return data;
  }

  // --- copyWith для частичного обновления ---
  Cabinet copyWith({
    int? id,
    String? cabinetFloor,
    String? name,
  }) {
    return Cabinet(
      id: id ?? this.id,
      cabinetFloor: cabinetFloor ?? this.cabinetFloor,
      name: name ?? this.name,
    );
  }
}