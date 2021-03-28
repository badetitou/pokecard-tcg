import 'package:flutter/material.dart';
import 'package:pokemon_tcg/collection/my_card_tile.dart';
import 'package:pokemon_tcg/model/database.dart';
import 'package:pokemon_tcg/model/database/shared.dart';

class MyCollectionPage extends StatefulWidget {
  @override
  _MyCollectionState createState() => _MyCollectionState();
}

class _MyCollectionState extends State<MyCollectionPage> {
  final myDatabase = constructDb();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: FutureBuilder(
        future: myDatabase.allCardEntries,
        builder: (BuildContext context, AsyncSnapshot<List<MyCard>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<Widget> widgets = snapshot.data!.map((item) {
            return MyCardTile(
                myCard: item,
                onDelete: () => setState(
                      () {
                        _removeCard(item);
                      },
                    ));
          }).toList();

          if (widgets.isNotEmpty) {
            return Column(children: <Widget>[
              Expanded(
                flex: 1,
                child: ListView(
                  children: widgets,
                ),
              )
            ]);
          }
          return Center(child: Text('My Collection'));
        },
      ),
    );
  }

  void _removeCard(MyCard item) {
    myDatabase.removeCard(item.id);
  }
}
