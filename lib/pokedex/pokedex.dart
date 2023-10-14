import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/pokedex/pokemon.dart';
import 'package:pokecard_tcg/pokedex/search.dart';
import 'package:provider/provider.dart';
import 'package:pokecard_tcg/pokedex/pokedex.i18n.dart';

class PokedexPage extends StatefulWidget {
  @override
  _PokedexState createState() => _PokedexState();
}

class _PokedexState extends State<PokedexPage> {
  Future<List<Pokemon>> getPokemons({required BuildContext context}) async {
    String data =
        await DefaultAssetBundle.of(context).loadString('assets/pokedex.json');
    return (json.decode(data) as List)
        .map((e) => new Pokemon.fromJson(e))
        .toList();
  }

  Future<List<Pokemon>> filterPokemons(
      List<Pokemon> pokemons, Database myDatabase) async {
    List<Pokemon> selectedPokemon = [];
    if (_value == 1) {
      return pokemons;
    } else if (_value == 2) {
      await Future.forEach(pokemons, (element) async {
        bool b = await _isCaptured((element).id, myDatabase);
        if (b) {
          selectedPokemon.add(element);
        }
      });
    } else {
      await Future.forEach(pokemons, (element) async {
        bool b = await _isCaptured(element.id, myDatabase);
        if (!b) {
          selectedPokemon.add(element);
        }
      });
    }
    return selectedPokemon;
  }

  Future<List<Pokemon>> getFilteredPokemons(
      {required BuildContext context, required Database database}) async {
    Future<List<Pokemon>> pokemons = getPokemons(context: context);
    return filterPokemons(await pokemons, database);
  }

  /// 1 all
  /// 2 Catched
  /// 3 Not Catched
  int? _value = 1;
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<Pokemon>>(
          future: getFilteredPokemons(
              context: context, database: Provider.of<Database>(context)),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Expanded(
                child: Scrollbar(
                    controller: controller,
                    thumbVisibility: true,
                    interactive: true,
                    child: ListView.builder(
                      controller: controller,
                      itemExtent: 60,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return PokemonListItem(snapshot.data![index],
                            Provider.of<Database>(context));
                      },
                    )),
              );
            }
            return CircularProgressIndicator();
          },
        ),
        Wrap(spacing: 3, children: [
          ChoiceChip(
              label: Text("All".i18n),
              selected: _value == 1,
              onSelected: (bool selected) {
                setState(() {
                  _value = 1;
                });
              }),
          ChoiceChip(
              label: Text("Catched".i18n),
              selected: _value == 2,
              onSelected: (bool selected) {
                setState(() {
                  _value = 2;
                });
              }),
          ChoiceChip(
              label: Text("Not catched".i18n),
              selected: _value == 3,
              onSelected: (bool selected) {
                setState(() {
                  _value = 3;
                });
              })
        ])
      ],
    );
  }
}

class PokemonListItem extends StatelessWidget {
  final Pokemon data;
  final Database myDatabase;

  PokemonListItem(this.data, this.myDatabase);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.of(context).push(
              _toSearch(new SearchCriteria(data.id, (data.name)['french'])));
        },
        child: ListTile(
          leading: (new FutureBuilder(
              initialData: false,
              future: _isCaptured(data.id, myDatabase),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.data!) {
                  return const Icon(Icons.check_box);
                }
                return const Icon(Icons.check_box_outline_blank);
              })),
          title: Text((data.name)['french']),
          subtitle: Text(
              "${'Pokemon Number '.i18n} ${data.id} - ${(data.name)['english']}"),
        ));
  }
}

Future<bool> _isCaptured(int id, Database myDatabase) async {
  return myDatabase.allCardEntries.then(
      (value) => value.any((element) => element.nationalPokedexNumbers == id));
}

Route _toSearch(SearchCriteria aSearchCriteria) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => SearchPokemonPage(
      search: (aSearchCriteria),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
