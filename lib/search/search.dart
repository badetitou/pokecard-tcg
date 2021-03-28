import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pokemon_tcg/collection/pokemon_grid_card.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';
import 'package:pokemon_tcg/tcg_api/tcg.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _query = '';

  Map<String, String> _existingCategory = {
    'name': 'name:',
    'id': 'id:',
    'supertype': 'supertype:',
    'subtypes': 'subtypes:',
    'hp': 'hp:',
    'types': 'types:',
    'attacks name': 'attacks.name:',
    'artist': 'artist:'
  };

  FloatingSearchBarController controller = FloatingSearchBarController();

  @override
  initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _search(String text) {
    setState(() => {_query = text});
    controller.close();
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      body: FloatingSearchBarScrollNotifier(
          child: new Container(
              child: (new SearchResultsGridView(_query,
                  padding: EdgeInsets.only(top: 55))))),
      transition: CircularFloatingSearchBarTransition(),
      physics: const BouncingScrollPhysics(),
      title: _query != ''
          ? Text(
              _query,
              style: Theme.of(context).textTheme.headline6,
            )
          : null,
      hint: 'Search... [name:bulba*]',
      controller: controller,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onSubmitted: (query) {
        _search(query);
      },
      actions: [],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
              color: Colors.white,
              elevation: 4.0,
              child: Builder(
                builder: (context) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _existingCategory.entries
                        .map(
                          (term) => ListTile(
                            title: Text(
                              term.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () {
                              controller.query += term.value;
                            },
                          ),
                        )
                        .toList(),
                  );
                },
              )),
        );
      },
    );
  }
}

class SearchResultsGridView extends StatefulWidget {
  final String _search;

  final EdgeInsets padding;

  const SearchResultsGridView(this._search, {this.padding = EdgeInsets.zero})
      : super();

  @override
  _SearchResultsGridViewState createState() => _SearchResultsGridViewState();
}

class _SearchResultsGridViewState extends State<SearchResultsGridView> {
  final PagingController<int, PokemonCard> _pagingController =
      PagingController(firstPageKey: 1);

  final _pageSize = 20;

  void initState() {
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
        crossAxisCount: (width / 200) < 2 ? 2 : (width / 200).floor(),
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
