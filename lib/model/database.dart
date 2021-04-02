// don't import moor_web.dart or moor_flutter/moor_flutter.dart in shared code
import 'package:moor/moor.dart';
export 'database/shared.dart';

part 'database.g.dart';

class MyCards extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get language => text()();
  TextColumn get etat => text()();
  IntColumn get nationalPokedexNumbers => integer()();
  TextColumn get cardID => text()();
}

@UseMoor(tables: [MyCards])
class Database extends _$Database {
  // we tell the database where to store the data with this constructor
  Database(QueryExecutor e) : super(e);

  Future<List<MyCard>> get allCardEntries => select(myCards).get();

  Future<List<MyCard>> allCardWithId(String id) {
    return (select(myCards)..where((card) => card.cardID.equals(id))).get();
  }

  // returns the generated id
  Future<int> addCard(MyCardsCompanion entry) {
    return into(myCards).insert(entry);
  }

  // returns the generated id
  Future removeCard(int id) {
    return (delete(myCards)..where((tbl) => tbl.id.equals(id))).go();
  }

  // you should bump this number whenever you change or add a table definition. Migrations
  // are covered later in this readme.
  @override
  int get schemaVersion => 2;
}
