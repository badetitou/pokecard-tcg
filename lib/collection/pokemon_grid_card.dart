import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:pokecard_tcg/collection/card_detail.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/tcg_api/model/card.dart';
import 'package:provider/provider.dart';

class PokemondGridCard extends StatelessWidget {
  final PokemonCard _pokemoncard;
  late Database _database;

  PokemondGridCard(this._pokemoncard);

  @override
  Widget build(BuildContext context) {
    this._database = Provider.of<Database>(context);
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
      new FutureBuilder(
          future: _cardAcquired(this._pokemoncard),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData || !snapshot.data!) {
              return Container();
            }
            return Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary),
                child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      Icons.check,
                      size: 30.0,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    )));
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

  Future<bool> _cardAcquired(PokemonCard pokemonCard) {
    return _database.allCardEntries.then(
        (value) => value.any((element) => element.cardID == pokemonCard.id));
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
