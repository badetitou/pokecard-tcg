import 'package:pokecard_tcg/tcg_api/model/prices.dart';

class TCGPlayer {
  final String url;
  List<Prices> prices;

  TCGPlayer({required this.url, required this.prices});

  factory TCGPlayer.fromJson(Map<String, dynamic> json) {
    // Legacy PokemonTCG.io payload support.
    return TCGPlayer(
      url: json['url'] ?? '',
      prices: (json['prices'] != null
          ? ((json['prices'] as Map)
              .entries
              .map((e) => Prices.fromJson(e.key, e.value))
              .toList())
          : []),
    );
  }

  factory TCGPlayer.fromTcgdexPricing(Map<String, dynamic>? pricing) {
    if (pricing == null) {
      return TCGPlayer(url: '', prices: []);
    }

    final prices = <Prices>[];
    final tcgplayer = pricing['tcgplayer'];
    if (tcgplayer is Map<String, dynamic>) {
      tcgplayer.forEach((key, value) {
        if (key == 'updated' || key == 'unit') {
          return;
        }
        if (value is Map<String, dynamic>) {
          prices.add(Prices.fromTcgdexVariant(key, value));
        }
      });
    }

    final cardmarket = pricing['cardmarket'];
    if (cardmarket is Map<String, dynamic>) {
      prices.add(Prices.fromTcgdexCardmarket(cardmarket));
    }

    return TCGPlayer(
      url: '',
      prices: prices,
    );
  }
}
