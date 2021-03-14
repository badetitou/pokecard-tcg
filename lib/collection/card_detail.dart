import 'package:flutter/material.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';
import 'package:pokemon_tcg/tcg_api/model/prices.dart';

class PokemonCardDetailPage extends StatefulWidget {
  final PokemonCard pokemonCard;

  const PokemonCardDetailPage({required this.pokemonCard}) : super();

  @override
  _PokemonCardDetailState createState() => _PokemonCardDetailState();
}

class _PokemonCardDetailState extends State<PokemonCardDetailPage> {
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
                  trailing: RichText(
                      text: TextSpan(text: widget.pokemonCard.hp, children: [
                    TextSpan(text: ' HP '),
                  ])),
                ),
                Divider(),
                RichText(
                    text: TextSpan(
                  text: 'Price: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )),
                SingleChildScrollView(
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
                Divider(),
                Row(
                  children: [
                    RichText(
                        text: TextSpan(
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
                Divider(),
                Text(
                  widget.pokemonCard.flavorText.toString(),
                  style: TextStyle(fontStyle: FontStyle.italic),
                  softWrap: true,
                )
              ])),
        ],
      ),
    );
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
