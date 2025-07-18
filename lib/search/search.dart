import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokecard_tcg/collection/pokemon_grid_card.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:pokecard_tcg/tcg_api/tcg.dart';

class SearchResultsGridView extends StatefulWidget {
  final String _search;

  final EdgeInsets padding;

  final int minGridSize;

  const SearchResultsGridView(this._search,
      {super.key, this.padding = EdgeInsets.zero, required this.minGridSize});

  @override
  _SearchResultsGridViewState createState() =>
      _SearchResultsGridViewState(minGridSize: minGridSize);
}

class _SearchResultsGridViewState extends State<SearchResultsGridView> {
  final PagingController<int, PokemonCard> _pagingController =
      PagingController(firstPageKey: 1);

  final _pageSize = 20;
  final int minGridSize;
  _SearchResultsGridViewState({required this.minGridSize});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _pagingController.addPageRequestListener((pageKey) async {
      try {
        final newItems =
            await TCG.fetchCards(pageKey, _pageSize, widget._search);

        final isLastPage = newItems.length < _pageSize;
        if (isLastPage) {
          _pagingController.appendLastPage(newItems);
        } else {
          final nextPageKey = pageKey + newItems.length;
          _pagingController.appendPage(newItems, nextPageKey);
        }
      } catch (error) {
        _pagingController.error = error;
      }
    });

    double width = MediaQuery.of(context).size.width;
    _pagingController.refresh();
    return PagedGridView<int, PokemonCard>(
      padding: EdgeInsets.only(
          top: 8 + widget.padding.top, bottom: 8, right: 8, left: 8),
      showNewPageProgressIndicatorAsGridChild: true,
      showNewPageErrorIndicatorAsGridChild: true,
      showNoMoreItemsIndicatorAsGridChild: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 100 / 140,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount:
            ((width / 200) < minGridSize) ? minGridSize : (width / 200).floor(),
      ),
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<PokemonCard>(
        itemBuilder: (context, item, index) => PokemondGridCard(
          item,
        ),
      ),
    );
  }
}
