import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:pokemon_tcg/collection/card_detail.dart';
import 'package:pokemon_tcg/tcg_api/model/card.dart';

class PokemondGridCard extends StatelessWidget {
  final PokemonCard _pokemoncard;

  PokemondGridCard(this._pokemoncard);

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image.network(_pokemoncard.images.small, loadingBuilder:
          (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      }),
      Positioned.fill(
        child: Material(
            color: Colors.transparent,
            child: InkWell(
                splashColor: Colors.blue.withAlpha(30),
                onTap: () {
                  Navigator.of(context).push(_toDetail(_pokemoncard));
                })),
      ),
    ]);
  }
}

Route _toDetail(PokemonCard pokemoncard) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        PokemonCardDetailPage(
      pokemonCard: pokemoncard,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child);
    },
  );
}
