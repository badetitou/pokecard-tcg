import 'package:flutter/material.dart';
import 'package:pokemon_tcg/model/database.dart';

class MyCardTile extends StatelessWidget {
  final MyCard myCard;
  final Function() onDelete;

  MyCardTile({required this.myCard, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(myCard.name.toString()),
          subtitle: Text(myCard.etat.toString()),
          trailing: IconButton(
            icon: Icon(Icons.remove),
            onPressed: onDelete,
            tooltip: 'Remove',
          )),
    );
  }
}
