import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokecard_tcg/search/search.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';

void main() {
  testWidgets('updates search grid columns when minGridSize changes',
      (tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(500, 1000);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    final gridSize = ValueNotifier<int>(2);

    Future<List<PokemonCard>> fetchCards(
      int pageKey,
      int pageSize,
      String query,
    ) async {
      return <PokemonCard>[];
    }

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: gridSize,
          builder: (context, value, _) {
            return SearchResultsGridView(
              'name:bulbasaur',
              minGridSize: value,
              fetchCards: fetchCards,
            );
          },
        ),
      ),
    );

    await tester.pump();

    final firstGrid = tester.widget<PagedGridView<int, PokemonCard>>(
      find.byType(PagedGridView<int, PokemonCard>),
    );
    final firstDelegate =
        firstGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(firstDelegate.crossAxisCount, 2);

    gridSize.value = 4;
    await tester.pump();

    final updatedGrid = tester.widget<PagedGridView<int, PokemonCard>>(
      find.byType(PagedGridView<int, PokemonCard>),
    );
    final updatedDelegate =
        updatedGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(updatedDelegate.crossAxisCount, 4);
  });
}
