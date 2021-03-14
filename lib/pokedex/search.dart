import 'package:flutter/material.dart';
import 'package:pokemon_tcg/search/search.dart';

class SearchPokemonPage extends StatefulWidget {
  final String search;

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
        title: Text(widget.search),
      ),
      body: SearchResultsGridView('name:' + widget.search),
    );
  }
}
