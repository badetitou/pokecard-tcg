import 'package:flutter/material.dart';
import 'package:pokecard_tcg/search/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchCriteria {
  final int pokemonId;
  final String pokemonName;

  SearchCriteria(this.pokemonId, this.pokemonName);
}

class SearchPokemonPage extends StatefulWidget {
  final SearchCriteria search;

  const SearchPokemonPage({required this.search}) : super();

  @override
  _SearchPokemonState createState() => _SearchPokemonState();
}

class _SearchPokemonState extends State<SearchPokemonPage> {
  int? minGridSize;

  @override
  void initState() {
    super.initState();
    this.initGridSize();
  }

  void initGridSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      minGridSize = prefs.getInt('gridSize') ?? 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    var result;
    if (minGridSize == null) {
      result = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      result = SearchResultsGridView(
          'nationalPokedexNumbers:' + widget.search.pokemonId.toString(),
          minGridSize: minGridSize!);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.search.pokemonName),
      ),
      body: result,
    );
  }
}
