import 'package:pokemon_tcg/tcg_api/model/tcgplayer.dart';

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
      {this.id,
      this.name,
      this.supertype,
      this.subtypes,
      this.hp,
      this.flavorText,
      this.number,
      this.nationalPokedexNumbers,
      this.types,
      this.images,
      this.tcgPlayer,
      this.artist});

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    var card = PokemonCard(
        id: json['id'].toString(),
        name: json['name'].toString(),
        supertype: json['supertype'].toString(),
        subtypes: List<String>.from(json['subtypes'] as List),
        hp: json['hp'] != null ? json['hp'] : '',
        number: json['number'] != null ? json['number'] : '',
        flavorText: json['flavorText'].toString(),
        artist: json['artist'].toString(),
        images: PokemonCardImage.fromJson(json['images']),
        tcgPlayer: TCGPlayer.fromJson(json['tcgplayer']));
    if (json.containsKey('nationalPokedexNumbers')) {
      card.nationalPokedexNumbers =
          List<int>.from(json['nationalPokedexNumbers']);
    } else {
      card.nationalPokedexNumbers = [];
    }
    if (json.containsKey('types')) {
      card.types = List<String>.from(json['types']);
    } else {
      card.types = [];
    }
    return card;
  }
}

class PokemonCardImage {
  final String small;
  final String large;

  PokemonCardImage({this.small, this.large});

  factory PokemonCardImage.fromJson(Map<String, dynamic> json) {
    return PokemonCardImage(small: json['small'], large: json['large']);
  }
}
