import 'package:pokemon_tcg/tcg_api/model/prices.dart';

class TCGPlayer {
  final String url;
  List<Prices> prices;

  TCGPlayer({this.url, this.prices});

  factory TCGPlayer.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return TCGPlayer();
    }
    return TCGPlayer(
      url: json['url'],
      prices: (json['prices'] as Map)
          .entries
          .map((e) => Prices.fromJson(e.key, e.value))
          .toList(),
    );
  }
}
