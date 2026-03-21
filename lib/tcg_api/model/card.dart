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
    // Backward compatibility for legacy payloads.
    if (json.containsKey('images')) {
      return PokemonCard(
          id: json['id'].toString(),
          name: json['name'].toString(),
          supertype: json['supertype'].toString(),
          subtypes: json['subtypes'] != null
              ? List<String>.from(json['subtypes'] as List)
              : [],
          hp: json['hp']?.toString() ?? '',
          number: json['number']?.toString() ?? '',
          flavorText: json['flavorText']?.toString() ?? '',
          artist: json['artist']?.toString() ?? '',
          images:
              PokemonCardImage.fromJson(json['images'] as Map<String, dynamic>),
          tcgPlayer: json['tcgplayer'] != null
              ? TCGPlayer.fromJson(json['tcgplayer'] as Map<String, dynamic>)
              : TCGPlayer(prices: [], url: ''),
          nationalPokedexNumbers: json['nationalPokedexNumbers'] != null
              ? List<int>.from(json['nationalPokedexNumbers'])
              : [],
          types: json['types'] != null ? List<String>.from(json['types']) : []);
    }

    return PokemonCard.fromTcgdexJson(json);
  }

  factory PokemonCard.fromTcgdexBriefJson(Map<String, dynamic> json) {
    return PokemonCard(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      supertype: 'Unknown',
      subtypes: const [],
      hp: '',
      flavorText: '',
      number: json['localId']?.toString() ?? '',
      nationalPokedexNumbers: const [],
      types: const [],
      images: PokemonCardImage.fromTcgdexAsset(json['image']?.toString()),
      tcgPlayer: TCGPlayer(prices: [], url: ''),
      artist: '',
    );
  }

  factory PokemonCard.fromTcgdexJson(Map<String, dynamic> json) {
    final subtypes = <String>[];
    for (final key in const ['stage', 'trainerType', 'energyType']) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        subtypes.add(value.toString());
      }
    }

    return PokemonCard(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      supertype: json['category']?.toString() ?? 'Unknown',
      subtypes: subtypes,
      hp: json['hp']?.toString() ?? '',
      flavorText:
          json['description']?.toString() ?? json['effect']?.toString() ?? '',
      number: json['localId']?.toString() ?? '',
      nationalPokedexNumbers:
          json['dexId'] != null ? List<int>.from(json['dexId']) : const [],
      types:
          json['types'] != null ? List<String>.from(json['types']) : const [],
      images: PokemonCardImage.fromTcgdexAsset(json['image']?.toString()),
      tcgPlayer:
          TCGPlayer.fromTcgdexPricing(json['pricing'] as Map<String, dynamic>?),
      artist: json['illustrator']?.toString() ?? '',
    );
  }
}

class PokemonCardImage {
  final String small;
  final String large;

  PokemonCardImage({required this.small, required this.large});

  factory PokemonCardImage.fromJson(Map<String, dynamic> json) {
    return PokemonCardImage(
      small: json['small']?.toString() ?? '',
      large: json['large']?.toString() ?? '',
    );
  }

  factory PokemonCardImage.fromTcgdexAsset(String? baseAssetUrl) {
    if (baseAssetUrl == null || baseAssetUrl.isEmpty) {
      return PokemonCardImage(small: '', large: '');
    }

    final normalizedBaseAsset = baseAssetUrl.endsWith('/')
        ? baseAssetUrl.substring(0, baseAssetUrl.length - 1)
        : baseAssetUrl;

    return PokemonCardImage(
      small: '$normalizedBaseAsset/low.webp',
      large: '$normalizedBaseAsset/high.webp',
    );
  }
}
