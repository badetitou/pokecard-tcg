import 'package:flutter/material.dart';
import 'package:pokemon_tcg/collection/card_detail.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';

class PokemondGridCard extends StatelessWidget {
  final PokemonCard _pokemoncard;

  PokemondGridCard(this._pokemoncard);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.blue.withAlpha(30),
      onTap: () {
        Navigator.of(context).push(_toDetail(_pokemoncard));
      },
      child: Container(
        height: 30,
        child: Image.network(_pokemoncard.images.small),
      ),
    );
  }
}

Route _toDetail(PokemonCard pokemoncard) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        PokemonCardDetailPage(
      pokemonCard: pokemoncard,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return child;
    },
  );
}
