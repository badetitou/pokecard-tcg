import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokemon_tcg/collection/pokemon_grid_card.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';
import 'package:pokemon_tcg/tcg_api/tcg.dart';

class SearchPokemonPage extends StatefulWidget {
  final String search;

  const SearchPokemonPage({Key key, this.search}) : super(key: key);

  @override
  _SearchPokemonState createState() => _SearchPokemonState();
}

class _SearchPokemonState extends State<SearchPokemonPage> {
  final PagingController<int, PokemonCard> _pagingController =
      PagingController(firstPageKey: 1);

  final _pageSize = 100;

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) async {
      try {
        final newItems =
            await TCG.fetchCards(pageKey, _pageSize, 'name:' + widget.search);

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.search),
      ),
      body: Center(
          child: PagedGridView<int, PokemonCard>(
        showNewPageProgressIndicatorAsGridChild: false,
        showNewPageErrorIndicatorAsGridChild: false,
        showNoMoreItemsIndicatorAsGridChild: false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 100 / 150,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: (width / 200).floor(),
        ),
        pagingController: _pagingController,
        padding: const EdgeInsets.all(8),
        builderDelegate: PagedChildBuilderDelegate<PokemonCard>(
          itemBuilder: (context, item, index) => PokemondGridCard(
            item,
          ),
        ),
      )),
    );
  }
}
