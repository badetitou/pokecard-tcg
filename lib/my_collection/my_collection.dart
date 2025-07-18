import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:pokecard_tcg/collection/pokemon_grid_card.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:pokecard_tcg/tcg_api/tcg.dart';
import 'package:provider/provider.dart';
import 'package:pokecard_tcg/my_collection/my_collection.i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCollectionPage extends StatefulWidget {
  const MyCollectionPage({super.key});

  @override
  _MyCollectionState createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollectionPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late int minGridSize;

  static const _pageSize = 10;
  final PagingController _pagingController = PagingController(firstPageKey: 0);
  late List<String> cardIds;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        minGridSize = prefs.getInt('gridSize') ?? 3;
      });
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems =
          cardIds.slice(pageKey, min(pageKey + _pageSize, cardIds.length));
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: FutureBuilder(
        future: _myCards(),
        builder: (BuildContext context, AsyncSnapshot<List<MyCard>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          cardIds = snapshot.data!.map((item) => item.cardID).toList();
          _pagingController.addPageRequestListener((pageKey) {
            _fetchPage(pageKey);
          });
          double width = MediaQuery.of(context).size.width;

          if (cardIds.isNotEmpty) {
            return Column(children: <Widget>[
              Expanded(
                flex: 1,
                child: PagedGridView(
                  builderDelegate: PagedChildBuilderDelegate(
                      itemBuilder: (context, dynamic item, index) =>
                          FutureBuilder(
                            future: TCG.fetchCard(item),
                            builder: (BuildContext context,
                                AsyncSnapshot<PokemonCard> snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return PokemondGridCard(snapshot.data!);
                            },
                          )),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (width / 200) < minGridSize
                          ? minGridSize
                          : (width / 200).floor(),
                      mainAxisSpacing: 8,
                      childAspectRatio: 100 / 140,
                      crossAxisSpacing: 8),
                  pagingController: _pagingController,
                ),
              )
            ]);
          }
          return Center(child: Text('My Collection'.i18n));
        },
      ),
    );
  }

  Future<List<MyCard>> _myCards() async {
    return Provider.of<Database>(context).allCardEntries;
  }
}
