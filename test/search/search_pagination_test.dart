import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokecard_tcg/search/search.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';

void main() {
  testWidgets('does not request the same first page multiple times on rebuild',
      (tester) async {
    int callCount = 0;
    final completer = Completer<List<PokemonCard>>();
    final rebuildTrigger = ValueNotifier<int>(0);

    Future<List<PokemonCard>> fetchCards(
      int pageKey,
      int pageSize,
      String query,
    ) {
      callCount++;
      return completer.future;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: rebuildTrigger,
          builder: (context, _, __) {
            return SearchResultsGridView(
              'nationalPokedexNumbers:1',
              minGridSize: 3,
              fetchCards: fetchCards,
            );
          },
        ),
      ),
    );

    await tester.pump();
    expect(callCount, 1);

    rebuildTrigger.value++;
    await tester.pump();
    rebuildTrigger.value++;
    await tester.pump();

    expect(callCount, 1);

    completer.complete(<PokemonCard>[]);
    await tester.pumpAndSettle();

    expect(callCount, 1);
  });
}
