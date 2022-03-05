class Pokemon {
  int id;
  Map<String, dynamic> name;
  List<dynamic> type;

  Pokemon({required this.id, required this.name, required this.type});

  factory Pokemon.fromJson(Map<String, dynamic> parsedJson) {
    return Pokemon(
        id: parsedJson['id'],
        name: parsedJson['name'],
        type: parsedJson['type']);
  }
}
