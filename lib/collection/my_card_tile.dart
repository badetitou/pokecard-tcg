import 'package:flutter/material.dart';
import 'package:pokecard_tcg/model/database.dart';
import 'package:pokecard_tcg/collection/card_detail.i18n.dart';

class MyCardTile extends StatelessWidget {
  final MyCard myCard;
  final Function() onDelete;

  MyCardTile({required this.myCard, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(myCard.name.toString()),
          subtitle: Text(myCard.etat.toString().i18n +
              ' - ' +
              myCard.language.toString().i18n),
          trailing: IconButton(
            icon: Icon(Icons.remove),
            onPressed: onDelete,
            tooltip: 'Remove'.i18n,
          )),
    );
  }
}
