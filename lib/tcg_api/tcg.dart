import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;

class TCG {
  // In-memory cache: key = 'pageKey|pageSize|query', value = list of cards.
  static final Map<String, List<PokemonCard>> _searchCache = {};
  static final Map<String, List<PokemonCard>> _dexSearchCache = {};
  static final Map<String, PokemonCard> _cardCache = {};

  static const String _apiHost = 'api.tcgdex.net';
  static const String _apiLanguage = 'en';

  static Future<List<PokemonCard>> fetchCards(int pageKey,
      [int pageSize = 250, String q = ""]) async {
    final cacheKey = '$pageKey|$pageSize|$q';
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final queryParameters = _buildQueryParameters(q);
    if (_isExactDexIdQuery(queryParameters)) {
      final dexCacheKey = 'dex|$q';
      if (!_dexSearchCache.containsKey(dexCacheKey)) {
        _dexSearchCache[dexCacheKey] =
            await _fetchAllCardsForQuery(queryParameters);
      }

      final sortedCards = _dexSearchCache[dexCacheKey]!;
      final startIndex = pageKey <= 0 ? 0 : pageKey - 1;
      if (startIndex >= sortedCards.length) {
        return [];
      }

      final endIndex = math.min(startIndex + pageSize, sortedCards.length);
      final paginatedResults = sortedCards.sublist(startIndex, endIndex);
      _searchCache[cacheKey] = paginatedResults;
      return paginatedResults;
    }

    final requestQueryParameters = queryParameters
      ..addAll({
        'pagination:page': ((pageKey / pageSize).ceil()).toString(),
        'pagination:itemsPerPage': pageSize.toString(),
      });

    final response = await http.get(
      Uri.https(
        _apiHost,
        '/v2/$_apiLanguage/cards',
        requestQueryParameters,
      ),
    );

    if (response.statusCode == 200) {
      final cards = jsonDecode(response.body) as List<dynamic>;
      final result = List<PokemonCard>.from(cards.map((json) =>
          PokemonCard.fromTcgdexBriefJson(json as Map<String, dynamic>)));
      _searchCache[cacheKey] = result;
      return result;
    } else {
      return [];
    }
  }

  static Future<PokemonCard> fetchCard(String cardId) async {
    if (_cardCache.containsKey(cardId)) {
      return _cardCache[cardId]!;
    }

    final cardResponse = await http.get(
      Uri.https(_apiHost, '/v2/$_apiLanguage/cards/$cardId'),
    );

    if (cardResponse.statusCode == 200) {
      final card = PokemonCard.fromTcgdexJson(
          jsonDecode(cardResponse.body) as Map<String, dynamic>);
      _cardCache[cardId] = card;
      return card;
    }

    // Compatibility fallback for legacy ids saved in local DB.
    final tokens = cardId.split('-');
    if (tokens.length >= 2) {
      final setId = tokens.first;
      final localId = tokens.sublist(1).join('-');
      final fallbackResponse = await http.get(
        Uri.https(_apiHost, '/v2/$_apiLanguage/sets/$setId/$localId'),
      );

      if (fallbackResponse.statusCode == 200) {
        final card = PokemonCard.fromTcgdexJson(
            jsonDecode(fallbackResponse.body) as Map<String, dynamic>);
        _cardCache[cardId] = card;
        return card;
      }
    }

    throw Exception('Card not found on TCGdex: $cardId');
  }

  static Future<List<PokemonCard>> _fetchAllCardsForQuery(
      Map<String, String> queryParameters) async {
    const int batchSize = 250;
    int page = 1;
    final allCards = <PokemonCard>[];

    while (true) {
      final response = await http.get(
        Uri.https(
          _apiHost,
          '/v2/$_apiLanguage/cards',
          {
            ...queryParameters,
            'pagination:page': page.toString(),
            'pagination:itemsPerPage': batchSize.toString(),
          },
        ),
      );

      if (response.statusCode != 200) {
        return [];
      }

      final cardsJson = jsonDecode(response.body) as List<dynamic>;
      final cards = cardsJson
          .map((json) =>
              PokemonCard.fromTcgdexBriefJson(json as Map<String, dynamic>))
          .toList();

      allCards.addAll(cards);
      if (cards.length < batchSize) {
        break;
      }
      page++;
    }

    allCards.sort((a, b) => a.id.compareTo(b.id));
    return allCards;
  }

  // Exposed for deterministic unit tests of query translation.
  static Map<String, String> debugBuildQueryParameters(String query) {
    return _buildQueryParameters(query);
  }

  static Map<String, String> _buildQueryParameters(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return {};
    }

    final parameters = <String, String>{};
    final tokens = trimmedQuery
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .where((token) => token.toUpperCase() != 'AND');

    for (final token in tokens) {
      final directFilter = RegExp(r'^([^=]+)=(.+)$').firstMatch(token);
      if (directFilter != null) {
        final field = _mapFieldName(directFilter.group(1)!);
        _appendParameter(
          parameters,
          field,
          _normalizeValueForField(field, directFilter.group(2)!),
        );
        continue;
      }

      final rangeFilter =
          RegExp(r'^([A-Za-z0-9.]+)(>=|<=|>|<)(.+)$').firstMatch(token);
      if (rangeFilter != null) {
        final field = _mapFieldName(rangeFilter.group(1)!);
        final operator = rangeFilter.group(2)!;
        final value = rangeFilter.group(3)!;

        final prefix = switch (operator) {
          '>' => 'gt:',
          '>=' => 'gte:',
          '<' => 'lt:',
          '<=' => 'lte:',
          _ => '',
        };
        _appendParameter(parameters, field, '$prefix$value');
        continue;
      }

      final oldStyleField = RegExp(r'^([A-Za-z0-9.]+):(.+)$').firstMatch(token);
      if (oldStyleField != null) {
        final field = _mapFieldName(oldStyleField.group(1)!);
        _appendParameter(
          parameters,
          field,
          _normalizeValueForField(field, oldStyleField.group(2)!),
        );
        continue;
      }
    }

    // If we could not parse any explicit filter, fallback to a fuzzy name search.
    if (parameters.isEmpty) {
      parameters['name'] = trimmedQuery;
    }

    return parameters;
  }

  static void _appendParameter(
    Map<String, String> parameters,
    String field,
    String value,
  ) {
    final normalizedValue = value.trim();
    if (normalizedValue.isEmpty) {
      return;
    }

    if (parameters.containsKey(field) &&
        parameters[field]!.split('|').contains(normalizedValue) == false) {
      parameters[field] = '${parameters[field]}|$normalizedValue';
    } else {
      parameters[field] = normalizedValue;
    }
  }

  static String _mapFieldName(String rawField) {
    switch (rawField.trim()) {
      case 'type':
        return 'types';
      case 'supertype':
        return 'category';
      case 'nationalPokedexNumbers':
        return 'dexId';
      default:
        return rawField.trim();
    }
  }

  static bool _isExactDexIdQuery(Map<String, String> parameters) {
    final dexIdFilter = parameters['dexId'];
    return dexIdFilter != null && dexIdFilter.startsWith('eq:');
  }

  static String _normalizeValueForField(String field, String value) {
    final trimmedValue = value.trim();

    // TCGdex requires explicit operator for dexId to avoid broad matches
    // (for example dexId=1 can return unrelated cards).
    if (field == 'dexId' &&
        trimmedValue.isNotEmpty &&
        !trimmedValue.contains(':')) {
      return 'eq:$trimmedValue';
    }

    return trimmedValue;
  }
}
