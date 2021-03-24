import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:pokemon_tcg/model/card.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';
import 'package:pokemon_tcg/tcg_api/model/prices.dart';

class PokemonCardDetailPage extends StatefulWidget {
  final PokemonCard pokemonCard;

  const PokemonCardDetailPage({required this.pokemonCard}) : super();

  @override
  _PokemonCardDetailState createState() => _PokemonCardDetailState();
}

class _PokemonCardDetailState extends State<PokemonCardDetailPage> {
  final storage = new LocalStorage('my_collection.json');
  bool initialized = false;
  MyCardList list = new MyCardList();

  @override
  Widget build(BuildContext context) {
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
                    // leading: Image(
                    //     image: AssetImage('color/' +
                    //         widget.pokemonCard.types[0].toLowerCase() +
                    //         '.png')),
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
                  future: storage.ready,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!initialized) {
                      list.items = storage.getItem(widget.pokemonCard.id) ?? [];
                      initialized = true;
                    }

                    List<Widget> widgets = list.items.map((item) {
                      return Card(
                        child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(item.etat),
                            trailing: IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => setState(
                                () {
                                  _removeCard(item);
                                },
                              ),
                              tooltip: 'Remove',
                            )),
                      );
                    }).toList();

                    return Column(children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: ListView(
                          children: widgets,
                        ),
                      )
                    ]);
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
    list.items.add(new MyCard(
        name: widget.pokemonCard.name,
        etat: 'nice',
        cardID: widget.pokemonCard.id));
    storage.setItem(widget.pokemonCard.id, list.items);
  }

  void _removeCard(MyCard item) {
    list.items.remove(item);
    storage.setItem(widget.pokemonCard.id, list.items);
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
