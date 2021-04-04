import 'package:flutter/material.dart';
import 'package:moor/moor.dart' as moor;
import 'package:pokemon_tcg/collection/my_card_tile.dart';
import 'package:pokemon_tcg/model/database.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';
import 'package:pokemon_tcg/tcg_api/model/prices.dart';
import 'package:provider/provider.dart';

class PokemonCardDetailPage extends StatefulWidget {
  final PokemonCard pokemonCard;

  const PokemonCardDetailPage({required this.pokemonCard}) : super();

  @override
  _PokemonCardDetailState createState() => _PokemonCardDetailState();
}

class _PokemonCardDetailState extends State<PokemonCardDetailPage> {
  late Database myDatabase;

  @override
  Widget build(BuildContext context) {
    myDatabase = Provider.of<Database>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.pokemonCard.supertype +
              ' ' +
              widget.pokemonCard.subtypes.toString() +
              ' : ' +
              widget.pokemonCard.name),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
                child: Column(
                    // Header
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  ListTile(
                    title: Text(widget.pokemonCard.name),
                    subtitle: Text(widget.pokemonCard.id),
                    trailing: Text.rich(
                        TextSpan(text: widget.pokemonCard.hp, children: [
                      TextSpan(text: ' HP '),
                    ])),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(TextSpan(
                      style: TextStyle(fontWeight: FontWeight.bold),
                      text: 'Price: ',
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const <DataColumn>[
                            DataColumn(
                              label: Text(
                                'Type',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Market',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Low',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Mid',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'High',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                          rows: prices(widget.pokemonCard.tcgPlayer.prices),
                        )),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text.rich(TextSpan(
                            text: 'Illustrator: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, height: 2),
                            children: [
                              TextSpan(text: widget.pokemonCard.artist)
                            ])),
                        Expanded(child: Container()),
                        OutlinedButton(
                            onPressed: () {
                              _showCardImage(context);
                            },
                            child: Text('View Card')),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.pokemonCard.flavorText.toString(),
                      style: TextStyle(fontStyle: FontStyle.italic),
                      softWrap: true,
                    ),
                  ),
                ])),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(10.0),
                child: FutureBuilder(
                  future: myDatabase.allCardWithId(widget.pokemonCard.id),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<MyCard>> snapshot) {
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
                        ),
                      );
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
                    return Center(child: Text('Add a Card'));
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => setState(() {
            this._addCard();
          }),
          tooltip: 'Add card to my collection',
          child: const Icon(Icons.add),
        ));
  }

  void _addCard() {
    myDatabase.addCard(MyCardsCompanion(
        name: moor.Value(widget.pokemonCard.name),
        etat: moor.Value('nice'),
        nationalPokedexNumbers:
            moor.Value(widget.pokemonCard.nationalPokedexNumbers.first),
        language: moor.Value('english'),
        cardID: moor.Value(widget.pokemonCard.id)));
  }

  void _removeCard(MyCard item) {
    myDatabase.removeCard(item.id);
  }

  // List _getCards() {
  //   return storage.getItem(widget.pokemonCard.id) ?? [];
  // }

  void _showCardImage(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Image.network(widget.pokemonCard.images.large);
        });
  }

  List<DataRow> prices(List<Prices> prices) {
    return [
      for (var price in prices)
        DataRow(cells: <DataCell>[
          DataCell(Text(price.type.toString())),
          DataCell(Text(price.market.toString())),
          DataCell(Text(price.low.toString())),
          DataCell(Text(price.mid.toString())),
          DataCell(Text(price.high.toString())),
        ])
    ];
  }
}
