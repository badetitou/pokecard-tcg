import 'package:pokecard_tcg/tcg_api/model/tcgplayer.dart';

class PokemonCard {
  final String id;
  final String name;
  final String supertype;
  final String flavorText;
  final List<String> subtypes;
  final String hp;
  final String number;
  List<int> nationalPokedexNumbers;
  List<String> types;
  final PokemonCardImage images;
  final TCGPlayer tcgPlayer;
  final String artist;

  PokemonCard(
      {required this.id,
      required this.name,
      required this.supertype,
      required this.subtypes,
      required this.hp,
      required this.flavorText,
      required this.number,
      required this.nationalPokedexNumbers,
      required this.types,
      required this.images,
      required this.tcgPlayer,
      required this.artist});

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    var card = PokemonCard(
        id: json['id'].toString(),
        name: json['name'].toString(),
        supertype: json['supertype'].toString(),
        subtypes: List<String>.from(json['subtypes'] as List),
        hp: json['hp'] ?? '',
        number: json['number'] ?? '',
        flavorText: json['flavorText'] ?? '',
        artist: json['artist'].toString(),
        images: PokemonCardImage.fromJson(json['images']),
        tcgPlayer: json['tcgplayer'] != null
            ? TCGPlayer.fromJson(json['tcgplayer'])
            : TCGPlayer(prices: [], url: ''),
        nationalPokedexNumbers: json['nationalPokedexNumbers'] != null
            ? List<int>.from(json['nationalPokedexNumbers'])
            : [],
        types: json['types'] != null ? List<String>.from(json['types']) : []);
    return card;
  }
}

class PokemonCardImage {
  final String small;
  final String large;

  PokemonCardImage({required this.small, required this.large});

  factory PokemonCardImage.fromJson(Map<String, dynamic> json) {
    return PokemonCardImage(small: json['small'], large: json['large']);
  }
}
