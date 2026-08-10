class Floor {
  final int id;
  final String name;
  final int levelIndex;

  const Floor({required this.id, required this.name, required this.levelIndex});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'] as int,
      name: json['name'] as String,
      levelIndex: json['level_index'] as int,
    );
  }
}
