// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MyCardsTable extends MyCards with TableInfo<$MyCardsTable, MyCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _languageMeta =
      const VerificationMeta('language');
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
      'language', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _etatMeta = const VerificationMeta('etat');
  @override
  late final GeneratedColumn<String> etat = GeneratedColumn<String>(
      'etat', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardTypeMeta =
      const VerificationMeta('cardType');
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
      'card_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nationalPokedexNumbersMeta =
      const VerificationMeta('nationalPokedexNumbers');
  @override
  late final GeneratedColumn<int> nationalPokedexNumbers = GeneratedColumn<int>(
      'national_pokedex_numbers', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _cardIDMeta = const VerificationMeta('cardID');
  @override
  late final GeneratedColumn<String> cardID = GeneratedColumn<String>(
      'card_i_d', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, language, etat, cardType, nationalPokedexNumbers, cardID];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_cards';
  @override
  VerificationContext validateIntegrity(Insertable<MyCard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('language')) {
      context.handle(_languageMeta,
          language.isAcceptableOrUnknown(data['language']!, _languageMeta));
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('etat')) {
      context.handle(
          _etatMeta, etat.isAcceptableOrUnknown(data['etat']!, _etatMeta));
    } else if (isInserting) {
      context.missing(_etatMeta);
    }
    if (data.containsKey('card_type')) {
      context.handle(_cardTypeMeta,
          cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta));
    } else if (isInserting) {
      context.missing(_cardTypeMeta);
    }
    if (data.containsKey('national_pokedex_numbers')) {
      context.handle(
          _nationalPokedexNumbersMeta,
          nationalPokedexNumbers.isAcceptableOrUnknown(
              data['national_pokedex_numbers']!, _nationalPokedexNumbersMeta));
    }
    if (data.containsKey('card_i_d')) {
      context.handle(_cardIDMeta,
          cardID.isAcceptableOrUnknown(data['card_i_d']!, _cardIDMeta));
    } else if (isInserting) {
      context.missing(_cardIDMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyCard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      language: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}language'])!,
      etat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}etat'])!,
      cardType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_type'])!,
      nationalPokedexNumbers: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}national_pokedex_numbers']),
      cardID: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_i_d'])!,
    );
  }

  @override
  $MyCardsTable createAlias(String alias) {
    return $MyCardsTable(attachedDatabase, alias);
  }
}

class MyCard extends DataClass implements Insertable<MyCard> {
  final int id;
  final String name;
  final String language;
  final String etat;
  final String cardType;
  final int? nationalPokedexNumbers;
  final String cardID;
  const MyCard(
      {required this.id,
      required this.name,
      required this.language,
      required this.etat,
      required this.cardType,
      this.nationalPokedexNumbers,
      required this.cardID});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['language'] = Variable<String>(language);
    map['etat'] = Variable<String>(etat);
    map['card_type'] = Variable<String>(cardType);
    if (!nullToAbsent || nationalPokedexNumbers != null) {
      map['national_pokedex_numbers'] = Variable<int>(nationalPokedexNumbers);
    }
    map['card_i_d'] = Variable<String>(cardID);
    return map;
  }

  MyCardsCompanion toCompanion(bool nullToAbsent) {
    return MyCardsCompanion(
      id: Value(id),
      name: Value(name),
      language: Value(language),
      etat: Value(etat),
      cardType: Value(cardType),
      nationalPokedexNumbers: nationalPokedexNumbers == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalPokedexNumbers),
      cardID: Value(cardID),
    );
  }

  factory MyCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyCard(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      language: serializer.fromJson<String>(json['language']),
      etat: serializer.fromJson<String>(json['etat']),
      cardType: serializer.fromJson<String>(json['cardType']),
      nationalPokedexNumbers:
          serializer.fromJson<int?>(json['nationalPokedexNumbers']),
      cardID: serializer.fromJson<String>(json['cardID']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'language': serializer.toJson<String>(language),
      'etat': serializer.toJson<String>(etat),
      'cardType': serializer.toJson<String>(cardType),
      'nationalPokedexNumbers': serializer.toJson<int?>(nationalPokedexNumbers),
      'cardID': serializer.toJson<String>(cardID),
    };
  }

  MyCard copyWith(
          {int? id,
          String? name,
          String? language,
          String? etat,
          String? cardType,
          Value<int?> nationalPokedexNumbers = const Value.absent(),
          String? cardID}) =>
      MyCard(
        id: id ?? this.id,
        name: name ?? this.name,
        language: language ?? this.language,
        etat: etat ?? this.etat,
        cardType: cardType ?? this.cardType,
        nationalPokedexNumbers: nationalPokedexNumbers.present
            ? nationalPokedexNumbers.value
            : this.nationalPokedexNumbers,
        cardID: cardID ?? this.cardID,
      );
  @override
  String toString() {
    return (StringBuffer('MyCard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('etat: $etat, ')
          ..write('cardType: $cardType, ')
          ..write('nationalPokedexNumbers: $nationalPokedexNumbers, ')
          ..write('cardID: $cardID')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, language, etat, cardType, nationalPokedexNumbers, cardID);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyCard &&
          other.id == this.id &&
          other.name == this.name &&
          other.language == this.language &&
          other.etat == this.etat &&
          other.cardType == this.cardType &&
          other.nationalPokedexNumbers == this.nationalPokedexNumbers &&
          other.cardID == this.cardID);
}

class MyCardsCompanion extends UpdateCompanion<MyCard> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> language;
  final Value<String> etat;
  final Value<String> cardType;
  final Value<int?> nationalPokedexNumbers;
  final Value<String> cardID;
  const MyCardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.language = const Value.absent(),
    this.etat = const Value.absent(),
    this.cardType = const Value.absent(),
    this.nationalPokedexNumbers = const Value.absent(),
    this.cardID = const Value.absent(),
  });
  MyCardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String language,
    required String etat,
    required String cardType,
    this.nationalPokedexNumbers = const Value.absent(),
    required String cardID,
  })  : name = Value(name),
        language = Value(language),
        etat = Value(etat),
        cardType = Value(cardType),
        cardID = Value(cardID);
  static Insertable<MyCard> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? language,
    Expression<String>? etat,
    Expression<String>? cardType,
    Expression<int>? nationalPokedexNumbers,
    Expression<String>? cardID,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (language != null) 'language': language,
      if (etat != null) 'etat': etat,
      if (cardType != null) 'card_type': cardType,
      if (nationalPokedexNumbers != null)
        'national_pokedex_numbers': nationalPokedexNumbers,
      if (cardID != null) 'card_i_d': cardID,
    });
  }

  MyCardsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? language,
      Value<String>? etat,
      Value<String>? cardType,
      Value<int?>? nationalPokedexNumbers,
      Value<String>? cardID}) {
    return MyCardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      etat: etat ?? this.etat,
      cardType: cardType ?? this.cardType,
      nationalPokedexNumbers:
          nationalPokedexNumbers ?? this.nationalPokedexNumbers,
      cardID: cardID ?? this.cardID,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (etat.present) {
      map['etat'] = Variable<String>(etat.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (nationalPokedexNumbers.present) {
      map['national_pokedex_numbers'] =
          Variable<int>(nationalPokedexNumbers.value);
    }
    if (cardID.present) {
      map['card_i_d'] = Variable<String>(cardID.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyCardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('language: $language, ')
          ..write('etat: $etat, ')
          ..write('cardType: $cardType, ')
          ..write('nationalPokedexNumbers: $nationalPokedexNumbers, ')
          ..write('cardID: $cardID')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  late final $MyCardsTable myCards = $MyCardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [myCards];
}
