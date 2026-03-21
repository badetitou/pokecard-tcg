import 'package:flutter_test/flutter_test.dart';
import 'package:pokecard_tcg/tcg_api/tcg.dart';

void main() {
  group('TCG.debugBuildQueryParameters', () {
    test('returns empty map on empty query', () {
      expect(TCG.debugBuildQueryParameters(''), isEmpty);
      expect(TCG.debugBuildQueryParameters('   '), isEmpty);
    });

    test('translates legacy colon and range syntax to TCGdex filters', () {
      final params =
          TCG.debugBuildQueryParameters('name:bulba* hp>100 type:fire');

      expect(params['name'], 'bulba*');
      expect(params['hp'], 'gt:100');
      expect(params['types'], 'fire');
    });

    test('maps nationalPokedexNumbers to dexId for pokedex compatibility', () {
      final params = TCG.debugBuildQueryParameters('nationalPokedexNumbers:25');

      expect(params, {'dexId': 'eq:25'});
    });

    test('uses fuzzy name search for plain keyword queries', () {
      final params = TCG.debugBuildQueryParameters('charizard');

      expect(params, {'name': 'charizard'});
    });

    test('keeps native TCGdex style key=value filters', () {
      final params = TCG.debugBuildQueryParameters('name=eq:Furret');

      expect(params, {'name': 'eq:Furret'});
    });

    test('forces eq operator for dexId direct filters', () {
      final params = TCG.debugBuildQueryParameters('dexId=1');

      expect(params, {'dexId': 'eq:1'});
    });

    test('joins repeated values with OR separator', () {
      final params = TCG.debugBuildQueryParameters('type:fire type:water');

      expect(params, {'types': 'fire|water'});
    });
  });
}
