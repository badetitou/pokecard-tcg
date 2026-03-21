import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:pokecard_tcg/collection/my_card_tile.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:pokecard_tcg/tcg_api/model/prices.dart';
import 'package:pokecard_tcg/tcg_api/tcg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pokecard_tcg/collection/card_detail.i18n.dart';

class PokemonCardDetailPage extends StatefulWidget {
  final PokemonCard pokemonCard;

  const PokemonCardDetailPage({super.key, required this.pokemonCard});

  @override
  _PokemonCardDetailState createState() => _PokemonCardDetailState();
}

class _PokemonCardDetailState extends State<PokemonCardDetailPage> {
  late Database myDatabase;
  late Future<PokemonCard> _cardFuture;

  @override
  void initState() {
    super.initState();
    _cardFuture = _loadCardDetails();
  }

  Future<PokemonCard> _loadCardDetails() async {
    try {
      return await TCG.fetchCard(widget.pokemonCard.id);
    } catch (_) {
      // Keep local/brief data available when remote details are unavailable.
      return widget.pokemonCard;
    }
  }

  @override
  Widget build(BuildContext context) {
    myDatabase = Provider.of<Database>(context);
    return FutureBuilder<PokemonCard>(
      future: _cardFuture,
      builder: (context, cardSnapshot) {
        final displayedCard = cardSnapshot.data ?? widget.pokemonCard;
        return Scaffold(
            appBar: AppBar(
              title: Text(
                  '${displayedCard.supertype} ${displayedCard.subtypes} : ${displayedCard.name}'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                      child: Column(
                          // Header
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        ListTile(
                          title: Text(displayedCard.name),
                          subtitle: Text(displayedCard.id),
                          trailing: Text.rich(
                              TextSpan(text: displayedCard.hp, children: [
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
                          child: displayedCard.tcgPlayer.prices.isEmpty
                              ? Text('No pricing data available')
                              : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'Type',
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Market'.i18n,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Low'.i18n,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Mid'.i18n,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'High'.i18n,
                                          style: TextStyle(
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                    ],
                                    rows:
                                        prices(displayedCard.tcgPlayer.prices),
                                  )),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Column(
                                children: [
                                  Text.rich(TextSpan(
                                    text: 'Illustrator: '.i18n,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, height: 2),
                                  )),
                                  Text.rich(TextSpan(
                                    text: displayedCard.artist,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        height: 2),
                                  )),
                                ],
                              ),
                              Expanded(child: Container()),
                              OutlinedButton(
                                  onPressed: () {
                                    _showCardImage(context, displayedCard);
                                  },
                                  child: Text('View Card'.i18n)),
                            ],
                          ),
                        ),
                        Divider(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            displayedCard.flavorText.toString(),
                            style: TextStyle(fontStyle: FontStyle.italic),
                            softWrap: true,
                          ),
                        ),
                      ])),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.all(10.0),
                      child: FutureBuilder(
                        future: myDatabase.allCardWithId(displayedCard.id),
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
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => setState(() {
                _addCard(displayedCard);
              }),
              tooltip: 'Add card to my collection'.i18n,
              child: const Icon(Icons.add),
            ));
      },
    );
  }

  Future<void> _addCard(PokemonCard currentCard) async {
    CreateWidgetState? cardState = await showDialog<CreateWidgetState>(
        context: context,
        builder: (BuildContext context) {
          return CreateWidget(
            pokemonCard: currentCard,
          );
        });
    if (cardState == null) {
      return;
    }
    setState(() {
      myDatabase.addCard(MyCardsCompanion(
          name: drift.Value(currentCard.name),
          etat: drift.Value(cardState._selectedCardState),
          nationalPokedexNumbers: drift.Value(
              currentCard.nationalPokedexNumbers.isNotEmpty
                  ? currentCard.nationalPokedexNumbers.first
                  : null),
          language: drift.Value(cardState._selectedCardLanguage),
          cardType: drift.Value(cardState._type),
          cardID: drift.Value(currentCard.id)));
    });
  }

  void _removeCard(MyCard item) {
    myDatabase.removeCard(item.id);
  }

  void _showCardImage(BuildContext context, PokemonCard card) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return CachedNetworkImage(
            imageUrl: card.images.large,
            placeholder: (context, url) =>
                const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
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
  const CreateWidget({super.key, required this.pokemonCard});

  @override
  State<StatefulWidget> createState() => _CreateWidgetState();
}

class CreateWidgetState {
  String _selectedCardState = "Mint";
  String _selectedCardLanguage = "French";
  String _type = "normal";
}

class _CreateWidgetState extends State<CreateWidget> {
  late CreateWidgetState wid = CreateWidgetState();
  late List<String> _availableCardTypes;

  @override
  void initState() {
    super.initState();
    _availableCardTypes =
        widget.pokemonCard.tcgPlayer.prices.map((e) => e.type).toSet().toList();

    if (_availableCardTypes.isEmpty) {
      _availableCardTypes = ['normal'];
    }
    wid._type = _availableCardTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> cardStates = {
      "Mint": 'Mint'.i18n,
      "Near Mint": "Near Mint".i18n,
      "Played": "Played".i18n,
      "Damaged": "Damaged".i18n
    };
    Map<String, String> cardLanguages = {
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
                    items: cardStates.entries
                        .map((code) => DropdownMenuItem(
                            value: code.key, child: Text(code.value)))
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
                    items: cardLanguages.entries
                        .map((code) => DropdownMenuItem(
                            value: code.key, child: Text(code.value)))
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
                    items: _availableCardTypes
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
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
