class Pokemon {
  int id;
  Map<String, dynamic> name;

  Pokemon({required this.id, required this.name});

  factory Pokemon.fromJson(Map<String, dynamic> parsedJson) {
    return Pokemon(id: parsedJson['id'], name: parsedJson['name']);
  }
}
