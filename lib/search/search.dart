import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokemon_tcg/collection/pokemon_grid_card.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';
import 'package:pokemon_tcg/tcg_api/tcg.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final PagingController<int, PokemonCard> _pagingController =
      PagingController(firstPageKey: 1);

  final _pageSize = 20;
  String query = "";

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) async {
      try {
        final newItems = await TCG.fetchCards(pageKey, _pageSize);

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
    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  // _search(String text) {
  //   query = text;
  //   _pagingController.refresh();
  // }

  @override
  Widget build(BuildContext context) {
    return PagedGridView<int, PokemonCard>(
      showNewPageProgressIndicatorAsGridChild: true,
      showNewPageErrorIndicatorAsGridChild: true,
      showNoMoreItemsIndicatorAsGridChild: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 100 / 150,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 3,
      ),
      pagingController: _pagingController,
      padding: const EdgeInsets.all(8),
      builderDelegate: PagedChildBuilderDelegate<PokemonCard>(
        itemBuilder: (context, item, index) => PokemondGridCard(
          item,
        ),
      ),
    );
  }
}
