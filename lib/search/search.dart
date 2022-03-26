import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pokecard_tcg/collection/pokemon_grid_card.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:pokecard_tcg/tcg_api/tcg.dart';
import 'package:pokecard_tcg/search/search.i18n.dart';

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
    'artist': 'artist:',
    'nationalPokedexNumbers': 'nationalPokedexNumbers:',
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
      backgroundColor: Theme.of(context).backgroundColor,
      accentColor: Theme.of(context).cardColor,
      title: _query != ''
          ? Text(
              _query,
              style: Theme.of(context).textTheme.headline6,
            )
          : null,
      hint: 'Search... [name:bulba*]'.i18n,
      controller: controller,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onSubmitted: (query) {
        _search(query);
      },
      actions: [
        FloatingSearchBarAction(
          showIfClosed: false,
          showIfOpened: true,
          child: CircularButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              _showSearchHelper(context);
            },
          ),
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
              color: Theme.of(context).backgroundColor,
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

  void _showSearchHelper(context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (BuildContext bc) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(TextSpan(
                  text: 'Request:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 3),
                )),
                Text.rich(TextSpan(
                  text: 'Keyword matching:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 2),
                )),
                Text.rich(TextSpan(
                  text:
                      'Search for all cards that have "charizard" in the name field:'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:charizard',
                ),
                Text.rich(TextSpan(
                  text:
                      'Search for "charizard" in the name field AND the type "mega" in the subtypes field:'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:charizard subtypes:mega',
                ),
                Text.rich(TextSpan(
                  text:
                      'Search for "charizard" in the name field AND either the subtypes of "mega" or "vmax":'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:charizard (subtypes:mega OR subtypes:vmax)',
                ),
                Text.rich(TextSpan(
                  text: 'Wildcard Matching:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 2),
                )),
                Text.rich(TextSpan(
                  text:
                      'Search for any card that starts with "char" in the name field:'
                          .i18n,
                )),
                CommandExample(
                  text: 'name:char*',
                ),
                Text.rich(TextSpan(
                  text: 'Range Searches:'.i18n,
                  style: TextStyle(fontWeight: FontWeight.bold, height: 2),
                )),
                Text.rich(TextSpan(
                  text:
                      'Search for only cards that feature the original 151 pokemon:'
                          .i18n,
                )),
                CommandExample(text: 'nationalPokedexNumbers:[1 TO 151]'),
              ],
            ),
          );
        });
  }
}

class CommandExample extends StatelessWidget {
  final String text;

  const CommandExample({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12)),
        child: Text(text));
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
