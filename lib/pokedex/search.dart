import 'package:flutter/material.dart';
import 'package:pokemon_tcg/search/search.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.search.pokemonName),
      ),
      body: SearchResultsGridView(
          'nationalPokedexNumbers:' + widget.search.pokemonId.toString()),
    );
  }
}
