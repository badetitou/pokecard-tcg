import 'package:flutter_test/flutter_test.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';

void main() {
  group('PokemonCard.fromTcgdexJson', () {
    test('maps TCGdex card payload to app model', () {
      final payload = <String, dynamic>{
        'id': 'swsh3-136',
        'localId': '136',
        'name': 'Furret',
        'category': 'Pokemon',
        'hp': 110,
        'description': 'Sample flavor text',
        'illustrator': 'tetsuya koizumi',
        'image': 'https://assets.tcgdex.net/en/swsh/swsh3/136',
        'dexId': [162],
        'types': ['Colorless'],
        'stage': 'Stage1',
        'pricing': {
          'tcgplayer': {
            'updated': 123,
            'unit': 1,
            'normal': {
              'lowPrice': 1.2,
              'midPrice': 2.3,
              'highPrice': 3.4,
              'marketPrice': 2.2,
              'directLowPrice': 1.1,
            }
          },
          'cardmarket': {
            'low': 0.9,
            'avg': 1.4,
            'trend': 1.8,
            'avg30': 1.7,
            'avg7': 1.5,
          }
        }
      };

      final card = PokemonCard.fromTcgdexJson(payload);

      expect(card.id, 'swsh3-136');
      expect(card.name, 'Furret');
      expect(card.supertype, 'Pokemon');
      expect(card.subtypes, ['Stage1']);
      expect(card.hp, '110');
      expect(card.flavorText, 'Sample flavor text');
      expect(card.artist, 'tetsuya koizumi');
      expect(card.nationalPokedexNumbers, [162]);
      expect(card.types, ['Colorless']);
      expect(card.images.small,
          'https://assets.tcgdex.net/en/swsh/swsh3/136/low.webp');
      expect(card.images.large,
          'https://assets.tcgdex.net/en/swsh/swsh3/136/high.webp');
      expect(card.tcgPlayer.prices.length, 2);
      expect(card.tcgPlayer.prices.first.type, 'normal');
      expect(card.tcgPlayer.prices.first.market, 2.2);
      expect(card.tcgPlayer.prices.last.type, 'cardmarket');
    });
  });

  group('PokemonCard.fromTcgdexBriefJson', () {
    test('creates usable card model from card brief payload', () {
      final brief = <String, dynamic>{
        'id': 'base4-1',
        'localId': '1',
        'name': 'Alakazam',
        'image': 'https://assets.tcgdex.net/en/base/base4/1',
      };

      final card = PokemonCard.fromTcgdexBriefJson(brief);

      expect(card.id, 'base4-1');
      expect(card.number, '1');
      expect(card.name, 'Alakazam');
      expect(card.images.small,
          'https://assets.tcgdex.net/en/base/base4/1/low.webp');
      expect(card.images.large,
          'https://assets.tcgdex.net/en/base/base4/1/high.webp');
      expect(card.tcgPlayer.prices, isEmpty);
    });
  });
}
