import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:pokemon_tcg/collection/my_card_tile.dart';
import 'package:pokemon_tcg/model/database.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';
import 'package:pokemon_tcg/tcg_api/model/prices.dart';
import 'package:provider/provider.dart';
import 'package:pokemon_tcg/collection/card_detail.i18n.dart';

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
                      text: 'Price:'.i18n,
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: <DataColumn>[
                            DataColumn(
                              label: Text(
                                'Type',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Market'.i18n,
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Low'.i18n,
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Mid'.i18n,
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'High'.i18n,
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
                            text: 'Illustrator: '.i18n,
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
                            child: Text('View Card'.i18n)),
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
                    return Center(child: Text('Add a Card'.i18n));
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
          tooltip: 'Add card to my collection'.i18n,
          child: const Icon(Icons.add),
        ));
  }

  Future<void> _addCard() async {
    CreateWidgetState? cardState = await showDialog<CreateWidgetState>(
        context: context,
        builder: (BuildContext context) {
          return CreateWidget(
            pokemonCard: widget.pokemonCard,
          )
        });
    if (cardState == null) {
      return;
    }
    setState(() {
      myDatabase.addCard(MyCardsCompanion(
          name: drift.Value(widget.pokemonCard.name),
          etat: drift.Value(cardState._selectedCardState),
          nationalPokedexNumbers:
              drift.Value(widget.pokemonCard.nationalPokedexNumbers.first),
          language: drift.Value(cardState._selectedCardLanguage),
          cardType: drift.Value(cardState._type),
          cardID: drift.Value(widget.pokemonCard.id)));
    });
  }

  void _removeCard(MyCard item) {
    myDatabase.removeCard(item.id);
  }

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

class CreateWidget extends StatefulWidget {
  final PokemonCard pokemonCard;
  CreateWidget({Key? key, required this.pokemonCard}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateWidgetState();
}

class CreateWidgetState {
  String _selectedCardState = "Mint";
  String _selectedCardLanguage = "French";
  String _type = "normal";
}

class _CreateWidgetState extends State<CreateWidget> {
  late CreateWidgetState wid = new CreateWidgetState();

  void initState() {
    super.initState();
    wid._type = widget.pokemonCard.tcgPlayer.prices.map((e) => e.type).first;
  } 

  @override
  Widget build(BuildContext context) {
    Map<String, String> _cardStates = {
      "Mint": 'Mint'.i18n,
      "Near Mint": "Near Mint".i18n,
      "Played": "Played".i18n,
      "Damaged": "Damaged".i18n
    };
    Map<String, String> _cardLanguages = {
      "English": "English".i18n,
      "French": "French".i18n,
      "Italian": "Italian".i18n,
      "Spanish": "Spanish".i18n,
      "Chinese": "Chinese".i18n,
      "German": "German".i18n,
      "Japanese": "Japanese".i18n,
      "Korean": "Korean".i18n
    };

    return SimpleDialog(
      title: Text('Add a card'.i18n),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Quality'.i18n),
                  DropdownButton(
                    value: wid._selectedCardState,
                    items: _cardStates.entries
                        .map((code) => new DropdownMenuItem(
                            value: code.key, child: new Text(code.value)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        wid._selectedCardState = value.toString();
                      });
                    },
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Language'.i18n),
                  DropdownButton(
                    value: wid._selectedCardLanguage,
                    items: _cardLanguages.entries
                        .map((code) => new DropdownMenuItem(
                            value: code.key, child: new Text(code.value)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        wid._selectedCardLanguage = value.toString();
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Type'),
                  DropdownButton(
                    value: wid._type,
                    items: widget.pokemonCard.tcgPlayer.prices.map((e) => e.type)
                        .map((type) => new DropdownMenuItem(
                            value: type, child: new Text(type)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        wid._type = value.toString();
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                  child: Text('Abort'.i18n),
                  onPressed: () => {Navigator.pop(context, null)}),
              SizedBox(width: 8),
              OutlinedButton(
                  child: Text('Add'.i18n),
                  onPressed: () => {Navigator.pop(context, wid)})
            ],
          ),
        )
      ],
    );
  }
}
