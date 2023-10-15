import 'package:flutter/material.dart';
import 'package:pokecard_tcg/collection/pokemon_grid_card.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:pokecard_tcg/tcg_api/tcg.dart';
import 'package:provider/provider.dart';
import 'package:pokecard_tcg/my_collection/my_collection.i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyCollectionPage extends StatefulWidget {
  @override
  _MyCollectionState createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollectionPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late int minGridSize;

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences prefs) {
      setState(() {
        minGridSize = prefs.getInt('gridSize') ?? 3;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: new FutureBuilder(
        future: _myCards(),
        builder: (BuildContext context, AsyncSnapshot<List<MyCard>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          List<Widget> widgets =
              snapshot.data!.map((item) => item.cardID).toSet().map((cardId) {
            return new FutureBuilder(
              future: TCG.fetchCard(cardId),
              builder:
                  (BuildContext context, AsyncSnapshot<PokemonCard> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return new PokemondGridCard(snapshot.data!);
              },
            );
          }).toList();
          double width = MediaQuery.of(context).size.width;

          if (widgets.isNotEmpty) {
            return Column(children: <Widget>[
              Expanded(
                flex: 1,
                child: GridView.count(
                  crossAxisCount: (width / 200) < minGridSize
                      ? minGridSize
                      : (width / 200).floor(),
                  crossAxisSpacing: 8,
                  childAspectRatio: 100 / 140,
                  mainAxisSpacing: 8,
                  children: widgets,
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
