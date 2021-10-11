import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pokemon_tcg/model/database.dart';
import 'package:pokemon_tcg/pokedex/search.dart';
import 'package:provider/provider.dart';
import 'package:pokemon_tcg/pokedex/pokedex.i18n.dart';

class PokedexPage extends StatefulWidget {
  @override
  _PokedexState createState() => _PokedexState();
}

class _PokedexState extends State<PokedexPage> {
  Future<List> getPokemons({required BuildContext context}) async {
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
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return PokemonListItem(
                  snapshot.data![index], Provider.of<Database>(context));
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
  final Database myDatabase;

  PokemonListItem(this.data, this.myDatabase);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.of(context).push(_toSearch((data['name'])['english']));
        },
        child: ListTile(
          leading: (new FutureBuilder(
              future: _isCapture(data['id']),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData) {
                  return const Icon(Icons.circle);
                }
                if (snapshot.data!) {
                  return const Icon(Icons.check_box);
                }
                return const Icon(Icons.check_box_outline_blank);
              })),
          title: Text((data['name'])['french']),
          subtitle: Text('Pokemon Number '.i18n +
              (data['id']).toString() +
              ' - ' +
              (data['name'])['english']),
        ));
  }

  Future<bool> _isCapture(int id) {
    return myDatabase.allCardEntries.then((value) =>
        value.any((element) => element.nationalPokedexNumbers == id));
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
