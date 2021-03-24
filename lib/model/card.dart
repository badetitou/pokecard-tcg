class MyCard {
  String name;
  String etat;
  String cardID;

  MyCard({required this.name, required this.etat, required this.cardID});

  toJSONEncodable() {
    Map<String, dynamic> m = new Map();

    m['name'] = name;
    m['etat'] = etat;
    m['cardID'] = cardID;

    return m;
  }
}

class MyCardList {
  List<MyCard> items = [];

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}
