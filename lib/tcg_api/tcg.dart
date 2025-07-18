import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TCG {
  static Future<List<PokemonCard>> fetchCards(pageKey,
      [int pageSize = 250, String q = ""]) async {
    final response =
        await http.get(Uri.https('api.pokemontcg.io', '/v2/cards', {
      'page': ((pageKey / pageSize).ceil()).toString(),
      'pageSize': pageSize.toString(),
      'q': q
    }));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Iterable cards = jsonDecode(response.body)['data'];
      return List<PokemonCard>.from(
          cards.map((json) => PokemonCard.fromJson(json)));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return [];
    }
  }

  static Future<PokemonCard> fetchCard(String cardId) async {
    final response =
        await http.get(Uri.https('api.pokemontcg.io', '/v2/cards/$cardId'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Map<String, dynamic> card = jsonDecode(response.body)['data'];
      return PokemonCard.fromJson(card);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Error();
    }
  }
}
