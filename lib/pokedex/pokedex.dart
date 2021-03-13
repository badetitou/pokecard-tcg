import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pokemon_tcg/pokedex/search.dart';

class PokedexPage extends StatefulWidget {
  @override
  _PokedexState createState() => _PokedexState();
}

class _PokedexState extends State<PokedexPage> {
  Future<List> getPokemons({BuildContext context}) async {
    String data =
        await DefaultAssetBundle.of(context).loadString('assets/pokedex.json');
    return json.decode(data);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: getPokemons(context: context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              return PokemonListItem(snapshot.data[index]);
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}

class PokemonListItem extends StatelessWidget {
  final dynamic data;

  PokemonListItem(this.data);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.of(context).push(_toSearch((data['name'])['english']));
        },
        child: ListTile(
          title: Text((data['name'])['french']),
          subtitle: Text('Pokemon Number ' +
              (data['id']).toString() +
              ' - ' +
              (data['name'])['english']),
        ));
  }
}

Route _toSearch(String aResearchString) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SearchPokemonPage(
      search: (aResearchString),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
