// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_database.dart';

// ignore_for_file: type=lint
class $CardDefinitionsTable extends CardDefinitions
    with TableInfo<$CardDefinitionsTable, CardDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issuerMeta = const VerificationMeta('issuer');
  @override
  late final GeneratedColumn<String> issuer = GeneratedColumn<String>(
    'issuer',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _issuedAtMeta = const VerificationMeta(
    'issuedAt',
  );
  @override
  late final GeneratedColumn<String> issuedAt = GeneratedColumn<String>(
    'issued_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardTypeMeta = const VerificationMeta(
    'cardType',
  );
  @override
  late final GeneratedColumn<String> cardType = GeneratedColumn<String>(
    'card_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _needsCompletionMeta = const VerificationMeta(
    'needsCompletion',
  );
  @override
  late final GeneratedColumn<bool> needsCompletion = GeneratedColumn<bool>(
    'needs_completion',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_completion" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    city,
    issuer,
    issuedAt,
    code,
    notes,
    cardType,
    needsCompletion,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('issuer')) {
      context.handle(
        _issuerMeta,
        issuer.isAcceptableOrUnknown(data['issuer']!, _issuerMeta),
      );
    }
    if (data.containsKey('issued_at')) {
      context.handle(
        _issuedAtMeta,
        issuedAt.isAcceptableOrUnknown(data['issued_at']!, _issuedAtMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('card_type')) {
      context.handle(
        _cardTypeMeta,
        cardType.isAcceptableOrUnknown(data['card_type']!, _cardTypeMeta),
      );
    }
    if (data.containsKey('needs_completion')) {
      context.handle(
        _needsCompletionMeta,
        needsCompletion.isAcceptableOrUnknown(
          data['needs_completion']!,
          _needsCompletionMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      issuer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issuer'],
      ),
      issuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issued_at'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      cardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_type'],
      ),
      needsCompletion: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_completion'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CardDefinitionsTable createAlias(String alias) {
    return $CardDefinitionsTable(attachedDatabase, alias);
  }
}

class CardDefinition extends DataClass implements Insertable<CardDefinition> {
  final String id;
  final String name;
  final String? city;
  final String? issuer;

  /// 部分日期的规范化文本：`YYYY`、`YYYY-MM` 或 `YYYY-MM-DD`。
  final String? issuedAt;
  final String? code;
  final String? notes;
  final String? cardType;
  final bool needsCompletion;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CardDefinition({
    required this.id,
    required this.name,
    this.city,
    this.issuer,
    this.issuedAt,
    this.code,
    this.notes,
    this.cardType,
    required this.needsCompletion,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || issuer != null) {
      map['issuer'] = Variable<String>(issuer);
    }
    if (!nullToAbsent || issuedAt != null) {
      map['issued_at'] = Variable<String>(issuedAt);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || cardType != null) {
      map['card_type'] = Variable<String>(cardType);
    }
    map['needs_completion'] = Variable<bool>(needsCompletion);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CardDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return CardDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      issuer: issuer == null && nullToAbsent
          ? const Value.absent()
          : Value(issuer),
      issuedAt: issuedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(issuedAt),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      cardType: cardType == null && nullToAbsent
          ? const Value.absent()
          : Value(cardType),
      needsCompletion: Value(needsCompletion),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CardDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardDefinition(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      city: serializer.fromJson<String?>(json['city']),
      issuer: serializer.fromJson<String?>(json['issuer']),
      issuedAt: serializer.fromJson<String?>(json['issuedAt']),
      code: serializer.fromJson<String?>(json['code']),
      notes: serializer.fromJson<String?>(json['notes']),
      cardType: serializer.fromJson<String?>(json['cardType']),
      needsCompletion: serializer.fromJson<bool>(json['needsCompletion']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'city': serializer.toJson<String?>(city),
      'issuer': serializer.toJson<String?>(issuer),
      'issuedAt': serializer.toJson<String?>(issuedAt),
      'code': serializer.toJson<String?>(code),
      'notes': serializer.toJson<String?>(notes),
      'cardType': serializer.toJson<String?>(cardType),
      'needsCompletion': serializer.toJson<bool>(needsCompletion),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CardDefinition copyWith({
    String? id,
    String? name,
    Value<String?> city = const Value.absent(),
    Value<String?> issuer = const Value.absent(),
    Value<String?> issuedAt = const Value.absent(),
    Value<String?> code = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> cardType = const Value.absent(),
    bool? needsCompletion,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CardDefinition(
    id: id ?? this.id,
    name: name ?? this.name,
    city: city.present ? city.value : this.city,
    issuer: issuer.present ? issuer.value : this.issuer,
    issuedAt: issuedAt.present ? issuedAt.value : this.issuedAt,
    code: code.present ? code.value : this.code,
    notes: notes.present ? notes.value : this.notes,
    cardType: cardType.present ? cardType.value : this.cardType,
    needsCompletion: needsCompletion ?? this.needsCompletion,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CardDefinition copyWithCompanion(CardDefinitionsCompanion data) {
    return CardDefinition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      city: data.city.present ? data.city.value : this.city,
      issuer: data.issuer.present ? data.issuer.value : this.issuer,
      issuedAt: data.issuedAt.present ? data.issuedAt.value : this.issuedAt,
      code: data.code.present ? data.code.value : this.code,
      notes: data.notes.present ? data.notes.value : this.notes,
      cardType: data.cardType.present ? data.cardType.value : this.cardType,
      needsCompletion: data.needsCompletion.present
          ? data.needsCompletion.value
          : this.needsCompletion,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardDefinition(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('issuer: $issuer, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('code: $code, ')
          ..write('notes: $notes, ')
          ..write('cardType: $cardType, ')
          ..write('needsCompletion: $needsCompletion, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    city,
    issuer,
    issuedAt,
    code,
    notes,
    cardType,
    needsCompletion,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardDefinition &&
          other.id == this.id &&
          other.name == this.name &&
          other.city == this.city &&
          other.issuer == this.issuer &&
          other.issuedAt == this.issuedAt &&
          other.code == this.code &&
          other.notes == this.notes &&
          other.cardType == this.cardType &&
          other.needsCompletion == this.needsCompletion &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CardDefinitionsCompanion extends UpdateCompanion<CardDefinition> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> city;
  final Value<String?> issuer;
  final Value<String?> issuedAt;
  final Value<String?> code;
  final Value<String?> notes;
  final Value<String?> cardType;
  final Value<bool> needsCompletion;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CardDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.city = const Value.absent(),
    this.issuer = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.code = const Value.absent(),
    this.notes = const Value.absent(),
    this.cardType = const Value.absent(),
    this.needsCompletion = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardDefinitionsCompanion.insert({
    required String id,
    required String name,
    this.city = const Value.absent(),
    this.issuer = const Value.absent(),
    this.issuedAt = const Value.absent(),
    this.code = const Value.absent(),
    this.notes = const Value.absent(),
    this.cardType = const Value.absent(),
    this.needsCompletion = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CardDefinition> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? city,
    Expression<String>? issuer,
    Expression<String>? issuedAt,
    Expression<String>? code,
    Expression<String>? notes,
    Expression<String>? cardType,
    Expression<bool>? needsCompletion,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (city != null) 'city': city,
      if (issuer != null) 'issuer': issuer,
      if (issuedAt != null) 'issued_at': issuedAt,
      if (code != null) 'code': code,
      if (notes != null) 'notes': notes,
      if (cardType != null) 'card_type': cardType,
      if (needsCompletion != null) 'needs_completion': needsCompletion,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? city,
    Value<String?>? issuer,
    Value<String?>? issuedAt,
    Value<String?>? code,
    Value<String?>? notes,
    Value<String?>? cardType,
    Value<bool>? needsCompletion,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CardDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      city: city ?? this.city,
      issuer: issuer ?? this.issuer,
      issuedAt: issuedAt ?? this.issuedAt,
      code: code ?? this.code,
      notes: notes ?? this.notes,
      cardType: cardType ?? this.cardType,
      needsCompletion: needsCompletion ?? this.needsCompletion,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (issuer.present) {
      map['issuer'] = Variable<String>(issuer.value);
    }
    if (issuedAt.present) {
      map['issued_at'] = Variable<String>(issuedAt.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (cardType.present) {
      map['card_type'] = Variable<String>(cardType.value);
    }
    if (needsCompletion.present) {
      map['needs_completion'] = Variable<bool>(needsCompletion.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('city: $city, ')
          ..write('issuer: $issuer, ')
          ..write('issuedAt: $issuedAt, ')
          ..write('code: $code, ')
          ..write('notes: $notes, ')
          ..write('cardType: $cardType, ')
          ..write('needsCompletion: $needsCompletion, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardItemsTable extends CardItems
    with TableInfo<$CardItemsTable, CardItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_definitions (id)',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    check: () => ComparableExpr(quantity).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _acquiredAtMeta = const VerificationMeta(
    'acquiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> acquiredAt = GeneratedColumn<DateTime>(
    'acquired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    definitionId,
    quantity,
    acquiredAt,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('acquired_at')) {
      context.handle(
        _acquiredAtMeta,
        acquiredAt.isAcceptableOrUnknown(data['acquired_at']!, _acquiredAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      acquiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acquired_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CardItemsTable createAlias(String alias) {
    return $CardItemsTable(attachedDatabase, alias);
  }
}

class CardItem extends DataClass implements Insertable<CardItem> {
  final String id;
  final String definitionId;
  final int quantity;
  final DateTime? acquiredAt;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 软删除标记。Feature 001 恒为 null。
  final DateTime? deletedAt;
  const CardItem({
    required this.id,
    required this.definitionId,
    required this.quantity,
    this.acquiredAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['definition_id'] = Variable<String>(definitionId);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || acquiredAt != null) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt);
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CardItemsCompanion toCompanion(bool nullToAbsent) {
    return CardItemsCompanion(
      id: Value(id),
      definitionId: Value(definitionId),
      quantity: Value(quantity),
      acquiredAt: acquiredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acquiredAt),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CardItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardItem(
      id: serializer.fromJson<String>(json['id']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      acquiredAt: serializer.fromJson<DateTime?>(json['acquiredAt']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'definitionId': serializer.toJson<String>(definitionId),
      'quantity': serializer.toJson<int>(quantity),
      'acquiredAt': serializer.toJson<DateTime?>(acquiredAt),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CardItem copyWith({
    String? id,
    String? definitionId,
    int? quantity,
    Value<DateTime?> acquiredAt = const Value.absent(),
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CardItem(
    id: id ?? this.id,
    definitionId: definitionId ?? this.definitionId,
    quantity: quantity ?? this.quantity,
    acquiredAt: acquiredAt.present ? acquiredAt.value : this.acquiredAt,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CardItem copyWithCompanion(CardItemsCompanion data) {
    return CardItem(
      id: data.id.present ? data.id.value : this.id,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      acquiredAt: data.acquiredAt.present
          ? data.acquiredAt.value
          : this.acquiredAt,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardItem(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('quantity: $quantity, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    definitionId,
    quantity,
    acquiredAt,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardItem &&
          other.id == this.id &&
          other.definitionId == this.definitionId &&
          other.quantity == this.quantity &&
          other.acquiredAt == this.acquiredAt &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CardItemsCompanion extends UpdateCompanion<CardItem> {
  final Value<String> id;
  final Value<String> definitionId;
  final Value<int> quantity;
  final Value<DateTime?> acquiredAt;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CardItemsCompanion({
    this.id = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardItemsCompanion.insert({
    required String id,
    required String definitionId,
    this.quantity = const Value.absent(),
    this.acquiredAt = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       definitionId = Value(definitionId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CardItem> custom({
    Expression<String>? id,
    Expression<String>? definitionId,
    Expression<int>? quantity,
    Expression<DateTime>? acquiredAt,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (definitionId != null) 'definition_id': definitionId,
      if (quantity != null) 'quantity': quantity,
      if (acquiredAt != null) 'acquired_at': acquiredAt,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? definitionId,
    Value<int>? quantity,
    Value<DateTime?>? acquiredAt,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CardItemsCompanion(
      id: id ?? this.id,
      definitionId: definitionId ?? this.definitionId,
      quantity: quantity ?? this.quantity,
      acquiredAt: acquiredAt ?? this.acquiredAt,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (acquiredAt.present) {
      map['acquired_at'] = Variable<DateTime>(acquiredAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardItemsCompanion(')
          ..write('id: $id, ')
          ..write('definitionId: $definitionId, ')
          ..write('quantity: $quantity, ')
          ..write('acquiredAt: $acquiredAt, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardImagesTable extends CardImages
    with TableInfo<$CardImagesTable, CardImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardItemIdMeta = const VerificationMeta(
    'cardItemId',
  );
  @override
  late final GeneratedColumn<String> cardItemId = GeneratedColumn<String>(
    'card_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_items (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CardImageKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CardImageKind>($CardImagesTable.$converterkind);
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _derivedRelativePathMeta =
      const VerificationMeta('derivedRelativePath');
  @override
  late final GeneratedColumn<String> derivedRelativePath =
      GeneratedColumn<String>(
        'derived_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isCoverMeta = const VerificationMeta(
    'isCover',
  );
  @override
  late final GeneratedColumn<bool> isCover = GeneratedColumn<bool>(
    'is_cover',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_cover" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardItemId,
    kind,
    relativePath,
    derivedRelativePath,
    sortOrder,
    isCover,
    checksum,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_images';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardImage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_item_id')) {
      context.handle(
        _cardItemIdMeta,
        cardItemId.isAcceptableOrUnknown(
          data['card_item_id']!,
          _cardItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardItemIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('derived_relative_path')) {
      context.handle(
        _derivedRelativePathMeta,
        derivedRelativePath.isAcceptableOrUnknown(
          data['derived_relative_path']!,
          _derivedRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_cover')) {
      context.handle(
        _isCoverMeta,
        isCover.isAcceptableOrUnknown(data['is_cover']!, _isCoverMeta),
      );
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardImage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      cardItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_item_id'],
      )!,
      kind: $CardImagesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      derivedRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}derived_relative_path'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isCover: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_cover'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CardImagesTable createAlias(String alias) {
    return $CardImagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CardImageKind, String, String> $converterkind =
      const EnumNameConverter<CardImageKind>(CardImageKind.values);
}

class CardImage extends DataClass implements Insertable<CardImage> {
  final String id;
  final String cardItemId;
  final CardImageKind kind;

  /// 相对于受管图片根目录的路径，全库唯一。
  final String relativePath;

  /// 可选派生图。原图不可被裁切或增强结果覆盖。
  final String? derivedRelativePath;
  final int sortOrder;
  final bool isCover;

  /// 源文件 SHA-256，用于完整性校验与去重判断。
  final String checksum;
  final DateTime createdAt;

  /// 保留原图地从图集移除时写入；默认查询排除。
  final DateTime? deletedAt;
  const CardImage({
    required this.id,
    required this.cardItemId,
    required this.kind,
    required this.relativePath,
    this.derivedRelativePath,
    required this.sortOrder,
    required this.isCover,
    required this.checksum,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_item_id'] = Variable<String>(cardItemId);
    {
      map['kind'] = Variable<String>(
        $CardImagesTable.$converterkind.toSql(kind),
      );
    }
    map['relative_path'] = Variable<String>(relativePath);
    if (!nullToAbsent || derivedRelativePath != null) {
      map['derived_relative_path'] = Variable<String>(derivedRelativePath);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_cover'] = Variable<bool>(isCover);
    map['checksum'] = Variable<String>(checksum);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CardImagesCompanion toCompanion(bool nullToAbsent) {
    return CardImagesCompanion(
      id: Value(id),
      cardItemId: Value(cardItemId),
      kind: Value(kind),
      relativePath: Value(relativePath),
      derivedRelativePath: derivedRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(derivedRelativePath),
      sortOrder: Value(sortOrder),
      isCover: Value(isCover),
      checksum: Value(checksum),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CardImage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardImage(
      id: serializer.fromJson<String>(json['id']),
      cardItemId: serializer.fromJson<String>(json['cardItemId']),
      kind: $CardImagesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      derivedRelativePath: serializer.fromJson<String?>(
        json['derivedRelativePath'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isCover: serializer.fromJson<bool>(json['isCover']),
      checksum: serializer.fromJson<String>(json['checksum']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardItemId': serializer.toJson<String>(cardItemId),
      'kind': serializer.toJson<String>(
        $CardImagesTable.$converterkind.toJson(kind),
      ),
      'relativePath': serializer.toJson<String>(relativePath),
      'derivedRelativePath': serializer.toJson<String?>(derivedRelativePath),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isCover': serializer.toJson<bool>(isCover),
      'checksum': serializer.toJson<String>(checksum),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CardImage copyWith({
    String? id,
    String? cardItemId,
    CardImageKind? kind,
    String? relativePath,
    Value<String?> derivedRelativePath = const Value.absent(),
    int? sortOrder,
    bool? isCover,
    String? checksum,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CardImage(
    id: id ?? this.id,
    cardItemId: cardItemId ?? this.cardItemId,
    kind: kind ?? this.kind,
    relativePath: relativePath ?? this.relativePath,
    derivedRelativePath: derivedRelativePath.present
        ? derivedRelativePath.value
        : this.derivedRelativePath,
    sortOrder: sortOrder ?? this.sortOrder,
    isCover: isCover ?? this.isCover,
    checksum: checksum ?? this.checksum,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CardImage copyWithCompanion(CardImagesCompanion data) {
    return CardImage(
      id: data.id.present ? data.id.value : this.id,
      cardItemId: data.cardItemId.present
          ? data.cardItemId.value
          : this.cardItemId,
      kind: data.kind.present ? data.kind.value : this.kind,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      derivedRelativePath: data.derivedRelativePath.present
          ? data.derivedRelativePath.value
          : this.derivedRelativePath,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isCover: data.isCover.present ? data.isCover.value : this.isCover,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardImage(')
          ..write('id: $id, ')
          ..write('cardItemId: $cardItemId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('derivedRelativePath: $derivedRelativePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isCover: $isCover, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardItemId,
    kind,
    relativePath,
    derivedRelativePath,
    sortOrder,
    isCover,
    checksum,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardImage &&
          other.id == this.id &&
          other.cardItemId == this.cardItemId &&
          other.kind == this.kind &&
          other.relativePath == this.relativePath &&
          other.derivedRelativePath == this.derivedRelativePath &&
          other.sortOrder == this.sortOrder &&
          other.isCover == this.isCover &&
          other.checksum == this.checksum &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class CardImagesCompanion extends UpdateCompanion<CardImage> {
  final Value<String> id;
  final Value<String> cardItemId;
  final Value<CardImageKind> kind;
  final Value<String> relativePath;
  final Value<String?> derivedRelativePath;
  final Value<int> sortOrder;
  final Value<bool> isCover;
  final Value<String> checksum;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CardImagesCompanion({
    this.id = const Value.absent(),
    this.cardItemId = const Value.absent(),
    this.kind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.derivedRelativePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isCover = const Value.absent(),
    this.checksum = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardImagesCompanion.insert({
    required String id,
    required String cardItemId,
    required CardImageKind kind,
    required String relativePath,
    this.derivedRelativePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isCover = const Value.absent(),
    required String checksum,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       cardItemId = Value(cardItemId),
       kind = Value(kind),
       relativePath = Value(relativePath),
       checksum = Value(checksum),
       createdAt = Value(createdAt);
  static Insertable<CardImage> custom({
    Expression<String>? id,
    Expression<String>? cardItemId,
    Expression<String>? kind,
    Expression<String>? relativePath,
    Expression<String>? derivedRelativePath,
    Expression<int>? sortOrder,
    Expression<bool>? isCover,
    Expression<String>? checksum,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardItemId != null) 'card_item_id': cardItemId,
      if (kind != null) 'kind': kind,
      if (relativePath != null) 'relative_path': relativePath,
      if (derivedRelativePath != null)
        'derived_relative_path': derivedRelativePath,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isCover != null) 'is_cover': isCover,
      if (checksum != null) 'checksum': checksum,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardImagesCompanion copyWith({
    Value<String>? id,
    Value<String>? cardItemId,
    Value<CardImageKind>? kind,
    Value<String>? relativePath,
    Value<String?>? derivedRelativePath,
    Value<int>? sortOrder,
    Value<bool>? isCover,
    Value<String>? checksum,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CardImagesCompanion(
      id: id ?? this.id,
      cardItemId: cardItemId ?? this.cardItemId,
      kind: kind ?? this.kind,
      relativePath: relativePath ?? this.relativePath,
      derivedRelativePath: derivedRelativePath ?? this.derivedRelativePath,
      sortOrder: sortOrder ?? this.sortOrder,
      isCover: isCover ?? this.isCover,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardItemId.present) {
      map['card_item_id'] = Variable<String>(cardItemId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CardImagesTable.$converterkind.toSql(kind.value),
      );
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (derivedRelativePath.present) {
      map['derived_relative_path'] = Variable<String>(
        derivedRelativePath.value,
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isCover.present) {
      map['is_cover'] = Variable<bool>(isCover.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardImagesCompanion(')
          ..write('id: $id, ')
          ..write('cardItemId: $cardItemId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('derivedRelativePath: $derivedRelativePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isCover: $isCover, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardSetsTable extends CardSets with TableInfo<$CardSetsTable, CardSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedCountMeta = const VerificationMeta(
    'expectedCount',
  );
  @override
  late final GeneratedColumn<int> expectedCount = GeneratedColumn<int>(
    'expected_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countKnownMeta = const VerificationMeta(
    'countKnown',
  );
  @override
  late final GeneratedColumn<bool> countKnown = GeneratedColumn<bool>(
    'count_known',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("count_known" IN (0, 1))',
    ),
  );
  static const VerificationMeta _issueInfoMeta = const VerificationMeta(
    'issueInfo',
  );
  @override
  late final GeneratedColumn<String> issueInfo = GeneratedColumn<String>(
    'issue_info',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverImageIdMeta = const VerificationMeta(
    'coverImageId',
  );
  @override
  late final GeneratedColumn<String> coverImageId = GeneratedColumn<String>(
    'cover_image_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_images (id)',
    ),
  );
  static const VerificationMeta _coverRelativePathMeta = const VerificationMeta(
    'coverRelativePath',
  );
  @override
  late final GeneratedColumn<String> coverRelativePath =
      GeneratedColumn<String>(
        'cover_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    expectedCount,
    countKnown,
    issueInfo,
    notes,
    coverImageId,
    coverRelativePath,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('expected_count')) {
      context.handle(
        _expectedCountMeta,
        expectedCount.isAcceptableOrUnknown(
          data['expected_count']!,
          _expectedCountMeta,
        ),
      );
    }
    if (data.containsKey('count_known')) {
      context.handle(
        _countKnownMeta,
        countKnown.isAcceptableOrUnknown(data['count_known']!, _countKnownMeta),
      );
    } else if (isInserting) {
      context.missing(_countKnownMeta);
    }
    if (data.containsKey('issue_info')) {
      context.handle(
        _issueInfoMeta,
        issueInfo.isAcceptableOrUnknown(data['issue_info']!, _issueInfoMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('cover_image_id')) {
      context.handle(
        _coverImageIdMeta,
        coverImageId.isAcceptableOrUnknown(
          data['cover_image_id']!,
          _coverImageIdMeta,
        ),
      );
    }
    if (data.containsKey('cover_relative_path')) {
      context.handle(
        _coverRelativePathMeta,
        coverRelativePath.isAcceptableOrUnknown(
          data['cover_relative_path']!,
          _coverRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      expectedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_count'],
      ),
      countKnown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}count_known'],
      )!,
      issueInfo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}issue_info'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      coverImageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_id'],
      ),
      coverRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_relative_path'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CardSetsTable createAlias(String alias) {
    return $CardSetsTable(attachedDatabase, alias);
  }
}

class CardSet extends DataClass implements Insertable<CardSet> {
  final String id;
  final String name;
  final int? expectedCount;
  final bool countKnown;
  final String? issueInfo;
  final String? notes;
  final String? coverImageId;
  final String? coverRelativePath;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CardSet({
    required this.id,
    required this.name,
    this.expectedCount,
    required this.countKnown,
    this.issueInfo,
    this.notes,
    this.coverImageId,
    this.coverRelativePath,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || expectedCount != null) {
      map['expected_count'] = Variable<int>(expectedCount);
    }
    map['count_known'] = Variable<bool>(countKnown);
    if (!nullToAbsent || issueInfo != null) {
      map['issue_info'] = Variable<String>(issueInfo);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || coverImageId != null) {
      map['cover_image_id'] = Variable<String>(coverImageId);
    }
    if (!nullToAbsent || coverRelativePath != null) {
      map['cover_relative_path'] = Variable<String>(coverRelativePath);
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CardSetsCompanion toCompanion(bool nullToAbsent) {
    return CardSetsCompanion(
      id: Value(id),
      name: Value(name),
      expectedCount: expectedCount == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedCount),
      countKnown: Value(countKnown),
      issueInfo: issueInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(issueInfo),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      coverImageId: coverImageId == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImageId),
      coverRelativePath: coverRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverRelativePath),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CardSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardSet(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      expectedCount: serializer.fromJson<int?>(json['expectedCount']),
      countKnown: serializer.fromJson<bool>(json['countKnown']),
      issueInfo: serializer.fromJson<String?>(json['issueInfo']),
      notes: serializer.fromJson<String?>(json['notes']),
      coverImageId: serializer.fromJson<String?>(json['coverImageId']),
      coverRelativePath: serializer.fromJson<String?>(
        json['coverRelativePath'],
      ),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'expectedCount': serializer.toJson<int?>(expectedCount),
      'countKnown': serializer.toJson<bool>(countKnown),
      'issueInfo': serializer.toJson<String?>(issueInfo),
      'notes': serializer.toJson<String?>(notes),
      'coverImageId': serializer.toJson<String?>(coverImageId),
      'coverRelativePath': serializer.toJson<String?>(coverRelativePath),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CardSet copyWith({
    String? id,
    String? name,
    Value<int?> expectedCount = const Value.absent(),
    bool? countKnown,
    Value<String?> issueInfo = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> coverImageId = const Value.absent(),
    Value<String?> coverRelativePath = const Value.absent(),
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CardSet(
    id: id ?? this.id,
    name: name ?? this.name,
    expectedCount: expectedCount.present
        ? expectedCount.value
        : this.expectedCount,
    countKnown: countKnown ?? this.countKnown,
    issueInfo: issueInfo.present ? issueInfo.value : this.issueInfo,
    notes: notes.present ? notes.value : this.notes,
    coverImageId: coverImageId.present ? coverImageId.value : this.coverImageId,
    coverRelativePath: coverRelativePath.present
        ? coverRelativePath.value
        : this.coverRelativePath,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CardSet copyWithCompanion(CardSetsCompanion data) {
    return CardSet(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      expectedCount: data.expectedCount.present
          ? data.expectedCount.value
          : this.expectedCount,
      countKnown: data.countKnown.present
          ? data.countKnown.value
          : this.countKnown,
      issueInfo: data.issueInfo.present ? data.issueInfo.value : this.issueInfo,
      notes: data.notes.present ? data.notes.value : this.notes,
      coverImageId: data.coverImageId.present
          ? data.coverImageId.value
          : this.coverImageId,
      coverRelativePath: data.coverRelativePath.present
          ? data.coverRelativePath.value
          : this.coverRelativePath,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardSet(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('expectedCount: $expectedCount, ')
          ..write('countKnown: $countKnown, ')
          ..write('issueInfo: $issueInfo, ')
          ..write('notes: $notes, ')
          ..write('coverImageId: $coverImageId, ')
          ..write('coverRelativePath: $coverRelativePath, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    expectedCount,
    countKnown,
    issueInfo,
    notes,
    coverImageId,
    coverRelativePath,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardSet &&
          other.id == this.id &&
          other.name == this.name &&
          other.expectedCount == this.expectedCount &&
          other.countKnown == this.countKnown &&
          other.issueInfo == this.issueInfo &&
          other.notes == this.notes &&
          other.coverImageId == this.coverImageId &&
          other.coverRelativePath == this.coverRelativePath &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CardSetsCompanion extends UpdateCompanion<CardSet> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> expectedCount;
  final Value<bool> countKnown;
  final Value<String?> issueInfo;
  final Value<String?> notes;
  final Value<String?> coverImageId;
  final Value<String?> coverRelativePath;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CardSetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.expectedCount = const Value.absent(),
    this.countKnown = const Value.absent(),
    this.issueInfo = const Value.absent(),
    this.notes = const Value.absent(),
    this.coverImageId = const Value.absent(),
    this.coverRelativePath = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardSetsCompanion.insert({
    required String id,
    required String name,
    this.expectedCount = const Value.absent(),
    required bool countKnown,
    this.issueInfo = const Value.absent(),
    this.notes = const Value.absent(),
    this.coverImageId = const Value.absent(),
    this.coverRelativePath = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       countKnown = Value(countKnown),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CardSet> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? expectedCount,
    Expression<bool>? countKnown,
    Expression<String>? issueInfo,
    Expression<String>? notes,
    Expression<String>? coverImageId,
    Expression<String>? coverRelativePath,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (expectedCount != null) 'expected_count': expectedCount,
      if (countKnown != null) 'count_known': countKnown,
      if (issueInfo != null) 'issue_info': issueInfo,
      if (notes != null) 'notes': notes,
      if (coverImageId != null) 'cover_image_id': coverImageId,
      if (coverRelativePath != null) 'cover_relative_path': coverRelativePath,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardSetsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? expectedCount,
    Value<bool>? countKnown,
    Value<String?>? issueInfo,
    Value<String?>? notes,
    Value<String?>? coverImageId,
    Value<String?>? coverRelativePath,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CardSetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      expectedCount: expectedCount ?? this.expectedCount,
      countKnown: countKnown ?? this.countKnown,
      issueInfo: issueInfo ?? this.issueInfo,
      notes: notes ?? this.notes,
      coverImageId: coverImageId ?? this.coverImageId,
      coverRelativePath: coverRelativePath ?? this.coverRelativePath,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (expectedCount.present) {
      map['expected_count'] = Variable<int>(expectedCount.value);
    }
    if (countKnown.present) {
      map['count_known'] = Variable<bool>(countKnown.value);
    }
    if (issueInfo.present) {
      map['issue_info'] = Variable<String>(issueInfo.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (coverImageId.present) {
      map['cover_image_id'] = Variable<String>(coverImageId.value);
    }
    if (coverRelativePath.present) {
      map['cover_relative_path'] = Variable<String>(coverRelativePath.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardSetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('expectedCount: $expectedCount, ')
          ..write('countKnown: $countKnown, ')
          ..write('issueInfo: $issueInfo, ')
          ..write('notes: $notes, ')
          ..write('coverImageId: $coverImageId, ')
          ..write('coverRelativePath: $coverRelativePath, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardSetMembersTable extends CardSetMembers
    with TableInfo<$CardSetMembersTable, CardSetMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardSetMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_sets (id)',
    ),
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_definitions (id)',
    ),
  );
  static const VerificationMeta _memberNoMeta = const VerificationMeta(
    'memberNo',
  );
  @override
  late final GeneratedColumn<String> memberNo = GeneratedColumn<String>(
    'member_no',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requiredMeta = const VerificationMeta(
    'required',
  );
  @override
  late final GeneratedColumn<bool> required = GeneratedColumn<bool>(
    'required',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("required" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    setId,
    definitionId,
    memberNo,
    required,
    sortOrder,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_set_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardSetMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('member_no')) {
      context.handle(
        _memberNoMeta,
        memberNo.isAcceptableOrUnknown(data['member_no']!, _memberNoMeta),
      );
    }
    if (data.containsKey('required')) {
      context.handle(
        _requiredMeta,
        required.isAcceptableOrUnknown(data['required']!, _requiredMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardSetMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardSetMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      memberNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_no'],
      ),
      required: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}required'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $CardSetMembersTable createAlias(String alias) {
    return $CardSetMembersTable(attachedDatabase, alias);
  }
}

class CardSetMember extends DataClass implements Insertable<CardSetMember> {
  final String id;
  final String setId;
  final String definitionId;
  final String? memberNo;
  final bool required;
  final int sortOrder;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CardSetMember({
    required this.id,
    required this.setId,
    required this.definitionId,
    this.memberNo,
    required this.required,
    required this.sortOrder,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['set_id'] = Variable<String>(setId);
    map['definition_id'] = Variable<String>(definitionId);
    if (!nullToAbsent || memberNo != null) {
      map['member_no'] = Variable<String>(memberNo);
    }
    map['required'] = Variable<bool>(required);
    map['sort_order'] = Variable<int>(sortOrder);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  CardSetMembersCompanion toCompanion(bool nullToAbsent) {
    return CardSetMembersCompanion(
      id: Value(id),
      setId: Value(setId),
      definitionId: Value(definitionId),
      memberNo: memberNo == null && nullToAbsent
          ? const Value.absent()
          : Value(memberNo),
      required: Value(required),
      sortOrder: Value(sortOrder),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CardSetMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardSetMember(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String>(json['setId']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      memberNo: serializer.fromJson<String?>(json['memberNo']),
      required: serializer.fromJson<bool>(json['required']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String>(setId),
      'definitionId': serializer.toJson<String>(definitionId),
      'memberNo': serializer.toJson<String?>(memberNo),
      'required': serializer.toJson<bool>(required),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CardSetMember copyWith({
    String? id,
    String? setId,
    String? definitionId,
    Value<String?> memberNo = const Value.absent(),
    bool? required,
    int? sortOrder,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CardSetMember(
    id: id ?? this.id,
    setId: setId ?? this.setId,
    definitionId: definitionId ?? this.definitionId,
    memberNo: memberNo.present ? memberNo.value : this.memberNo,
    required: required ?? this.required,
    sortOrder: sortOrder ?? this.sortOrder,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CardSetMember copyWithCompanion(CardSetMembersCompanion data) {
    return CardSetMember(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      memberNo: data.memberNo.present ? data.memberNo.value : this.memberNo,
      required: data.required.present ? data.required.value : this.required,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardSetMember(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('definitionId: $definitionId, ')
          ..write('memberNo: $memberNo, ')
          ..write('required: $required, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    setId,
    definitionId,
    memberNo,
    required,
    sortOrder,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardSetMember &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.definitionId == this.definitionId &&
          other.memberNo == this.memberNo &&
          other.required == this.required &&
          other.sortOrder == this.sortOrder &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CardSetMembersCompanion extends UpdateCompanion<CardSetMember> {
  final Value<String> id;
  final Value<String> setId;
  final Value<String> definitionId;
  final Value<String?> memberNo;
  final Value<bool> required;
  final Value<int> sortOrder;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CardSetMembersCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.memberNo = const Value.absent(),
    this.required = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardSetMembersCompanion.insert({
    required String id,
    required String setId,
    required String definitionId,
    this.memberNo = const Value.absent(),
    this.required = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       setId = Value(setId),
       definitionId = Value(definitionId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CardSetMember> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<String>? definitionId,
    Expression<String>? memberNo,
    Expression<bool>? required,
    Expression<int>? sortOrder,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (definitionId != null) 'definition_id': definitionId,
      if (memberNo != null) 'member_no': memberNo,
      if (required != null) 'required': required,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardSetMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? setId,
    Value<String>? definitionId,
    Value<String?>? memberNo,
    Value<bool>? required,
    Value<int>? sortOrder,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CardSetMembersCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      definitionId: definitionId ?? this.definitionId,
      memberNo: memberNo ?? this.memberNo,
      required: required ?? this.required,
      sortOrder: sortOrder ?? this.sortOrder,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (memberNo.present) {
      map['member_no'] = Variable<String>(memberNo.value);
    }
    if (required.present) {
      map['required'] = Variable<bool>(required.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardSetMembersCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('definitionId: $definitionId, ')
          ..write('memberNo: $memberNo, ')
          ..write('required: $required, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  final String normalizedName;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Tag({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? normalizedName,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required String normalizedName,
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedName = Value(normalizedName),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTagsTable extends CardTags with TableInfo<$CardTagsTable, CardTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_definitions (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [tagId, definitionId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tagId, definitionId};
  @override
  CardTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTag(
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CardTagsTable createAlias(String alias) {
    return $CardTagsTable(attachedDatabase, alias);
  }
}

class CardTag extends DataClass implements Insertable<CardTag> {
  final String tagId;
  final String definitionId;
  final DateTime createdAt;
  const CardTag({
    required this.tagId,
    required this.definitionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tag_id'] = Variable<String>(tagId);
    map['definition_id'] = Variable<String>(definitionId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardTagsCompanion toCompanion(bool nullToAbsent) {
    return CardTagsCompanion(
      tagId: Value(tagId),
      definitionId: Value(definitionId),
      createdAt: Value(createdAt),
    );
  }

  factory CardTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTag(
      tagId: serializer.fromJson<String>(json['tagId']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tagId': serializer.toJson<String>(tagId),
      'definitionId': serializer.toJson<String>(definitionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardTag copyWith({
    String? tagId,
    String? definitionId,
    DateTime? createdAt,
  }) => CardTag(
    tagId: tagId ?? this.tagId,
    definitionId: definitionId ?? this.definitionId,
    createdAt: createdAt ?? this.createdAt,
  );
  CardTag copyWithCompanion(CardTagsCompanion data) {
    return CardTag(
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTag(')
          ..write('tagId: $tagId, ')
          ..write('definitionId: $definitionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(tagId, definitionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTag &&
          other.tagId == this.tagId &&
          other.definitionId == this.definitionId &&
          other.createdAt == this.createdAt);
}

class CardTagsCompanion extends UpdateCompanion<CardTag> {
  final Value<String> tagId;
  final Value<String> definitionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CardTagsCompanion({
    this.tagId = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTagsCompanion.insert({
    required String tagId,
    required String definitionId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : tagId = Value(tagId),
       definitionId = Value(definitionId),
       createdAt = Value(createdAt);
  static Insertable<CardTag> custom({
    Expression<String>? tagId,
    Expression<String>? definitionId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tagId != null) 'tag_id': tagId,
      if (definitionId != null) 'definition_id': definitionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTagsCompanion copyWith({
    Value<String>? tagId,
    Value<String>? definitionId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CardTagsCompanion(
      tagId: tagId ?? this.tagId,
      definitionId: definitionId ?? this.definitionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTagsCompanion(')
          ..write('tagId: $tagId, ')
          ..write('definitionId: $definitionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesRecordsTable extends SeriesRecords
    with TableInfo<$SeriesRecordsTable, SeriesRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverRelativePathMeta = const VerificationMeta(
    'coverRelativePath',
  );
  @override
  late final GeneratedColumn<String> coverRelativePath =
      GeneratedColumn<String>(
        'cover_relative_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    coverRelativePath,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_relative_path')) {
      context.handle(
        _coverRelativePathMeta,
        coverRelativePath.isAcceptableOrUnknown(
          data['cover_relative_path']!,
          _coverRelativePathMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SeriesRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_relative_path'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SeriesRecordsTable createAlias(String alias) {
    return $SeriesRecordsTable(attachedDatabase, alias);
  }
}

class SeriesRecord extends DataClass implements Insertable<SeriesRecord> {
  final String id;
  final String name;
  final String? description;
  final String? coverRelativePath;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const SeriesRecord({
    required this.id,
    required this.name,
    this.description,
    this.coverRelativePath,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverRelativePath != null) {
      map['cover_relative_path'] = Variable<String>(coverRelativePath);
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SeriesRecordsCompanion toCompanion(bool nullToAbsent) {
    return SeriesRecordsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverRelativePath: coverRelativePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverRelativePath),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SeriesRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      coverRelativePath: serializer.fromJson<String?>(
        json['coverRelativePath'],
      ),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'coverRelativePath': serializer.toJson<String?>(coverRelativePath),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SeriesRecord copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> coverRelativePath = const Value.absent(),
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SeriesRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    coverRelativePath: coverRelativePath.present
        ? coverRelativePath.value
        : this.coverRelativePath,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SeriesRecord copyWithCompanion(SeriesRecordsCompanion data) {
    return SeriesRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverRelativePath: data.coverRelativePath.present
          ? data.coverRelativePath.value
          : this.coverRelativePath,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverRelativePath: $coverRelativePath, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    coverRelativePath,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverRelativePath == this.coverRelativePath &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class SeriesRecordsCompanion extends UpdateCompanion<SeriesRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> coverRelativePath;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SeriesRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverRelativePath = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesRecordsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.coverRelativePath = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SeriesRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverRelativePath,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverRelativePath != null) 'cover_relative_path': coverRelativePath,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? coverRelativePath,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SeriesRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverRelativePath: coverRelativePath ?? this.coverRelativePath,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverRelativePath.present) {
      map['cover_relative_path'] = Variable<String>(coverRelativePath.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverRelativePath: $coverRelativePath, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesCardsTable extends SeriesCards
    with TableInfo<$SeriesCardsTable, SeriesCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES series_records (id)',
    ),
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_definitions (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seriesId, definitionId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, definitionId};
  @override
  SeriesCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesCard(
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SeriesCardsTable createAlias(String alias) {
    return $SeriesCardsTable(attachedDatabase, alias);
  }
}

class SeriesCard extends DataClass implements Insertable<SeriesCard> {
  final String seriesId;
  final String definitionId;
  final DateTime createdAt;
  const SeriesCard({
    required this.seriesId,
    required this.definitionId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<String>(seriesId);
    map['definition_id'] = Variable<String>(definitionId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SeriesCardsCompanion toCompanion(bool nullToAbsent) {
    return SeriesCardsCompanion(
      seriesId: Value(seriesId),
      definitionId: Value(definitionId),
      createdAt: Value(createdAt),
    );
  }

  factory SeriesCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesCard(
      seriesId: serializer.fromJson<String>(json['seriesId']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<String>(seriesId),
      'definitionId': serializer.toJson<String>(definitionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SeriesCard copyWith({
    String? seriesId,
    String? definitionId,
    DateTime? createdAt,
  }) => SeriesCard(
    seriesId: seriesId ?? this.seriesId,
    definitionId: definitionId ?? this.definitionId,
    createdAt: createdAt ?? this.createdAt,
  );
  SeriesCard copyWithCompanion(SeriesCardsCompanion data) {
    return SeriesCard(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCard(')
          ..write('seriesId: $seriesId, ')
          ..write('definitionId: $definitionId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, definitionId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesCard &&
          other.seriesId == this.seriesId &&
          other.definitionId == this.definitionId &&
          other.createdAt == this.createdAt);
}

class SeriesCardsCompanion extends UpdateCompanion<SeriesCard> {
  final Value<String> seriesId;
  final Value<String> definitionId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SeriesCardsCompanion({
    this.seriesId = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesCardsCompanion.insert({
    required String seriesId,
    required String definitionId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : seriesId = Value(seriesId),
       definitionId = Value(definitionId),
       createdAt = Value(createdAt);
  static Insertable<SeriesCard> custom({
    Expression<String>? seriesId,
    Expression<String>? definitionId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (definitionId != null) 'definition_id': definitionId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesCardsCompanion copyWith({
    Value<String>? seriesId,
    Value<String>? definitionId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SeriesCardsCompanion(
      seriesId: seriesId ?? this.seriesId,
      definitionId: definitionId ?? this.definitionId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesCardsCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('definitionId: $definitionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeriesSetsTable extends SeriesSets
    with TableInfo<$SeriesSetsTable, SeriesSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<String> seriesId = GeneratedColumn<String>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES series_records (id)',
    ),
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_sets (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [seriesId, setId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seriesId, setId};
  @override
  SeriesSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesSet(
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series_id'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SeriesSetsTable createAlias(String alias) {
    return $SeriesSetsTable(attachedDatabase, alias);
  }
}

class SeriesSet extends DataClass implements Insertable<SeriesSet> {
  final String seriesId;
  final String setId;
  final DateTime createdAt;
  const SeriesSet({
    required this.seriesId,
    required this.setId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['series_id'] = Variable<String>(seriesId);
    map['set_id'] = Variable<String>(setId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SeriesSetsCompanion toCompanion(bool nullToAbsent) {
    return SeriesSetsCompanion(
      seriesId: Value(seriesId),
      setId: Value(setId),
      createdAt: Value(createdAt),
    );
  }

  factory SeriesSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesSet(
      seriesId: serializer.fromJson<String>(json['seriesId']),
      setId: serializer.fromJson<String>(json['setId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seriesId': serializer.toJson<String>(seriesId),
      'setId': serializer.toJson<String>(setId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SeriesSet copyWith({String? seriesId, String? setId, DateTime? createdAt}) =>
      SeriesSet(
        seriesId: seriesId ?? this.seriesId,
        setId: setId ?? this.setId,
        createdAt: createdAt ?? this.createdAt,
      );
  SeriesSet copyWithCompanion(SeriesSetsCompanion data) {
    return SeriesSet(
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      setId: data.setId.present ? data.setId.value : this.setId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesSet(')
          ..write('seriesId: $seriesId, ')
          ..write('setId: $setId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(seriesId, setId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesSet &&
          other.seriesId == this.seriesId &&
          other.setId == this.setId &&
          other.createdAt == this.createdAt);
}

class SeriesSetsCompanion extends UpdateCompanion<SeriesSet> {
  final Value<String> seriesId;
  final Value<String> setId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SeriesSetsCompanion({
    this.seriesId = const Value.absent(),
    this.setId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeriesSetsCompanion.insert({
    required String seriesId,
    required String setId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : seriesId = Value(seriesId),
       setId = Value(setId),
       createdAt = Value(createdAt);
  static Insertable<SeriesSet> custom({
    Expression<String>? seriesId,
    Expression<String>? setId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (seriesId != null) 'series_id': seriesId,
      if (setId != null) 'set_id': setId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeriesSetsCompanion copyWith({
    Value<String>? seriesId,
    Value<String>? setId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SeriesSetsCompanion(
      seriesId: seriesId ?? this.seriesId,
      setId: setId ?? this.setId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seriesId.present) {
      map['series_id'] = Variable<String>(seriesId.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesSetsCompanion(')
          ..write('seriesId: $seriesId, ')
          ..write('setId: $setId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrganizationFieldDefinitionsTable extends OrganizationFieldDefinitions
    with
        TableInfo<
          $OrganizationFieldDefinitionsTable,
          OrganizationFieldDefinition
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationFieldDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CustomFieldType, String>
  fieldType =
      GeneratedColumn<String>(
        'field_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CustomFieldType>(
        $OrganizationFieldDefinitionsTable.$converterfieldType,
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    fieldType,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrganizationFieldDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrganizationFieldDefinition map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrganizationFieldDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      fieldType: $OrganizationFieldDefinitionsTable.$converterfieldType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}field_type'],
        )!,
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $OrganizationFieldDefinitionsTable createAlias(String alias) {
    return $OrganizationFieldDefinitionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CustomFieldType, String, String>
  $converterfieldType = const EnumNameConverter<CustomFieldType>(
    CustomFieldType.values,
  );
}

class OrganizationFieldDefinition extends DataClass
    implements Insertable<OrganizationFieldDefinition> {
  final String id;
  final String name;
  final String normalizedName;
  final CustomFieldType fieldType;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const OrganizationFieldDefinition({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.fieldType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    {
      map['field_type'] = Variable<String>(
        $OrganizationFieldDefinitionsTable.$converterfieldType.toSql(fieldType),
      );
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  OrganizationFieldDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return OrganizationFieldDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      fieldType: Value(fieldType),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory OrganizationFieldDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrganizationFieldDefinition(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      fieldType: $OrganizationFieldDefinitionsTable.$converterfieldType
          .fromJson(serializer.fromJson<String>(json['fieldType'])),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'fieldType': serializer.toJson<String>(
        $OrganizationFieldDefinitionsTable.$converterfieldType.toJson(
          fieldType,
        ),
      ),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  OrganizationFieldDefinition copyWith({
    String? id,
    String? name,
    String? normalizedName,
    CustomFieldType? fieldType,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => OrganizationFieldDefinition(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    fieldType: fieldType ?? this.fieldType,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  OrganizationFieldDefinition copyWithCompanion(
    OrganizationFieldDefinitionsCompanion data,
  ) {
    return OrganizationFieldDefinition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationFieldDefinition(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('fieldType: $fieldType, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    fieldType,
    version,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrganizationFieldDefinition &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.fieldType == this.fieldType &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class OrganizationFieldDefinitionsCompanion
    extends UpdateCompanion<OrganizationFieldDefinition> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<CustomFieldType> fieldType;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const OrganizationFieldDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrganizationFieldDefinitionsCompanion.insert({
    required String id,
    required String name,
    required String normalizedName,
    required CustomFieldType fieldType,
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedName = Value(normalizedName),
       fieldType = Value(fieldType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<OrganizationFieldDefinition> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? fieldType,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (fieldType != null) 'field_type': fieldType,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrganizationFieldDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<CustomFieldType>? fieldType,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return OrganizationFieldDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      fieldType: fieldType ?? this.fieldType,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(
        $OrganizationFieldDefinitionsTable.$converterfieldType.toSql(
          fieldType.value,
        ),
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationFieldDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('fieldType: $fieldType, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OrganizationFieldValuesTable extends OrganizationFieldValues
    with TableInfo<$OrganizationFieldValuesTable, OrganizationFieldValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrganizationFieldValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fieldIdMeta = const VerificationMeta(
    'fieldId',
  );
  @override
  late final GeneratedColumn<String> fieldId = GeneratedColumn<String>(
    'field_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_field_definitions (id)',
    ),
  );
  static const VerificationMeta _definitionIdMeta = const VerificationMeta(
    'definitionId',
  );
  @override
  late final GeneratedColumn<String> definitionId = GeneratedColumn<String>(
    'definition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES card_definitions (id)',
    ),
  );
  static const VerificationMeta _textValueMeta = const VerificationMeta(
    'textValue',
  );
  @override
  late final GeneratedColumn<String> textValue = GeneratedColumn<String>(
    'text_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numberValueMeta = const VerificationMeta(
    'numberValue',
  );
  @override
  late final GeneratedColumn<double> numberValue = GeneratedColumn<double>(
    'number_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateValueMeta = const VerificationMeta(
    'dateValue',
  );
  @override
  late final GeneratedColumn<DateTime> dateValue = GeneratedColumn<DateTime>(
    'date_value',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    fieldId,
    definitionId,
    textValue,
    numberValue,
    dateValue,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_field_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<OrganizationFieldValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('field_id')) {
      context.handle(
        _fieldIdMeta,
        fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('definition_id')) {
      context.handle(
        _definitionIdMeta,
        definitionId.isAcceptableOrUnknown(
          data['definition_id']!,
          _definitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_definitionIdMeta);
    }
    if (data.containsKey('text_value')) {
      context.handle(
        _textValueMeta,
        textValue.isAcceptableOrUnknown(data['text_value']!, _textValueMeta),
      );
    }
    if (data.containsKey('number_value')) {
      context.handle(
        _numberValueMeta,
        numberValue.isAcceptableOrUnknown(
          data['number_value']!,
          _numberValueMeta,
        ),
      );
    }
    if (data.containsKey('date_value')) {
      context.handle(
        _dateValueMeta,
        dateValue.isAcceptableOrUnknown(data['date_value']!, _dateValueMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fieldId, definitionId};
  @override
  OrganizationFieldValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrganizationFieldValue(
      fieldId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_id'],
      )!,
      definitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}definition_id'],
      )!,
      textValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_value'],
      ),
      numberValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}number_value'],
      ),
      dateValue: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_value'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $OrganizationFieldValuesTable createAlias(String alias) {
    return $OrganizationFieldValuesTable(attachedDatabase, alias);
  }
}

class OrganizationFieldValue extends DataClass
    implements Insertable<OrganizationFieldValue> {
  final String fieldId;
  final String definitionId;
  final String? textValue;
  final double? numberValue;
  final DateTime? dateValue;
  final DateTime updatedAt;
  const OrganizationFieldValue({
    required this.fieldId,
    required this.definitionId,
    this.textValue,
    this.numberValue,
    this.dateValue,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['field_id'] = Variable<String>(fieldId);
    map['definition_id'] = Variable<String>(definitionId);
    if (!nullToAbsent || textValue != null) {
      map['text_value'] = Variable<String>(textValue);
    }
    if (!nullToAbsent || numberValue != null) {
      map['number_value'] = Variable<double>(numberValue);
    }
    if (!nullToAbsent || dateValue != null) {
      map['date_value'] = Variable<DateTime>(dateValue);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrganizationFieldValuesCompanion toCompanion(bool nullToAbsent) {
    return OrganizationFieldValuesCompanion(
      fieldId: Value(fieldId),
      definitionId: Value(definitionId),
      textValue: textValue == null && nullToAbsent
          ? const Value.absent()
          : Value(textValue),
      numberValue: numberValue == null && nullToAbsent
          ? const Value.absent()
          : Value(numberValue),
      dateValue: dateValue == null && nullToAbsent
          ? const Value.absent()
          : Value(dateValue),
      updatedAt: Value(updatedAt),
    );
  }

  factory OrganizationFieldValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrganizationFieldValue(
      fieldId: serializer.fromJson<String>(json['fieldId']),
      definitionId: serializer.fromJson<String>(json['definitionId']),
      textValue: serializer.fromJson<String?>(json['textValue']),
      numberValue: serializer.fromJson<double?>(json['numberValue']),
      dateValue: serializer.fromJson<DateTime?>(json['dateValue']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fieldId': serializer.toJson<String>(fieldId),
      'definitionId': serializer.toJson<String>(definitionId),
      'textValue': serializer.toJson<String?>(textValue),
      'numberValue': serializer.toJson<double?>(numberValue),
      'dateValue': serializer.toJson<DateTime?>(dateValue),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  OrganizationFieldValue copyWith({
    String? fieldId,
    String? definitionId,
    Value<String?> textValue = const Value.absent(),
    Value<double?> numberValue = const Value.absent(),
    Value<DateTime?> dateValue = const Value.absent(),
    DateTime? updatedAt,
  }) => OrganizationFieldValue(
    fieldId: fieldId ?? this.fieldId,
    definitionId: definitionId ?? this.definitionId,
    textValue: textValue.present ? textValue.value : this.textValue,
    numberValue: numberValue.present ? numberValue.value : this.numberValue,
    dateValue: dateValue.present ? dateValue.value : this.dateValue,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  OrganizationFieldValue copyWithCompanion(
    OrganizationFieldValuesCompanion data,
  ) {
    return OrganizationFieldValue(
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      definitionId: data.definitionId.present
          ? data.definitionId.value
          : this.definitionId,
      textValue: data.textValue.present ? data.textValue.value : this.textValue,
      numberValue: data.numberValue.present
          ? data.numberValue.value
          : this.numberValue,
      dateValue: data.dateValue.present ? data.dateValue.value : this.dateValue,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationFieldValue(')
          ..write('fieldId: $fieldId, ')
          ..write('definitionId: $definitionId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('dateValue: $dateValue, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    fieldId,
    definitionId,
    textValue,
    numberValue,
    dateValue,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrganizationFieldValue &&
          other.fieldId == this.fieldId &&
          other.definitionId == this.definitionId &&
          other.textValue == this.textValue &&
          other.numberValue == this.numberValue &&
          other.dateValue == this.dateValue &&
          other.updatedAt == this.updatedAt);
}

class OrganizationFieldValuesCompanion
    extends UpdateCompanion<OrganizationFieldValue> {
  final Value<String> fieldId;
  final Value<String> definitionId;
  final Value<String?> textValue;
  final Value<double?> numberValue;
  final Value<DateTime?> dateValue;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const OrganizationFieldValuesCompanion({
    this.fieldId = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.dateValue = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrganizationFieldValuesCompanion.insert({
    required String fieldId,
    required String definitionId,
    this.textValue = const Value.absent(),
    this.numberValue = const Value.absent(),
    this.dateValue = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : fieldId = Value(fieldId),
       definitionId = Value(definitionId),
       updatedAt = Value(updatedAt);
  static Insertable<OrganizationFieldValue> custom({
    Expression<String>? fieldId,
    Expression<String>? definitionId,
    Expression<String>? textValue,
    Expression<double>? numberValue,
    Expression<DateTime>? dateValue,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fieldId != null) 'field_id': fieldId,
      if (definitionId != null) 'definition_id': definitionId,
      if (textValue != null) 'text_value': textValue,
      if (numberValue != null) 'number_value': numberValue,
      if (dateValue != null) 'date_value': dateValue,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrganizationFieldValuesCompanion copyWith({
    Value<String>? fieldId,
    Value<String>? definitionId,
    Value<String?>? textValue,
    Value<double?>? numberValue,
    Value<DateTime?>? dateValue,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return OrganizationFieldValuesCompanion(
      fieldId: fieldId ?? this.fieldId,
      definitionId: definitionId ?? this.definitionId,
      textValue: textValue ?? this.textValue,
      numberValue: numberValue ?? this.numberValue,
      dateValue: dateValue ?? this.dateValue,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fieldId.present) {
      map['field_id'] = Variable<String>(fieldId.value);
    }
    if (definitionId.present) {
      map['definition_id'] = Variable<String>(definitionId.value);
    }
    if (textValue.present) {
      map['text_value'] = Variable<String>(textValue.value);
    }
    if (numberValue.present) {
      map['number_value'] = Variable<double>(numberValue.value);
    }
    if (dateValue.present) {
      map['date_value'] = Variable<DateTime>(dateValue.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrganizationFieldValuesCompanion(')
          ..write('fieldId: $fieldId, ')
          ..write('definitionId: $definitionId, ')
          ..write('textValue: $textValue, ')
          ..write('numberValue: $numberValue, ')
          ..write('dateValue: $dateValue, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasedAtMeta = const VerificationMeta(
    'purchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purchasedAt = GeneratedColumn<DateTime>(
    'purchased_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shippingMinorMeta = const VerificationMeta(
    'shippingMinor',
  );
  @override
  late final GeneratedColumn<int> shippingMinor = GeneratedColumn<int>(
    'shipping_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _feesMinorMeta = const VerificationMeta(
    'feesMinor',
  );
  @override
  late final GeneratedColumn<int> feesMinor = GeneratedColumn<int>(
    'fees_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellerMeta = const VerificationMeta('seller');
  @override
  late final GeneratedColumn<String> seller = GeneratedColumn<String>(
    'seller',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adjustmentOfIdMeta = const VerificationMeta(
    'adjustmentOfId',
  );
  @override
  late final GeneratedColumn<String> adjustmentOfId = GeneratedColumn<String>(
    'adjustment_of_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases (id)',
    ),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    check: () => ComparableExpr(version).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchasedAt,
    amountMinor,
    currency,
    shippingMinor,
    feesMinor,
    channel,
    seller,
    notes,
    adjustmentOfId,
    version,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Purchase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchased_at')) {
      context.handle(
        _purchasedAtMeta,
        purchasedAt.isAcceptableOrUnknown(
          data['purchased_at']!,
          _purchasedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasedAtMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('shipping_minor')) {
      context.handle(
        _shippingMinorMeta,
        shippingMinor.isAcceptableOrUnknown(
          data['shipping_minor']!,
          _shippingMinorMeta,
        ),
      );
    }
    if (data.containsKey('fees_minor')) {
      context.handle(
        _feesMinorMeta,
        feesMinor.isAcceptableOrUnknown(data['fees_minor']!, _feesMinorMeta),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('seller')) {
      context.handle(
        _sellerMeta,
        seller.isAcceptableOrUnknown(data['seller']!, _sellerMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('adjustment_of_id')) {
      context.handle(
        _adjustmentOfIdMeta,
        adjustmentOfId.isAcceptableOrUnknown(
          data['adjustment_of_id']!,
          _adjustmentOfIdMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchased_at'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      shippingMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shipping_minor'],
      )!,
      feesMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fees_minor'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      ),
      seller: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seller'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      adjustmentOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment_of_id'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final String id;
  final DateTime purchasedAt;
  final int amountMinor;
  final String currency;
  final int shippingMinor;
  final int feesMinor;
  final String? channel;
  final String? seller;
  final String? notes;
  final String? adjustmentOfId;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Purchase({
    required this.id,
    required this.purchasedAt,
    required this.amountMinor,
    required this.currency,
    required this.shippingMinor,
    required this.feesMinor,
    this.channel,
    this.seller,
    this.notes,
    this.adjustmentOfId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchased_at'] = Variable<DateTime>(purchasedAt);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency'] = Variable<String>(currency);
    map['shipping_minor'] = Variable<int>(shippingMinor);
    map['fees_minor'] = Variable<int>(feesMinor);
    if (!nullToAbsent || channel != null) {
      map['channel'] = Variable<String>(channel);
    }
    if (!nullToAbsent || seller != null) {
      map['seller'] = Variable<String>(seller);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || adjustmentOfId != null) {
      map['adjustment_of_id'] = Variable<String>(adjustmentOfId);
    }
    map['version'] = Variable<int>(version);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      purchasedAt: Value(purchasedAt),
      amountMinor: Value(amountMinor),
      currency: Value(currency),
      shippingMinor: Value(shippingMinor),
      feesMinor: Value(feesMinor),
      channel: channel == null && nullToAbsent
          ? const Value.absent()
          : Value(channel),
      seller: seller == null && nullToAbsent
          ? const Value.absent()
          : Value(seller),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      adjustmentOfId: adjustmentOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustmentOfId),
      version: Value(version),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Purchase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<String>(json['id']),
      purchasedAt: serializer.fromJson<DateTime>(json['purchasedAt']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      shippingMinor: serializer.fromJson<int>(json['shippingMinor']),
      feesMinor: serializer.fromJson<int>(json['feesMinor']),
      channel: serializer.fromJson<String?>(json['channel']),
      seller: serializer.fromJson<String?>(json['seller']),
      notes: serializer.fromJson<String?>(json['notes']),
      adjustmentOfId: serializer.fromJson<String?>(json['adjustmentOfId']),
      version: serializer.fromJson<int>(json['version']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchasedAt': serializer.toJson<DateTime>(purchasedAt),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currency': serializer.toJson<String>(currency),
      'shippingMinor': serializer.toJson<int>(shippingMinor),
      'feesMinor': serializer.toJson<int>(feesMinor),
      'channel': serializer.toJson<String?>(channel),
      'seller': serializer.toJson<String?>(seller),
      'notes': serializer.toJson<String?>(notes),
      'adjustmentOfId': serializer.toJson<String?>(adjustmentOfId),
      'version': serializer.toJson<int>(version),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Purchase copyWith({
    String? id,
    DateTime? purchasedAt,
    int? amountMinor,
    String? currency,
    int? shippingMinor,
    int? feesMinor,
    Value<String?> channel = const Value.absent(),
    Value<String?> seller = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> adjustmentOfId = const Value.absent(),
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Purchase(
    id: id ?? this.id,
    purchasedAt: purchasedAt ?? this.purchasedAt,
    amountMinor: amountMinor ?? this.amountMinor,
    currency: currency ?? this.currency,
    shippingMinor: shippingMinor ?? this.shippingMinor,
    feesMinor: feesMinor ?? this.feesMinor,
    channel: channel.present ? channel.value : this.channel,
    seller: seller.present ? seller.value : this.seller,
    notes: notes.present ? notes.value : this.notes,
    adjustmentOfId: adjustmentOfId.present
        ? adjustmentOfId.value
        : this.adjustmentOfId,
    version: version ?? this.version,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      purchasedAt: data.purchasedAt.present
          ? data.purchasedAt.value
          : this.purchasedAt,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      shippingMinor: data.shippingMinor.present
          ? data.shippingMinor.value
          : this.shippingMinor,
      feesMinor: data.feesMinor.present ? data.feesMinor.value : this.feesMinor,
      channel: data.channel.present ? data.channel.value : this.channel,
      seller: data.seller.present ? data.seller.value : this.seller,
      notes: data.notes.present ? data.notes.value : this.notes,
      adjustmentOfId: data.adjustmentOfId.present
          ? data.adjustmentOfId.value
          : this.adjustmentOfId,
      version: data.version.present ? data.version.value : this.version,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('shippingMinor: $shippingMinor, ')
          ..write('feesMinor: $feesMinor, ')
          ..write('channel: $channel, ')
          ..write('seller: $seller, ')
          ..write('notes: $notes, ')
          ..write('adjustmentOfId: $adjustmentOfId, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchasedAt,
    amountMinor,
    currency,
    shippingMinor,
    feesMinor,
    channel,
    seller,
    notes,
    adjustmentOfId,
    version,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.purchasedAt == this.purchasedAt &&
          other.amountMinor == this.amountMinor &&
          other.currency == this.currency &&
          other.shippingMinor == this.shippingMinor &&
          other.feesMinor == this.feesMinor &&
          other.channel == this.channel &&
          other.seller == this.seller &&
          other.notes == this.notes &&
          other.adjustmentOfId == this.adjustmentOfId &&
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<String> id;
  final Value<DateTime> purchasedAt;
  final Value<int> amountMinor;
  final Value<String> currency;
  final Value<int> shippingMinor;
  final Value<int> feesMinor;
  final Value<String?> channel;
  final Value<String?> seller;
  final Value<String?> notes;
  final Value<String?> adjustmentOfId;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.shippingMinor = const Value.absent(),
    this.feesMinor = const Value.absent(),
    this.channel = const Value.absent(),
    this.seller = const Value.absent(),
    this.notes = const Value.absent(),
    this.adjustmentOfId = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String id,
    required DateTime purchasedAt,
    required int amountMinor,
    required String currency,
    this.shippingMinor = const Value.absent(),
    this.feesMinor = const Value.absent(),
    this.channel = const Value.absent(),
    this.seller = const Value.absent(),
    this.notes = const Value.absent(),
    this.adjustmentOfId = const Value.absent(),
    this.version = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       purchasedAt = Value(purchasedAt),
       amountMinor = Value(amountMinor),
       currency = Value(currency),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Purchase> custom({
    Expression<String>? id,
    Expression<DateTime>? purchasedAt,
    Expression<int>? amountMinor,
    Expression<String>? currency,
    Expression<int>? shippingMinor,
    Expression<int>? feesMinor,
    Expression<String>? channel,
    Expression<String>? seller,
    Expression<String>? notes,
    Expression<String>? adjustmentOfId,
    Expression<int>? version,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currency != null) 'currency': currency,
      if (shippingMinor != null) 'shipping_minor': shippingMinor,
      if (feesMinor != null) 'fees_minor': feesMinor,
      if (channel != null) 'channel': channel,
      if (seller != null) 'seller': seller,
      if (notes != null) 'notes': notes,
      if (adjustmentOfId != null) 'adjustment_of_id': adjustmentOfId,
      if (version != null) 'version': version,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? purchasedAt,
    Value<int>? amountMinor,
    Value<String>? currency,
    Value<int>? shippingMinor,
    Value<int>? feesMinor,
    Value<String?>? channel,
    Value<String?>? seller,
    Value<String?>? notes,
    Value<String?>? adjustmentOfId,
    Value<int>? version,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PurchasesCompanion(
      id: id ?? this.id,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      amountMinor: amountMinor ?? this.amountMinor,
      currency: currency ?? this.currency,
      shippingMinor: shippingMinor ?? this.shippingMinor,
      feesMinor: feesMinor ?? this.feesMinor,
      channel: channel ?? this.channel,
      seller: seller ?? this.seller,
      notes: notes ?? this.notes,
      adjustmentOfId: adjustmentOfId ?? this.adjustmentOfId,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchasedAt.present) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (shippingMinor.present) {
      map['shipping_minor'] = Variable<int>(shippingMinor.value);
    }
    if (feesMinor.present) {
      map['fees_minor'] = Variable<int>(feesMinor.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (seller.present) {
      map['seller'] = Variable<String>(seller.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (adjustmentOfId.present) {
      map['adjustment_of_id'] = Variable<String>(adjustmentOfId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currency: $currency, ')
          ..write('shippingMinor: $shippingMinor, ')
          ..write('feesMinor: $feesMinor, ')
          ..write('channel: $channel, ')
          ..write('seller: $seller, ')
          ..write('notes: $notes, ')
          ..write('adjustmentOfId: $adjustmentOfId, ')
          ..write('version: $version, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PurchaseItemsTable extends PurchaseItems
    with TableInfo<$PurchaseItemsTable, PurchaseItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _purchaseIdMeta = const VerificationMeta(
    'purchaseId',
  );
  @override
  late final GeneratedColumn<String> purchaseId = GeneratedColumn<String>(
    'purchase_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES purchases (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PurchaseTargetType, String>
  targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PurchaseTargetType>($PurchaseItemsTable.$convertertargetType);
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetNameMeta = const VerificationMeta(
    'targetName',
  );
  @override
  late final GeneratedColumn<String> targetName = GeneratedColumn<String>(
    'target_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allocatedMinorMeta = const VerificationMeta(
    'allocatedMinor',
  );
  @override
  late final GeneratedColumn<int> allocatedMinor = GeneratedColumn<int>(
    'allocated_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    purchaseId,
    targetType,
    targetId,
    targetName,
    allocatedMinor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('purchase_id')) {
      context.handle(
        _purchaseIdMeta,
        purchaseId.isAcceptableOrUnknown(data['purchase_id']!, _purchaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('target_name')) {
      context.handle(
        _targetNameMeta,
        targetName.isAcceptableOrUnknown(data['target_name']!, _targetNameMeta),
      );
    } else if (isInserting) {
      context.missing(_targetNameMeta);
    }
    if (data.containsKey('allocated_minor')) {
      context.handle(
        _allocatedMinorMeta,
        allocatedMinor.isAcceptableOrUnknown(
          data['allocated_minor']!,
          _allocatedMinorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {purchaseId, targetType, targetId};
  @override
  PurchaseItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseItem(
      purchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_id'],
      )!,
      targetType: $PurchaseItemsTable.$convertertargetType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}target_type'],
        )!,
      ),
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      targetName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_name'],
      )!,
      allocatedMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allocated_minor'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PurchaseItemsTable createAlias(String alias) {
    return $PurchaseItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PurchaseTargetType, String, String>
  $convertertargetType = const EnumNameConverter<PurchaseTargetType>(
    PurchaseTargetType.values,
  );
}

class PurchaseItem extends DataClass implements Insertable<PurchaseItem> {
  final String purchaseId;
  final PurchaseTargetType targetType;
  final String targetId;
  final String targetName;
  final int? allocatedMinor;
  final DateTime createdAt;
  const PurchaseItem({
    required this.purchaseId,
    required this.targetType,
    required this.targetId,
    required this.targetName,
    this.allocatedMinor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['purchase_id'] = Variable<String>(purchaseId);
    {
      map['target_type'] = Variable<String>(
        $PurchaseItemsTable.$convertertargetType.toSql(targetType),
      );
    }
    map['target_id'] = Variable<String>(targetId);
    map['target_name'] = Variable<String>(targetName);
    if (!nullToAbsent || allocatedMinor != null) {
      map['allocated_minor'] = Variable<int>(allocatedMinor);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PurchaseItemsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseItemsCompanion(
      purchaseId: Value(purchaseId),
      targetType: Value(targetType),
      targetId: Value(targetId),
      targetName: Value(targetName),
      allocatedMinor: allocatedMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(allocatedMinor),
      createdAt: Value(createdAt),
    );
  }

  factory PurchaseItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseItem(
      purchaseId: serializer.fromJson<String>(json['purchaseId']),
      targetType: $PurchaseItemsTable.$convertertargetType.fromJson(
        serializer.fromJson<String>(json['targetType']),
      ),
      targetId: serializer.fromJson<String>(json['targetId']),
      targetName: serializer.fromJson<String>(json['targetName']),
      allocatedMinor: serializer.fromJson<int?>(json['allocatedMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'purchaseId': serializer.toJson<String>(purchaseId),
      'targetType': serializer.toJson<String>(
        $PurchaseItemsTable.$convertertargetType.toJson(targetType),
      ),
      'targetId': serializer.toJson<String>(targetId),
      'targetName': serializer.toJson<String>(targetName),
      'allocatedMinor': serializer.toJson<int?>(allocatedMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PurchaseItem copyWith({
    String? purchaseId,
    PurchaseTargetType? targetType,
    String? targetId,
    String? targetName,
    Value<int?> allocatedMinor = const Value.absent(),
    DateTime? createdAt,
  }) => PurchaseItem(
    purchaseId: purchaseId ?? this.purchaseId,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    targetName: targetName ?? this.targetName,
    allocatedMinor: allocatedMinor.present
        ? allocatedMinor.value
        : this.allocatedMinor,
    createdAt: createdAt ?? this.createdAt,
  );
  PurchaseItem copyWithCompanion(PurchaseItemsCompanion data) {
    return PurchaseItem(
      purchaseId: data.purchaseId.present
          ? data.purchaseId.value
          : this.purchaseId,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      targetName: data.targetName.present
          ? data.targetName.value
          : this.targetName,
      allocatedMinor: data.allocatedMinor.present
          ? data.allocatedMinor.value
          : this.allocatedMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItem(')
          ..write('purchaseId: $purchaseId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('targetName: $targetName, ')
          ..write('allocatedMinor: $allocatedMinor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    purchaseId,
    targetType,
    targetId,
    targetName,
    allocatedMinor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseItem &&
          other.purchaseId == this.purchaseId &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.targetName == this.targetName &&
          other.allocatedMinor == this.allocatedMinor &&
          other.createdAt == this.createdAt);
}

class PurchaseItemsCompanion extends UpdateCompanion<PurchaseItem> {
  final Value<String> purchaseId;
  final Value<PurchaseTargetType> targetType;
  final Value<String> targetId;
  final Value<String> targetName;
  final Value<int?> allocatedMinor;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PurchaseItemsCompanion({
    this.purchaseId = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.targetName = const Value.absent(),
    this.allocatedMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchaseItemsCompanion.insert({
    required String purchaseId,
    required PurchaseTargetType targetType,
    required String targetId,
    required String targetName,
    this.allocatedMinor = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : purchaseId = Value(purchaseId),
       targetType = Value(targetType),
       targetId = Value(targetId),
       targetName = Value(targetName),
       createdAt = Value(createdAt);
  static Insertable<PurchaseItem> custom({
    Expression<String>? purchaseId,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<String>? targetName,
    Expression<int>? allocatedMinor,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (targetName != null) 'target_name': targetName,
      if (allocatedMinor != null) 'allocated_minor': allocatedMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchaseItemsCompanion copyWith({
    Value<String>? purchaseId,
    Value<PurchaseTargetType>? targetType,
    Value<String>? targetId,
    Value<String>? targetName,
    Value<int?>? allocatedMinor,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PurchaseItemsCompanion(
      purchaseId: purchaseId ?? this.purchaseId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      targetName: targetName ?? this.targetName,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (purchaseId.present) {
      map['purchase_id'] = Variable<String>(purchaseId.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(
        $PurchaseItemsTable.$convertertargetType.toSql(targetType.value),
      );
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (targetName.present) {
      map['target_name'] = Variable<String>(targetName.value);
    }
    if (allocatedMinor.present) {
      map['allocated_minor'] = Variable<int>(allocatedMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemsCompanion(')
          ..write('purchaseId: $purchaseId, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('targetName: $targetName, ')
          ..write('allocatedMinor: $allocatedMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _baseCurrencyMeta = const VerificationMeta(
    'baseCurrency',
  );
  @override
  late final GeneratedColumn<String> baseCurrency = GeneratedColumn<String>(
    'base_currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quoteCurrencyMeta = const VerificationMeta(
    'quoteCurrency',
  );
  @override
  late final GeneratedColumn<String> quoteCurrency = GeneratedColumn<String>(
    'quote_currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateDateMeta = const VerificationMeta(
    'rateDate',
  );
  @override
  late final GeneratedColumn<DateTime> rateDate = GeneratedColumn<DateTime>(
    'rate_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _numeratorMeta = const VerificationMeta(
    'numerator',
  );
  @override
  late final GeneratedColumn<int> numerator = GeneratedColumn<int>(
    'numerator',
    aliasedName,
    false,
    check: () => ComparableExpr(numerator).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _denominatorMeta = const VerificationMeta(
    'denominator',
  );
  @override
  late final GeneratedColumn<int> denominator = GeneratedColumn<int>(
    'denominator',
    aliasedName,
    false,
    check: () => ComparableExpr(denominator).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    baseCurrency,
    quoteCurrency,
    rateDate,
    numerator,
    denominator,
    source,
    capturedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('base_currency')) {
      context.handle(
        _baseCurrencyMeta,
        baseCurrency.isAcceptableOrUnknown(
          data['base_currency']!,
          _baseCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseCurrencyMeta);
    }
    if (data.containsKey('quote_currency')) {
      context.handle(
        _quoteCurrencyMeta,
        quoteCurrency.isAcceptableOrUnknown(
          data['quote_currency']!,
          _quoteCurrencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quoteCurrencyMeta);
    }
    if (data.containsKey('rate_date')) {
      context.handle(
        _rateDateMeta,
        rateDate.isAcceptableOrUnknown(data['rate_date']!, _rateDateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateDateMeta);
    }
    if (data.containsKey('numerator')) {
      context.handle(
        _numeratorMeta,
        numerator.isAcceptableOrUnknown(data['numerator']!, _numeratorMeta),
      );
    } else if (isInserting) {
      context.missing(_numeratorMeta);
    }
    if (data.containsKey('denominator')) {
      context.handle(
        _denominatorMeta,
        denominator.isAcceptableOrUnknown(
          data['denominator']!,
          _denominatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_denominatorMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    baseCurrency,
    quoteCurrency,
    rateDate,
    source,
  };
  @override
  ExchangeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRate(
      baseCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_currency'],
      )!,
      quoteCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_currency'],
      )!,
      rateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rate_date'],
      )!,
      numerator: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numerator'],
      )!,
      denominator: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}denominator'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }
}

class ExchangeRate extends DataClass implements Insertable<ExchangeRate> {
  final String baseCurrency;
  final String quoteCurrency;
  final DateTime rateDate;
  final int numerator;
  final int denominator;
  final String source;
  final DateTime capturedAt;
  const ExchangeRate({
    required this.baseCurrency,
    required this.quoteCurrency,
    required this.rateDate,
    required this.numerator,
    required this.denominator,
    required this.source,
    required this.capturedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['base_currency'] = Variable<String>(baseCurrency);
    map['quote_currency'] = Variable<String>(quoteCurrency);
    map['rate_date'] = Variable<DateTime>(rateDate);
    map['numerator'] = Variable<int>(numerator);
    map['denominator'] = Variable<int>(denominator);
    map['source'] = Variable<String>(source);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      baseCurrency: Value(baseCurrency),
      quoteCurrency: Value(quoteCurrency),
      rateDate: Value(rateDate),
      numerator: Value(numerator),
      denominator: Value(denominator),
      source: Value(source),
      capturedAt: Value(capturedAt),
    );
  }

  factory ExchangeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRate(
      baseCurrency: serializer.fromJson<String>(json['baseCurrency']),
      quoteCurrency: serializer.fromJson<String>(json['quoteCurrency']),
      rateDate: serializer.fromJson<DateTime>(json['rateDate']),
      numerator: serializer.fromJson<int>(json['numerator']),
      denominator: serializer.fromJson<int>(json['denominator']),
      source: serializer.fromJson<String>(json['source']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'baseCurrency': serializer.toJson<String>(baseCurrency),
      'quoteCurrency': serializer.toJson<String>(quoteCurrency),
      'rateDate': serializer.toJson<DateTime>(rateDate),
      'numerator': serializer.toJson<int>(numerator),
      'denominator': serializer.toJson<int>(denominator),
      'source': serializer.toJson<String>(source),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
    };
  }

  ExchangeRate copyWith({
    String? baseCurrency,
    String? quoteCurrency,
    DateTime? rateDate,
    int? numerator,
    int? denominator,
    String? source,
    DateTime? capturedAt,
  }) => ExchangeRate(
    baseCurrency: baseCurrency ?? this.baseCurrency,
    quoteCurrency: quoteCurrency ?? this.quoteCurrency,
    rateDate: rateDate ?? this.rateDate,
    numerator: numerator ?? this.numerator,
    denominator: denominator ?? this.denominator,
    source: source ?? this.source,
    capturedAt: capturedAt ?? this.capturedAt,
  );
  ExchangeRate copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRate(
      baseCurrency: data.baseCurrency.present
          ? data.baseCurrency.value
          : this.baseCurrency,
      quoteCurrency: data.quoteCurrency.present
          ? data.quoteCurrency.value
          : this.quoteCurrency,
      rateDate: data.rateDate.present ? data.rateDate.value : this.rateDate,
      numerator: data.numerator.present ? data.numerator.value : this.numerator,
      denominator: data.denominator.present
          ? data.denominator.value
          : this.denominator,
      source: data.source.present ? data.source.value : this.source,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRate(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rateDate: $rateDate, ')
          ..write('numerator: $numerator, ')
          ..write('denominator: $denominator, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    baseCurrency,
    quoteCurrency,
    rateDate,
    numerator,
    denominator,
    source,
    capturedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRate &&
          other.baseCurrency == this.baseCurrency &&
          other.quoteCurrency == this.quoteCurrency &&
          other.rateDate == this.rateDate &&
          other.numerator == this.numerator &&
          other.denominator == this.denominator &&
          other.source == this.source &&
          other.capturedAt == this.capturedAt);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRate> {
  final Value<String> baseCurrency;
  final Value<String> quoteCurrency;
  final Value<DateTime> rateDate;
  final Value<int> numerator;
  final Value<int> denominator;
  final Value<String> source;
  final Value<DateTime> capturedAt;
  final Value<int> rowid;
  const ExchangeRatesCompanion({
    this.baseCurrency = const Value.absent(),
    this.quoteCurrency = const Value.absent(),
    this.rateDate = const Value.absent(),
    this.numerator = const Value.absent(),
    this.denominator = const Value.absent(),
    this.source = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    required String baseCurrency,
    required String quoteCurrency,
    required DateTime rateDate,
    required int numerator,
    required int denominator,
    required String source,
    required DateTime capturedAt,
    this.rowid = const Value.absent(),
  }) : baseCurrency = Value(baseCurrency),
       quoteCurrency = Value(quoteCurrency),
       rateDate = Value(rateDate),
       numerator = Value(numerator),
       denominator = Value(denominator),
       source = Value(source),
       capturedAt = Value(capturedAt);
  static Insertable<ExchangeRate> custom({
    Expression<String>? baseCurrency,
    Expression<String>? quoteCurrency,
    Expression<DateTime>? rateDate,
    Expression<int>? numerator,
    Expression<int>? denominator,
    Expression<String>? source,
    Expression<DateTime>? capturedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (baseCurrency != null) 'base_currency': baseCurrency,
      if (quoteCurrency != null) 'quote_currency': quoteCurrency,
      if (rateDate != null) 'rate_date': rateDate,
      if (numerator != null) 'numerator': numerator,
      if (denominator != null) 'denominator': denominator,
      if (source != null) 'source': source,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExchangeRatesCompanion copyWith({
    Value<String>? baseCurrency,
    Value<String>? quoteCurrency,
    Value<DateTime>? rateDate,
    Value<int>? numerator,
    Value<int>? denominator,
    Value<String>? source,
    Value<DateTime>? capturedAt,
    Value<int>? rowid,
  }) {
    return ExchangeRatesCompanion(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      quoteCurrency: quoteCurrency ?? this.quoteCurrency,
      rateDate: rateDate ?? this.rateDate,
      numerator: numerator ?? this.numerator,
      denominator: denominator ?? this.denominator,
      source: source ?? this.source,
      capturedAt: capturedAt ?? this.capturedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (baseCurrency.present) {
      map['base_currency'] = Variable<String>(baseCurrency.value);
    }
    if (quoteCurrency.present) {
      map['quote_currency'] = Variable<String>(quoteCurrency.value);
    }
    if (rateDate.present) {
      map['rate_date'] = Variable<DateTime>(rateDate.value);
    }
    if (numerator.present) {
      map['numerator'] = Variable<int>(numerator.value);
    }
    if (denominator.present) {
      map['denominator'] = Variable<int>(denominator.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('baseCurrency: $baseCurrency, ')
          ..write('quoteCurrency: $quoteCurrency, ')
          ..write('rateDate: $rateDate, ')
          ..write('numerator: $numerator, ')
          ..write('denominator: $denominator, ')
          ..write('source: $source, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecycleBinSettingsRowsTable extends RecycleBinSettingsRows
    with TableInfo<$RecycleBinSettingsRowsTable, RecycleBinSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecycleBinSettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retentionDaysMeta = const VerificationMeta(
    'retentionDays',
  );
  @override
  late final GeneratedColumn<int> retentionDays = GeneratedColumn<int>(
    'retention_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, retentionDays, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recycle_bin_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecycleBinSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('retention_days')) {
      context.handle(
        _retentionDaysMeta,
        retentionDays.isAcceptableOrUnknown(
          data['retention_days']!,
          _retentionDaysMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecycleBinSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecycleBinSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      retentionDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retention_days'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RecycleBinSettingsRowsTable createAlias(String alias) {
    return $RecycleBinSettingsRowsTable(attachedDatabase, alias);
  }
}

class RecycleBinSettingsRow extends DataClass
    implements Insertable<RecycleBinSettingsRow> {
  final int id;
  final int retentionDays;
  final DateTime updatedAt;
  const RecycleBinSettingsRow({
    required this.id,
    required this.retentionDays,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['retention_days'] = Variable<int>(retentionDays);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RecycleBinSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return RecycleBinSettingsRowsCompanion(
      id: Value(id),
      retentionDays: Value(retentionDays),
      updatedAt: Value(updatedAt),
    );
  }

  factory RecycleBinSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecycleBinSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      retentionDays: serializer.fromJson<int>(json['retentionDays']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'retentionDays': serializer.toJson<int>(retentionDays),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RecycleBinSettingsRow copyWith({
    int? id,
    int? retentionDays,
    DateTime? updatedAt,
  }) => RecycleBinSettingsRow(
    id: id ?? this.id,
    retentionDays: retentionDays ?? this.retentionDays,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RecycleBinSettingsRow copyWithCompanion(
    RecycleBinSettingsRowsCompanion data,
  ) {
    return RecycleBinSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      retentionDays: data.retentionDays.present
          ? data.retentionDays.value
          : this.retentionDays,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecycleBinSettingsRow(')
          ..write('id: $id, ')
          ..write('retentionDays: $retentionDays, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, retentionDays, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecycleBinSettingsRow &&
          other.id == this.id &&
          other.retentionDays == this.retentionDays &&
          other.updatedAt == this.updatedAt);
}

class RecycleBinSettingsRowsCompanion
    extends UpdateCompanion<RecycleBinSettingsRow> {
  final Value<int> id;
  final Value<int> retentionDays;
  final Value<DateTime> updatedAt;
  const RecycleBinSettingsRowsCompanion({
    this.id = const Value.absent(),
    this.retentionDays = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RecycleBinSettingsRowsCompanion.insert({
    this.id = const Value.absent(),
    this.retentionDays = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<RecycleBinSettingsRow> custom({
    Expression<int>? id,
    Expression<int>? retentionDays,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (retentionDays != null) 'retention_days': retentionDays,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RecycleBinSettingsRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? retentionDays,
    Value<DateTime>? updatedAt,
  }) {
    return RecycleBinSettingsRowsCompanion(
      id: id ?? this.id,
      retentionDays: retentionDays ?? this.retentionDays,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (retentionDays.present) {
      map['retention_days'] = Variable<int>(retentionDays.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecycleBinSettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('retentionDays: $retentionDays, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FileCleanupQueueEntriesTable extends FileCleanupQueueEntries
    with TableInfo<$FileCleanupQueueEntriesTable, FileCleanupQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileCleanupQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    relativePath,
    createdAt,
    attemptCount,
    lastAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_cleanup_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<FileCleanupQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {relativePath};
  @override
  FileCleanupQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileCleanupQueueEntry(
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
    );
  }

  @override
  $FileCleanupQueueEntriesTable createAlias(String alias) {
    return $FileCleanupQueueEntriesTable(attachedDatabase, alias);
  }
}

class FileCleanupQueueEntry extends DataClass
    implements Insertable<FileCleanupQueueEntry> {
  final String relativePath;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? lastAttemptAt;
  const FileCleanupQueueEntry({
    required this.relativePath,
    required this.createdAt,
    required this.attemptCount,
    this.lastAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['relative_path'] = Variable<String>(relativePath);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  FileCleanupQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return FileCleanupQueueEntriesCompanion(
      relativePath: Value(relativePath),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory FileCleanupQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileCleanupQueueEntry(
      relativePath: serializer.fromJson<String>(json['relativePath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'relativePath': serializer.toJson<String>(relativePath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  FileCleanupQueueEntry copyWith({
    String? relativePath,
    DateTime? createdAt,
    int? attemptCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
  }) => FileCleanupQueueEntry(
    relativePath: relativePath ?? this.relativePath,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
  );
  FileCleanupQueueEntry copyWithCompanion(
    FileCleanupQueueEntriesCompanion data,
  ) {
    return FileCleanupQueueEntry(
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileCleanupQueueEntry(')
          ..write('relativePath: $relativePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(relativePath, createdAt, attemptCount, lastAttemptAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileCleanupQueueEntry &&
          other.relativePath == this.relativePath &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class FileCleanupQueueEntriesCompanion
    extends UpdateCompanion<FileCleanupQueueEntry> {
  final Value<String> relativePath;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<int> rowid;
  const FileCleanupQueueEntriesCompanion({
    this.relativePath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileCleanupQueueEntriesCompanion.insert({
    required String relativePath,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : relativePath = Value(relativePath),
       createdAt = Value(createdAt);
  static Insertable<FileCleanupQueueEntry> custom({
    Expression<String>? relativePath,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (relativePath != null) 'relative_path': relativePath,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileCleanupQueueEntriesCompanion copyWith({
    Value<String>? relativePath,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<DateTime?>? lastAttemptAt,
    Value<int>? rowid,
  }) {
    return FileCleanupQueueEntriesCompanion(
      relativePath: relativePath ?? this.relativePath,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileCleanupQueueEntriesCompanion(')
          ..write('relativePath: $relativePath, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncSettingsRowsTable extends SyncSettingsRows
    with TableInfo<$SyncSettingsRowsTable, SyncSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncSettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<String> cursor = GeneratedColumn<String>(
    'cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountUserIdMeta = const VerificationMeta(
    'accountUserId',
  );
  @override
  late final GeneratedColumn<String> accountUserId = GeneratedColumn<String>(
    'account_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountEmailMeta = const VerificationMeta(
    'accountEmail',
  );
  @override
  late final GeneratedColumn<String> accountEmail = GeneratedColumn<String>(
    'account_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    enabled,
    cursor,
    accountUserId,
    accountEmail,
    lastSyncedAt,
    lastErrorCode,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('account_user_id')) {
      context.handle(
        _accountUserIdMeta,
        accountUserId.isAcceptableOrUnknown(
          data['account_user_id']!,
          _accountUserIdMeta,
        ),
      );
    }
    if (data.containsKey('account_email')) {
      context.handle(
        _accountEmailMeta,
        accountEmail.isAcceptableOrUnknown(
          data['account_email']!,
          _accountEmailMeta,
        ),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor'],
      ),
      accountUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_user_id'],
      ),
      accountEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_email'],
      ),
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_synced_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncSettingsRowsTable createAlias(String alias) {
    return $SyncSettingsRowsTable(attachedDatabase, alias);
  }
}

class SyncSettingsRow extends DataClass implements Insertable<SyncSettingsRow> {
  final int id;
  final String deviceId;
  final bool enabled;
  final String? cursor;
  final String? accountUserId;
  final String? accountEmail;
  final DateTime? lastSyncedAt;
  final String? lastErrorCode;
  final DateTime updatedAt;
  const SyncSettingsRow({
    required this.id,
    required this.deviceId,
    required this.enabled,
    this.cursor,
    this.accountUserId,
    this.accountEmail,
    this.lastSyncedAt,
    this.lastErrorCode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['enabled'] = Variable<bool>(enabled);
    if (!nullToAbsent || cursor != null) {
      map['cursor'] = Variable<String>(cursor);
    }
    if (!nullToAbsent || accountUserId != null) {
      map['account_user_id'] = Variable<String>(accountUserId);
    }
    if (!nullToAbsent || accountEmail != null) {
      map['account_email'] = Variable<String>(accountEmail);
    }
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncSettingsRowsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      enabled: Value(enabled),
      cursor: cursor == null && nullToAbsent
          ? const Value.absent()
          : Value(cursor),
      accountUserId: accountUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountUserId),
      accountEmail: accountEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(accountEmail),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncSettingsRow(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      cursor: serializer.fromJson<String?>(json['cursor']),
      accountUserId: serializer.fromJson<String?>(json['accountUserId']),
      accountEmail: serializer.fromJson<String?>(json['accountEmail']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'enabled': serializer.toJson<bool>(enabled),
      'cursor': serializer.toJson<String?>(cursor),
      'accountUserId': serializer.toJson<String?>(accountUserId),
      'accountEmail': serializer.toJson<String?>(accountEmail),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncSettingsRow copyWith({
    int? id,
    String? deviceId,
    bool? enabled,
    Value<String?> cursor = const Value.absent(),
    Value<String?> accountUserId = const Value.absent(),
    Value<String?> accountEmail = const Value.absent(),
    Value<DateTime?> lastSyncedAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
    DateTime? updatedAt,
  }) => SyncSettingsRow(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    enabled: enabled ?? this.enabled,
    cursor: cursor.present ? cursor.value : this.cursor,
    accountUserId: accountUserId.present
        ? accountUserId.value
        : this.accountUserId,
    accountEmail: accountEmail.present ? accountEmail.value : this.accountEmail,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncSettingsRow copyWithCompanion(SyncSettingsRowsCompanion data) {
    return SyncSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      accountUserId: data.accountUserId.present
          ? data.accountUserId.value
          : this.accountUserId,
      accountEmail: data.accountEmail.present
          ? data.accountEmail.value
          : this.accountEmail,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncSettingsRow(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('enabled: $enabled, ')
          ..write('cursor: $cursor, ')
          ..write('accountUserId: $accountUserId, ')
          ..write('accountEmail: $accountEmail, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    enabled,
    cursor,
    accountUserId,
    accountEmail,
    lastSyncedAt,
    lastErrorCode,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncSettingsRow &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.enabled == this.enabled &&
          other.cursor == this.cursor &&
          other.accountUserId == this.accountUserId &&
          other.accountEmail == this.accountEmail &&
          other.lastSyncedAt == this.lastSyncedAt &&
          other.lastErrorCode == this.lastErrorCode &&
          other.updatedAt == this.updatedAt);
}

class SyncSettingsRowsCompanion extends UpdateCompanion<SyncSettingsRow> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<bool> enabled;
  final Value<String?> cursor;
  final Value<String?> accountUserId;
  final Value<String?> accountEmail;
  final Value<DateTime?> lastSyncedAt;
  final Value<String?> lastErrorCode;
  final Value<DateTime> updatedAt;
  const SyncSettingsRowsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.cursor = const Value.absent(),
    this.accountUserId = const Value.absent(),
    this.accountEmail = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncSettingsRowsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    this.enabled = const Value.absent(),
    this.cursor = const Value.absent(),
    this.accountUserId = const Value.absent(),
    this.accountEmail = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    required DateTime updatedAt,
  }) : deviceId = Value(deviceId),
       updatedAt = Value(updatedAt);
  static Insertable<SyncSettingsRow> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<bool>? enabled,
    Expression<String>? cursor,
    Expression<String>? accountUserId,
    Expression<String>? accountEmail,
    Expression<DateTime>? lastSyncedAt,
    Expression<String>? lastErrorCode,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (enabled != null) 'enabled': enabled,
      if (cursor != null) 'cursor': cursor,
      if (accountUserId != null) 'account_user_id': accountUserId,
      if (accountEmail != null) 'account_email': accountEmail,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncSettingsRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<bool>? enabled,
    Value<String?>? cursor,
    Value<String?>? accountUserId,
    Value<String?>? accountEmail,
    Value<DateTime?>? lastSyncedAt,
    Value<String?>? lastErrorCode,
    Value<DateTime>? updatedAt,
  }) {
    return SyncSettingsRowsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      enabled: enabled ?? this.enabled,
      cursor: cursor ?? this.cursor,
      accountUserId: accountUserId ?? this.accountUserId,
      accountEmail: accountEmail ?? this.accountEmail,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<String>(cursor.value);
    }
    if (accountUserId.present) {
      map['account_user_id'] = Variable<String>(accountUserId.value);
    }
    if (accountEmail.present) {
      map['account_email'] = Variable<String>(accountEmail.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncSettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('enabled: $enabled, ')
          ..write('cursor: $cursor, ')
          ..write('accountUserId: $accountUserId, ')
          ..write('accountEmail: $accountEmail, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncEntityStateRowsTable extends SyncEntityStateRows
    with TableInfo<$SyncEntityStateRowsTable, SyncEntityStateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncEntityStateRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverVersionMeta = const VerificationMeta(
    'serverVersion',
  );
  @override
  late final GeneratedColumn<int> serverVersion = GeneratedColumn<int>(
    'server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entityType,
    entityId,
    serverVersion,
    payloadJson,
    deleted,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_entity_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncEntityStateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('server_version')) {
      context.handle(
        _serverVersionMeta,
        serverVersion.isAcceptableOrUnknown(
          data['server_version']!,
          _serverVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverVersionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityType, entityId};
  @override
  SyncEntityStateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncEntityStateRow(
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      serverVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncEntityStateRowsTable createAlias(String alias) {
    return $SyncEntityStateRowsTable(attachedDatabase, alias);
  }
}

class SyncEntityStateRow extends DataClass
    implements Insertable<SyncEntityStateRow> {
  final String entityType;
  final String entityId;
  final int serverVersion;
  final String? payloadJson;
  final bool deleted;
  final DateTime updatedAt;
  const SyncEntityStateRow({
    required this.entityType,
    required this.entityId,
    required this.serverVersion,
    this.payloadJson,
    required this.deleted,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['server_version'] = Variable<int>(serverVersion);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['deleted'] = Variable<bool>(deleted);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncEntityStateRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncEntityStateRowsCompanion(
      entityType: Value(entityType),
      entityId: Value(entityId),
      serverVersion: Value(serverVersion),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      deleted: Value(deleted),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncEntityStateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncEntityStateRow(
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      serverVersion: serializer.fromJson<int>(json['serverVersion']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'serverVersion': serializer.toJson<int>(serverVersion),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'deleted': serializer.toJson<bool>(deleted),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncEntityStateRow copyWith({
    String? entityType,
    String? entityId,
    int? serverVersion,
    Value<String?> payloadJson = const Value.absent(),
    bool? deleted,
    DateTime? updatedAt,
  }) => SyncEntityStateRow(
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    serverVersion: serverVersion ?? this.serverVersion,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    deleted: deleted ?? this.deleted,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncEntityStateRow copyWithCompanion(SyncEntityStateRowsCompanion data) {
    return SyncEntityStateRow(
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      serverVersion: data.serverVersion.present
          ? data.serverVersion.value
          : this.serverVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityStateRow(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    entityType,
    entityId,
    serverVersion,
    payloadJson,
    deleted,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncEntityStateRow &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.serverVersion == this.serverVersion &&
          other.payloadJson == this.payloadJson &&
          other.deleted == this.deleted &&
          other.updatedAt == this.updatedAt);
}

class SyncEntityStateRowsCompanion extends UpdateCompanion<SyncEntityStateRow> {
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> serverVersion;
  final Value<String?> payloadJson;
  final Value<bool> deleted;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncEntityStateRowsCompanion({
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.serverVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.deleted = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncEntityStateRowsCompanion.insert({
    required String entityType,
    required String entityId,
    required int serverVersion,
    this.payloadJson = const Value.absent(),
    this.deleted = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : entityType = Value(entityType),
       entityId = Value(entityId),
       serverVersion = Value(serverVersion),
       updatedAt = Value(updatedAt);
  static Insertable<SyncEntityStateRow> custom({
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? serverVersion,
    Expression<String>? payloadJson,
    Expression<bool>? deleted,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (serverVersion != null) 'server_version': serverVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (deleted != null) 'deleted': deleted,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncEntityStateRowsCompanion copyWith({
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? serverVersion,
    Value<String?>? payloadJson,
    Value<bool>? deleted,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncEntityStateRowsCompanion(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      serverVersion: serverVersion ?? this.serverVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      deleted: deleted ?? this.deleted,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (serverVersion.present) {
      map['server_version'] = Variable<int>(serverVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncEntityStateRowsCompanion(')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('serverVersion: $serverVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('deleted: $deleted, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxEntriesTable extends SyncOutboxEntries
    with TableInfo<$SyncOutboxEntriesTable, SyncOutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseServerVersionMeta = const VerificationMeta(
    'baseServerVersion',
  );
  @override
  late final GeneratedColumn<int> baseServerVersion = GeneratedColumn<int>(
    'base_server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changedFieldsJsonMeta = const VerificationMeta(
    'changedFieldsJson',
  );
  @override
  late final GeneratedColumn<String> changedFieldsJson =
      GeneratedColumn<String>(
        'changed_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorCodeMeta = const VerificationMeta(
    'lastErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastErrorCode = GeneratedColumn<String>(
    'last_error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    operationId,
    entityType,
    entityId,
    operation,
    baseServerVersion,
    payloadJson,
    changedFieldsJson,
    createdAt,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('base_server_version')) {
      context.handle(
        _baseServerVersionMeta,
        baseServerVersion.isAcceptableOrUnknown(
          data['base_server_version']!,
          _baseServerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseServerVersionMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('changed_fields_json')) {
      context.handle(
        _changedFieldsJsonMeta,
        changedFieldsJson.isAcceptableOrUnknown(
          data['changed_fields_json']!,
          _changedFieldsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changedFieldsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error_code')) {
      context.handle(
        _lastErrorCodeMeta,
        lastErrorCode.isAcceptableOrUnknown(
          data['last_error_code']!,
          _lastErrorCodeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {operationId};
  @override
  SyncOutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxEntry(
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      baseServerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_server_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      changedFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changed_fields_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error_code'],
      ),
    );
  }

  @override
  $SyncOutboxEntriesTable createAlias(String alias) {
    return $SyncOutboxEntriesTable(attachedDatabase, alias);
  }
}

class SyncOutboxEntry extends DataClass implements Insertable<SyncOutboxEntry> {
  final String operationId;
  final String entityType;
  final String entityId;
  final String operation;
  final int baseServerVersion;
  final String? payloadJson;
  final String changedFieldsJson;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? nextAttemptAt;
  final String? lastErrorCode;
  const SyncOutboxEntry({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.baseServerVersion,
    this.payloadJson,
    required this.changedFieldsJson,
    required this.createdAt,
    required this.attemptCount,
    this.nextAttemptAt,
    this.lastErrorCode,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['operation_id'] = Variable<String>(operationId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['base_server_version'] = Variable<int>(baseServerVersion);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['changed_fields_json'] = Variable<String>(changedFieldsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastErrorCode != null) {
      map['last_error_code'] = Variable<String>(lastErrorCode);
    }
    return map;
  }

  SyncOutboxEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxEntriesCompanion(
      operationId: Value(operationId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      baseServerVersion: Value(baseServerVersion),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      changedFieldsJson: Value(changedFieldsJson),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastErrorCode: lastErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastErrorCode),
    );
  }

  factory SyncOutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxEntry(
      operationId: serializer.fromJson<String>(json['operationId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      baseServerVersion: serializer.fromJson<int>(json['baseServerVersion']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      changedFieldsJson: serializer.fromJson<String>(json['changedFieldsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastErrorCode: serializer.fromJson<String?>(json['lastErrorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'operationId': serializer.toJson<String>(operationId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'baseServerVersion': serializer.toJson<int>(baseServerVersion),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'changedFieldsJson': serializer.toJson<String>(changedFieldsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastErrorCode': serializer.toJson<String?>(lastErrorCode),
    };
  }

  SyncOutboxEntry copyWith({
    String? operationId,
    String? entityType,
    String? entityId,
    String? operation,
    int? baseServerVersion,
    Value<String?> payloadJson = const Value.absent(),
    String? changedFieldsJson,
    DateTime? createdAt,
    int? attemptCount,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<String?> lastErrorCode = const Value.absent(),
  }) => SyncOutboxEntry(
    operationId: operationId ?? this.operationId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    baseServerVersion: baseServerVersion ?? this.baseServerVersion,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    changedFieldsJson: changedFieldsJson ?? this.changedFieldsJson,
    createdAt: createdAt ?? this.createdAt,
    attemptCount: attemptCount ?? this.attemptCount,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastErrorCode: lastErrorCode.present
        ? lastErrorCode.value
        : this.lastErrorCode,
  );
  SyncOutboxEntry copyWithCompanion(SyncOutboxEntriesCompanion data) {
    return SyncOutboxEntry(
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      baseServerVersion: data.baseServerVersion.present
          ? data.baseServerVersion.value
          : this.baseServerVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      changedFieldsJson: data.changedFieldsJson.present
          ? data.changedFieldsJson.value
          : this.changedFieldsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastErrorCode: data.lastErrorCode.present
          ? data.lastErrorCode.value
          : this.lastErrorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntry(')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('baseServerVersion: $baseServerVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('changedFieldsJson: $changedFieldsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    operationId,
    entityType,
    entityId,
    operation,
    baseServerVersion,
    payloadJson,
    changedFieldsJson,
    createdAt,
    attemptCount,
    nextAttemptAt,
    lastErrorCode,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxEntry &&
          other.operationId == this.operationId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.baseServerVersion == this.baseServerVersion &&
          other.payloadJson == this.payloadJson &&
          other.changedFieldsJson == this.changedFieldsJson &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastErrorCode == this.lastErrorCode);
}

class SyncOutboxEntriesCompanion extends UpdateCompanion<SyncOutboxEntry> {
  final Value<String> operationId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<int> baseServerVersion;
  final Value<String?> payloadJson;
  final Value<String> changedFieldsJson;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> nextAttemptAt;
  final Value<String?> lastErrorCode;
  final Value<int> rowid;
  const SyncOutboxEntriesCompanion({
    this.operationId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.baseServerVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.changedFieldsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxEntriesCompanion.insert({
    required String operationId,
    required String entityType,
    required String entityId,
    required String operation,
    required int baseServerVersion,
    this.payloadJson = const Value.absent(),
    required String changedFieldsJson,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastErrorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : operationId = Value(operationId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation),
       baseServerVersion = Value(baseServerVersion),
       changedFieldsJson = Value(changedFieldsJson),
       createdAt = Value(createdAt);
  static Insertable<SyncOutboxEntry> custom({
    Expression<String>? operationId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<int>? baseServerVersion,
    Expression<String>? payloadJson,
    Expression<String>? changedFieldsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? nextAttemptAt,
    Expression<String>? lastErrorCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (operationId != null) 'operation_id': operationId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (baseServerVersion != null) 'base_server_version': baseServerVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (changedFieldsJson != null) 'changed_fields_json': changedFieldsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastErrorCode != null) 'last_error_code': lastErrorCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxEntriesCompanion copyWith({
    Value<String>? operationId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<int>? baseServerVersion,
    Value<String?>? payloadJson,
    Value<String>? changedFieldsJson,
    Value<DateTime>? createdAt,
    Value<int>? attemptCount,
    Value<DateTime?>? nextAttemptAt,
    Value<String?>? lastErrorCode,
    Value<int>? rowid,
  }) {
    return SyncOutboxEntriesCompanion(
      operationId: operationId ?? this.operationId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      baseServerVersion: baseServerVersion ?? this.baseServerVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      changedFieldsJson: changedFieldsJson ?? this.changedFieldsJson,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (baseServerVersion.present) {
      map['base_server_version'] = Variable<int>(baseServerVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (changedFieldsJson.present) {
      map['changed_fields_json'] = Variable<String>(changedFieldsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastErrorCode.present) {
      map['last_error_code'] = Variable<String>(lastErrorCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxEntriesCompanion(')
          ..write('operationId: $operationId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('baseServerVersion: $baseServerVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('changedFieldsJson: $changedFieldsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastErrorCode: $lastErrorCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncConflictRowsTable extends SyncConflictRows
    with TableInfo<$SyncConflictRowsTable, SyncConflictRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncConflictRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localOperationMeta = const VerificationMeta(
    'localOperation',
  );
  @override
  late final GeneratedColumn<String> localOperation = GeneratedColumn<String>(
    'local_operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPayloadJsonMeta = const VerificationMeta(
    'localPayloadJson',
  );
  @override
  late final GeneratedColumn<String> localPayloadJson = GeneratedColumn<String>(
    'local_payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteOperationMeta = const VerificationMeta(
    'remoteOperation',
  );
  @override
  late final GeneratedColumn<String> remoteOperation = GeneratedColumn<String>(
    'remote_operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remotePayloadJsonMeta = const VerificationMeta(
    'remotePayloadJson',
  );
  @override
  late final GeneratedColumn<String> remotePayloadJson =
      GeneratedColumn<String>(
        'remote_payload_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _remoteServerVersionMeta =
      const VerificationMeta('remoteServerVersion');
  @override
  late final GeneratedColumn<int> remoteServerVersion = GeneratedColumn<int>(
    'remote_server_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conflictingFieldsJsonMeta =
      const VerificationMeta('conflictingFieldsJson');
  @override
  late final GeneratedColumn<String> conflictingFieldsJson =
      GeneratedColumn<String>(
        'conflicting_fields_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityType,
    entityId,
    localOperation,
    localPayloadJson,
    remoteOperation,
    remotePayloadJson,
    remoteServerVersion,
    conflictingFieldsJson,
    detectedAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncConflictRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('local_operation')) {
      context.handle(
        _localOperationMeta,
        localOperation.isAcceptableOrUnknown(
          data['local_operation']!,
          _localOperationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localOperationMeta);
    }
    if (data.containsKey('local_payload_json')) {
      context.handle(
        _localPayloadJsonMeta,
        localPayloadJson.isAcceptableOrUnknown(
          data['local_payload_json']!,
          _localPayloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('remote_operation')) {
      context.handle(
        _remoteOperationMeta,
        remoteOperation.isAcceptableOrUnknown(
          data['remote_operation']!,
          _remoteOperationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteOperationMeta);
    }
    if (data.containsKey('remote_payload_json')) {
      context.handle(
        _remotePayloadJsonMeta,
        remotePayloadJson.isAcceptableOrUnknown(
          data['remote_payload_json']!,
          _remotePayloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('remote_server_version')) {
      context.handle(
        _remoteServerVersionMeta,
        remoteServerVersion.isAcceptableOrUnknown(
          data['remote_server_version']!,
          _remoteServerVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteServerVersionMeta);
    }
    if (data.containsKey('conflicting_fields_json')) {
      context.handle(
        _conflictingFieldsJsonMeta,
        conflictingFieldsJson.isAcceptableOrUnknown(
          data['conflicting_fields_json']!,
          _conflictingFieldsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conflictingFieldsJsonMeta);
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncConflictRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncConflictRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      localOperation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_operation'],
      )!,
      localPayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_payload_json'],
      ),
      remoteOperation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_operation'],
      )!,
      remotePayloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_payload_json'],
      ),
      remoteServerVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}remote_server_version'],
      )!,
      conflictingFieldsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conflicting_fields_json'],
      )!,
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $SyncConflictRowsTable createAlias(String alias) {
    return $SyncConflictRowsTable(attachedDatabase, alias);
  }
}

class SyncConflictRow extends DataClass implements Insertable<SyncConflictRow> {
  final String id;
  final String entityType;
  final String entityId;
  final String localOperation;
  final String? localPayloadJson;
  final String remoteOperation;
  final String? remotePayloadJson;
  final int remoteServerVersion;
  final String conflictingFieldsJson;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  const SyncConflictRow({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.localOperation,
    this.localPayloadJson,
    required this.remoteOperation,
    this.remotePayloadJson,
    required this.remoteServerVersion,
    required this.conflictingFieldsJson,
    required this.detectedAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['local_operation'] = Variable<String>(localOperation);
    if (!nullToAbsent || localPayloadJson != null) {
      map['local_payload_json'] = Variable<String>(localPayloadJson);
    }
    map['remote_operation'] = Variable<String>(remoteOperation);
    if (!nullToAbsent || remotePayloadJson != null) {
      map['remote_payload_json'] = Variable<String>(remotePayloadJson);
    }
    map['remote_server_version'] = Variable<int>(remoteServerVersion);
    map['conflicting_fields_json'] = Variable<String>(conflictingFieldsJson);
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  SyncConflictRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncConflictRowsCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      localOperation: Value(localOperation),
      localPayloadJson: localPayloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(localPayloadJson),
      remoteOperation: Value(remoteOperation),
      remotePayloadJson: remotePayloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(remotePayloadJson),
      remoteServerVersion: Value(remoteServerVersion),
      conflictingFieldsJson: Value(conflictingFieldsJson),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory SyncConflictRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncConflictRow(
      id: serializer.fromJson<String>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      localOperation: serializer.fromJson<String>(json['localOperation']),
      localPayloadJson: serializer.fromJson<String?>(json['localPayloadJson']),
      remoteOperation: serializer.fromJson<String>(json['remoteOperation']),
      remotePayloadJson: serializer.fromJson<String?>(
        json['remotePayloadJson'],
      ),
      remoteServerVersion: serializer.fromJson<int>(
        json['remoteServerVersion'],
      ),
      conflictingFieldsJson: serializer.fromJson<String>(
        json['conflictingFieldsJson'],
      ),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'localOperation': serializer.toJson<String>(localOperation),
      'localPayloadJson': serializer.toJson<String?>(localPayloadJson),
      'remoteOperation': serializer.toJson<String>(remoteOperation),
      'remotePayloadJson': serializer.toJson<String?>(remotePayloadJson),
      'remoteServerVersion': serializer.toJson<int>(remoteServerVersion),
      'conflictingFieldsJson': serializer.toJson<String>(conflictingFieldsJson),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  SyncConflictRow copyWith({
    String? id,
    String? entityType,
    String? entityId,
    String? localOperation,
    Value<String?> localPayloadJson = const Value.absent(),
    String? remoteOperation,
    Value<String?> remotePayloadJson = const Value.absent(),
    int? remoteServerVersion,
    String? conflictingFieldsJson,
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => SyncConflictRow(
    id: id ?? this.id,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    localOperation: localOperation ?? this.localOperation,
    localPayloadJson: localPayloadJson.present
        ? localPayloadJson.value
        : this.localPayloadJson,
    remoteOperation: remoteOperation ?? this.remoteOperation,
    remotePayloadJson: remotePayloadJson.present
        ? remotePayloadJson.value
        : this.remotePayloadJson,
    remoteServerVersion: remoteServerVersion ?? this.remoteServerVersion,
    conflictingFieldsJson: conflictingFieldsJson ?? this.conflictingFieldsJson,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  SyncConflictRow copyWithCompanion(SyncConflictRowsCompanion data) {
    return SyncConflictRow(
      id: data.id.present ? data.id.value : this.id,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      localOperation: data.localOperation.present
          ? data.localOperation.value
          : this.localOperation,
      localPayloadJson: data.localPayloadJson.present
          ? data.localPayloadJson.value
          : this.localPayloadJson,
      remoteOperation: data.remoteOperation.present
          ? data.remoteOperation.value
          : this.remoteOperation,
      remotePayloadJson: data.remotePayloadJson.present
          ? data.remotePayloadJson.value
          : this.remotePayloadJson,
      remoteServerVersion: data.remoteServerVersion.present
          ? data.remoteServerVersion.value
          : this.remoteServerVersion,
      conflictingFieldsJson: data.conflictingFieldsJson.present
          ? data.conflictingFieldsJson.value
          : this.conflictingFieldsJson,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localOperation: $localOperation, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('remoteOperation: $remoteOperation, ')
          ..write('remotePayloadJson: $remotePayloadJson, ')
          ..write('remoteServerVersion: $remoteServerVersion, ')
          ..write('conflictingFieldsJson: $conflictingFieldsJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityType,
    entityId,
    localOperation,
    localPayloadJson,
    remoteOperation,
    remotePayloadJson,
    remoteServerVersion,
    conflictingFieldsJson,
    detectedAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncConflictRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.localOperation == this.localOperation &&
          other.localPayloadJson == this.localPayloadJson &&
          other.remoteOperation == this.remoteOperation &&
          other.remotePayloadJson == this.remotePayloadJson &&
          other.remoteServerVersion == this.remoteServerVersion &&
          other.conflictingFieldsJson == this.conflictingFieldsJson &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt);
}

class SyncConflictRowsCompanion extends UpdateCompanion<SyncConflictRow> {
  final Value<String> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> localOperation;
  final Value<String?> localPayloadJson;
  final Value<String> remoteOperation;
  final Value<String?> remotePayloadJson;
  final Value<int> remoteServerVersion;
  final Value<String> conflictingFieldsJson;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const SyncConflictRowsCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.localOperation = const Value.absent(),
    this.localPayloadJson = const Value.absent(),
    this.remoteOperation = const Value.absent(),
    this.remotePayloadJson = const Value.absent(),
    this.remoteServerVersion = const Value.absent(),
    this.conflictingFieldsJson = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncConflictRowsCompanion.insert({
    required String id,
    required String entityType,
    required String entityId,
    required String localOperation,
    this.localPayloadJson = const Value.absent(),
    required String remoteOperation,
    this.remotePayloadJson = const Value.absent(),
    required int remoteServerVersion,
    required String conflictingFieldsJson,
    required DateTime detectedAt,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityType = Value(entityType),
       entityId = Value(entityId),
       localOperation = Value(localOperation),
       remoteOperation = Value(remoteOperation),
       remoteServerVersion = Value(remoteServerVersion),
       conflictingFieldsJson = Value(conflictingFieldsJson),
       detectedAt = Value(detectedAt);
  static Insertable<SyncConflictRow> custom({
    Expression<String>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? localOperation,
    Expression<String>? localPayloadJson,
    Expression<String>? remoteOperation,
    Expression<String>? remotePayloadJson,
    Expression<int>? remoteServerVersion,
    Expression<String>? conflictingFieldsJson,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (localOperation != null) 'local_operation': localOperation,
      if (localPayloadJson != null) 'local_payload_json': localPayloadJson,
      if (remoteOperation != null) 'remote_operation': remoteOperation,
      if (remotePayloadJson != null) 'remote_payload_json': remotePayloadJson,
      if (remoteServerVersion != null)
        'remote_server_version': remoteServerVersion,
      if (conflictingFieldsJson != null)
        'conflicting_fields_json': conflictingFieldsJson,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncConflictRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? localOperation,
    Value<String?>? localPayloadJson,
    Value<String>? remoteOperation,
    Value<String?>? remotePayloadJson,
    Value<int>? remoteServerVersion,
    Value<String>? conflictingFieldsJson,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return SyncConflictRowsCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localOperation: localOperation ?? this.localOperation,
      localPayloadJson: localPayloadJson ?? this.localPayloadJson,
      remoteOperation: remoteOperation ?? this.remoteOperation,
      remotePayloadJson: remotePayloadJson ?? this.remotePayloadJson,
      remoteServerVersion: remoteServerVersion ?? this.remoteServerVersion,
      conflictingFieldsJson:
          conflictingFieldsJson ?? this.conflictingFieldsJson,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (localOperation.present) {
      map['local_operation'] = Variable<String>(localOperation.value);
    }
    if (localPayloadJson.present) {
      map['local_payload_json'] = Variable<String>(localPayloadJson.value);
    }
    if (remoteOperation.present) {
      map['remote_operation'] = Variable<String>(remoteOperation.value);
    }
    if (remotePayloadJson.present) {
      map['remote_payload_json'] = Variable<String>(remotePayloadJson.value);
    }
    if (remoteServerVersion.present) {
      map['remote_server_version'] = Variable<int>(remoteServerVersion.value);
    }
    if (conflictingFieldsJson.present) {
      map['conflicting_fields_json'] = Variable<String>(
        conflictingFieldsJson.value,
      );
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncConflictRowsCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('localOperation: $localOperation, ')
          ..write('localPayloadJson: $localPayloadJson, ')
          ..write('remoteOperation: $remoteOperation, ')
          ..write('remotePayloadJson: $remotePayloadJson, ')
          ..write('remoteServerVersion: $remoteServerVersion, ')
          ..write('conflictingFieldsJson: $conflictingFieldsJson, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardDefinitionsTable cardDefinitions = $CardDefinitionsTable(
    this,
  );
  late final $CardItemsTable cardItems = $CardItemsTable(this);
  late final $CardImagesTable cardImages = $CardImagesTable(this);
  late final $CardSetsTable cardSets = $CardSetsTable(this);
  late final $CardSetMembersTable cardSetMembers = $CardSetMembersTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $CardTagsTable cardTags = $CardTagsTable(this);
  late final $SeriesRecordsTable seriesRecords = $SeriesRecordsTable(this);
  late final $SeriesCardsTable seriesCards = $SeriesCardsTable(this);
  late final $SeriesSetsTable seriesSets = $SeriesSetsTable(this);
  late final $OrganizationFieldDefinitionsTable organizationFieldDefinitions =
      $OrganizationFieldDefinitionsTable(this);
  late final $OrganizationFieldValuesTable organizationFieldValues =
      $OrganizationFieldValuesTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PurchaseItemsTable purchaseItems = $PurchaseItemsTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final $RecycleBinSettingsRowsTable recycleBinSettingsRows =
      $RecycleBinSettingsRowsTable(this);
  late final $FileCleanupQueueEntriesTable fileCleanupQueueEntries =
      $FileCleanupQueueEntriesTable(this);
  late final $SyncSettingsRowsTable syncSettingsRows = $SyncSettingsRowsTable(
    this,
  );
  late final $SyncEntityStateRowsTable syncEntityStateRows =
      $SyncEntityStateRowsTable(this);
  late final $SyncOutboxEntriesTable syncOutboxEntries =
      $SyncOutboxEntriesTable(this);
  late final $SyncConflictRowsTable syncConflictRows = $SyncConflictRowsTable(
    this,
  );
  late final Index idxCardDefinitionsDeletedAt = Index(
    'idx_card_definitions_deleted_at',
    'CREATE INDEX idx_card_definitions_deleted_at ON card_definitions (deleted_at)',
  );
  late final Index idxCardItemsDefinitionId = Index(
    'idx_card_items_definition_id',
    'CREATE INDEX idx_card_items_definition_id ON card_items (definition_id)',
  );
  late final Index idxCardItemsDeletedAt = Index(
    'idx_card_items_deleted_at',
    'CREATE INDEX idx_card_items_deleted_at ON card_items (deleted_at)',
  );
  late final Index idxCardItemsCreatedAt = Index(
    'idx_card_items_created_at',
    'CREATE INDEX idx_card_items_created_at ON card_items (created_at)',
  );
  late final Index idxCardImagesCardItemId = Index(
    'idx_card_images_card_item_id',
    'CREATE INDEX idx_card_images_card_item_id ON card_images (card_item_id)',
  );
  late final Index idxCardImagesSortOrder = Index(
    'idx_card_images_sort_order',
    'CREATE INDEX idx_card_images_sort_order ON card_images (sort_order)',
  );
  late final Index idxCardSetsCreatedAt = Index(
    'idx_card_sets_created_at',
    'CREATE INDEX idx_card_sets_created_at ON card_sets (created_at)',
  );
  late final Index idxCardSetsDeletedAt = Index(
    'idx_card_sets_deleted_at',
    'CREATE INDEX idx_card_sets_deleted_at ON card_sets (deleted_at)',
  );
  late final Index idxCardSetMembersSetId = Index(
    'idx_card_set_members_set_id',
    'CREATE INDEX idx_card_set_members_set_id ON card_set_members (set_id)',
  );
  late final Index idxCardSetMembersSetSort = Index(
    'idx_card_set_members_set_sort',
    'CREATE INDEX idx_card_set_members_set_sort ON card_set_members (set_id, sort_order)',
  );
  late final Index idxCardSetMembersDefinitionId = Index(
    'idx_card_set_members_definition_id',
    'CREATE INDEX idx_card_set_members_definition_id ON card_set_members (definition_id)',
  );
  late final Index idxTagsDeletedAt = Index(
    'idx_tags_deleted_at',
    'CREATE INDEX idx_tags_deleted_at ON tags (deleted_at)',
  );
  late final Index idxTagsUpdatedAt = Index(
    'idx_tags_updated_at',
    'CREATE INDEX idx_tags_updated_at ON tags (updated_at)',
  );
  late final Index idxCardTagsTagId = Index(
    'idx_card_tags_tag_id',
    'CREATE INDEX idx_card_tags_tag_id ON card_tags (tag_id)',
  );
  late final Index idxCardTagsDefinitionId = Index(
    'idx_card_tags_definition_id',
    'CREATE INDEX idx_card_tags_definition_id ON card_tags (definition_id)',
  );
  late final Index idxSeriesDeletedAt = Index(
    'idx_series_deleted_at',
    'CREATE INDEX idx_series_deleted_at ON series_records (deleted_at)',
  );
  late final Index idxSeriesUpdatedAt = Index(
    'idx_series_updated_at',
    'CREATE INDEX idx_series_updated_at ON series_records (updated_at)',
  );
  late final Index idxSeriesCardsDefinitionId = Index(
    'idx_series_cards_definition_id',
    'CREATE INDEX idx_series_cards_definition_id ON series_cards (definition_id)',
  );
  late final Index idxSeriesSetsSetId = Index(
    'idx_series_sets_set_id',
    'CREATE INDEX idx_series_sets_set_id ON series_sets (set_id)',
  );
  late final Index idxCustomFieldsDeletedAt = Index(
    'idx_custom_fields_deleted_at',
    'CREATE INDEX idx_custom_fields_deleted_at ON custom_field_definitions (deleted_at)',
  );
  late final Index idxCustomFieldValuesDefinitionId = Index(
    'idx_custom_field_values_definition_id',
    'CREATE INDEX idx_custom_field_values_definition_id ON custom_field_values (definition_id)',
  );
  late final Index idxPurchasesPurchasedAt = Index(
    'idx_purchases_purchased_at',
    'CREATE INDEX idx_purchases_purchased_at ON purchases (purchased_at)',
  );
  late final Index idxPurchasesCurrency = Index(
    'idx_purchases_currency',
    'CREATE INDEX idx_purchases_currency ON purchases (currency)',
  );
  late final Index idxPurchasesAdjustmentOfId = Index(
    'idx_purchases_adjustment_of_id',
    'CREATE INDEX idx_purchases_adjustment_of_id ON purchases (adjustment_of_id)',
  );
  late final Index idxPurchaseItemsTarget = Index(
    'idx_purchase_items_target',
    'CREATE INDEX idx_purchase_items_target ON purchase_items (target_type, target_id)',
  );
  late final Index idxExchangeRatesLookup = Index(
    'idx_exchange_rates_lookup',
    'CREATE INDEX idx_exchange_rates_lookup ON exchange_rates (base_currency, quote_currency, rate_date)',
  );
  late final Index idxFileCleanupCreatedAt = Index(
    'idx_file_cleanup_created_at',
    'CREATE INDEX idx_file_cleanup_created_at ON file_cleanup_queue (created_at)',
  );
  late final Index idxSyncOutboxEntity = Index(
    'idx_sync_outbox_entity',
    'CREATE UNIQUE INDEX idx_sync_outbox_entity ON sync_outbox (entity_type, entity_id)',
  );
  late final Index idxSyncOutboxDue = Index(
    'idx_sync_outbox_due',
    'CREATE INDEX idx_sync_outbox_due ON sync_outbox (next_attempt_at, created_at)',
  );
  late final Index idxSyncConflictsOpen = Index(
    'idx_sync_conflicts_open',
    'CREATE INDEX idx_sync_conflicts_open ON sync_conflicts (resolved_at, detected_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cardDefinitions,
    cardItems,
    cardImages,
    cardSets,
    cardSetMembers,
    tags,
    cardTags,
    seriesRecords,
    seriesCards,
    seriesSets,
    organizationFieldDefinitions,
    organizationFieldValues,
    purchases,
    purchaseItems,
    exchangeRates,
    recycleBinSettingsRows,
    fileCleanupQueueEntries,
    syncSettingsRows,
    syncEntityStateRows,
    syncOutboxEntries,
    syncConflictRows,
    idxCardDefinitionsDeletedAt,
    idxCardItemsDefinitionId,
    idxCardItemsDeletedAt,
    idxCardItemsCreatedAt,
    idxCardImagesCardItemId,
    idxCardImagesSortOrder,
    idxCardSetsCreatedAt,
    idxCardSetsDeletedAt,
    idxCardSetMembersSetId,
    idxCardSetMembersSetSort,
    idxCardSetMembersDefinitionId,
    idxTagsDeletedAt,
    idxTagsUpdatedAt,
    idxCardTagsTagId,
    idxCardTagsDefinitionId,
    idxSeriesDeletedAt,
    idxSeriesUpdatedAt,
    idxSeriesCardsDefinitionId,
    idxSeriesSetsSetId,
    idxCustomFieldsDeletedAt,
    idxCustomFieldValuesDefinitionId,
    idxPurchasesPurchasedAt,
    idxPurchasesCurrency,
    idxPurchasesAdjustmentOfId,
    idxPurchaseItemsTarget,
    idxExchangeRatesLookup,
    idxFileCleanupCreatedAt,
    idxSyncOutboxEntity,
    idxSyncOutboxDue,
    idxSyncConflictsOpen,
  ];
}

typedef $$CardDefinitionsTableCreateCompanionBuilder =
    CardDefinitionsCompanion Function({
      required String id,
      required String name,
      Value<String?> city,
      Value<String?> issuer,
      Value<String?> issuedAt,
      Value<String?> code,
      Value<String?> notes,
      Value<String?> cardType,
      Value<bool> needsCompletion,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CardDefinitionsTableUpdateCompanionBuilder =
    CardDefinitionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> city,
      Value<String?> issuer,
      Value<String?> issuedAt,
      Value<String?> code,
      Value<String?> notes,
      Value<String?> cardType,
      Value<bool> needsCompletion,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CardDefinitionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CardDefinitionsTable, CardDefinition> {
  $$CardDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$CardItemsTable, List<CardItem>>
  _cardItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardItems,
    aliasName: 'card_definitions__id__card_items__definition_id',
  );

  $$CardItemsTableProcessedTableManager get cardItemsRefs {
    final manager = $$CardItemsTableTableManager(
      $_db,
      $_db.cardItems,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardSetMembersTable, List<CardSetMember>>
  _cardSetMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardSetMembers,
    aliasName: 'card_definitions__id__card_set_members__definition_id',
  );

  $$CardSetMembersTableProcessedTableManager get cardSetMembersRefs {
    final manager = $$CardSetMembersTableTableManager(
      $_db,
      $_db.cardSetMembers,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardSetMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CardTagsTable, List<CardTag>> _cardTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cardTags,
    aliasName: 'card_definitions__id__card_tags__definition_id',
  );

  $$CardTagsTableProcessedTableManager get cardTagsRefs {
    final manager = $$CardTagsTableTableManager(
      $_db,
      $_db.cardTags,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SeriesCardsTable, List<SeriesCard>>
  _seriesCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesCards,
    aliasName: 'card_definitions__id__series_cards__definition_id',
  );

  $$SeriesCardsTableProcessedTableManager get seriesCardsRefs {
    final manager = $$SeriesCardsTableTableManager(
      $_db,
      $_db.seriesCards,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $OrganizationFieldValuesTable,
    List<OrganizationFieldValue>
  >
  _organizationFieldValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.organizationFieldValues,
        aliasName: 'card_definitions__id__custom_field_values__definition_id',
      );

  $$OrganizationFieldValuesTableProcessedTableManager
  get organizationFieldValuesRefs {
    final manager = $$OrganizationFieldValuesTableTableManager(
      $_db,
      $_db.organizationFieldValues,
    ).filter((f) => f.definitionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _organizationFieldValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CardDefinitionsTable> {
  $$CardDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsCompletion => $composableBuilder(
    column: $table.needsCompletion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardItemsRefs(
    Expression<bool> Function($$CardItemsTableFilterComposer f) f,
  ) {
    final $$CardItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardItems,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardItemsTableFilterComposer(
            $db: $db,
            $table: $db.cardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardSetMembersRefs(
    Expression<bool> Function($$CardSetMembersTableFilterComposer f) f,
  ) {
    final $$CardSetMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSetMembers,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetMembersTableFilterComposer(
            $db: $db,
            $table: $db.cardSetMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cardTagsRefs(
    Expression<bool> Function($$CardTagsTableFilterComposer f) f,
  ) {
    final $$CardTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableFilterComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> seriesCardsRefs(
    Expression<bool> Function($$SeriesCardsTableFilterComposer f) f,
  ) {
    final $$SeriesCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesCards,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesCardsTableFilterComposer(
            $db: $db,
            $table: $db.seriesCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> organizationFieldValuesRefs(
    Expression<bool> Function($$OrganizationFieldValuesTableFilterComposer f) f,
  ) {
    final $$OrganizationFieldValuesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.organizationFieldValues,
          getReferencedColumn: (t) => t.definitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrganizationFieldValuesTableFilterComposer(
                $db: $db,
                $table: $db.organizationFieldValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CardDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardDefinitionsTable> {
  $$CardDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuer => $composableBuilder(
    column: $table.issuer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issuedAt => $composableBuilder(
    column: $table.issuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardType => $composableBuilder(
    column: $table.cardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsCompletion => $composableBuilder(
    column: $table.needsCompletion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardDefinitionsTable> {
  $$CardDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get issuer =>
      $composableBuilder(column: $table.issuer, builder: (column) => column);

  GeneratedColumn<String> get issuedAt =>
      $composableBuilder(column: $table.issuedAt, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get cardType =>
      $composableBuilder(column: $table.cardType, builder: (column) => column);

  GeneratedColumn<bool> get needsCompletion => $composableBuilder(
    column: $table.needsCompletion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> cardItemsRefs<T extends Object>(
    Expression<T> Function($$CardItemsTableAnnotationComposer a) f,
  ) {
    final $$CardItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardItems,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardSetMembersRefs<T extends Object>(
    Expression<T> Function($$CardSetMembersTableAnnotationComposer a) f,
  ) {
    final $$CardSetMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSetMembers,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.cardSetMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cardTagsRefs<T extends Object>(
    Expression<T> Function($$CardTagsTableAnnotationComposer a) f,
  ) {
    final $$CardTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> seriesCardsRefs<T extends Object>(
    Expression<T> Function($$SeriesCardsTableAnnotationComposer a) f,
  ) {
    final $$SeriesCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesCards,
      getReferencedColumn: (t) => t.definitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> organizationFieldValuesRefs<T extends Object>(
    Expression<T> Function($$OrganizationFieldValuesTableAnnotationComposer a)
    f,
  ) {
    final $$OrganizationFieldValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.organizationFieldValues,
          getReferencedColumn: (t) => t.definitionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrganizationFieldValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.organizationFieldValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CardDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardDefinitionsTable,
          CardDefinition,
          $$CardDefinitionsTableFilterComposer,
          $$CardDefinitionsTableOrderingComposer,
          $$CardDefinitionsTableAnnotationComposer,
          $$CardDefinitionsTableCreateCompanionBuilder,
          $$CardDefinitionsTableUpdateCompanionBuilder,
          (CardDefinition, $$CardDefinitionsTableReferences),
          CardDefinition,
          PrefetchHooks Function({
            bool cardItemsRefs,
            bool cardSetMembersRefs,
            bool cardTagsRefs,
            bool seriesCardsRefs,
            bool organizationFieldValuesRefs,
          })
        > {
  $$CardDefinitionsTableTableManager(
    _$AppDatabase db,
    $CardDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardDefinitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardDefinitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> issuer = const Value.absent(),
                Value<String?> issuedAt = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> cardType = const Value.absent(),
                Value<bool> needsCompletion = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardDefinitionsCompanion(
                id: id,
                name: name,
                city: city,
                issuer: issuer,
                issuedAt: issuedAt,
                code: code,
                notes: notes,
                cardType: cardType,
                needsCompletion: needsCompletion,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> city = const Value.absent(),
                Value<String?> issuer = const Value.absent(),
                Value<String?> issuedAt = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> cardType = const Value.absent(),
                Value<bool> needsCompletion = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardDefinitionsCompanion.insert(
                id: id,
                name: name,
                city: city,
                issuer: issuer,
                issuedAt: issuedAt,
                code: code,
                notes: notes,
                cardType: cardType,
                needsCompletion: needsCompletion,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cardItemsRefs = false,
                cardSetMembersRefs = false,
                cardTagsRefs = false,
                seriesCardsRefs = false,
                organizationFieldValuesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardItemsRefs) db.cardItems,
                    if (cardSetMembersRefs) db.cardSetMembers,
                    if (cardTagsRefs) db.cardTags,
                    if (seriesCardsRefs) db.seriesCards,
                    if (organizationFieldValuesRefs) db.organizationFieldValues,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardItemsRefs)
                        await $_getPrefetchedData<
                          CardDefinition,
                          $CardDefinitionsTable,
                          CardItem
                        >(
                          currentTable: table,
                          referencedTable: $$CardDefinitionsTableReferences
                              ._cardItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.definitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardSetMembersRefs)
                        await $_getPrefetchedData<
                          CardDefinition,
                          $CardDefinitionsTable,
                          CardSetMember
                        >(
                          currentTable: table,
                          referencedTable: $$CardDefinitionsTableReferences
                              ._cardSetMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardSetMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.definitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (cardTagsRefs)
                        await $_getPrefetchedData<
                          CardDefinition,
                          $CardDefinitionsTable,
                          CardTag
                        >(
                          currentTable: table,
                          referencedTable: $$CardDefinitionsTableReferences
                              ._cardTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.definitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (seriesCardsRefs)
                        await $_getPrefetchedData<
                          CardDefinition,
                          $CardDefinitionsTable,
                          SeriesCard
                        >(
                          currentTable: table,
                          referencedTable: $$CardDefinitionsTableReferences
                              ._seriesCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.definitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (organizationFieldValuesRefs)
                        await $_getPrefetchedData<
                          CardDefinition,
                          $CardDefinitionsTable,
                          OrganizationFieldValue
                        >(
                          currentTable: table,
                          referencedTable: $$CardDefinitionsTableReferences
                              ._organizationFieldValuesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardDefinitionsTableReferences(
                                db,
                                table,
                                p0,
                              ).organizationFieldValuesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.definitionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardDefinitionsTable,
      CardDefinition,
      $$CardDefinitionsTableFilterComposer,
      $$CardDefinitionsTableOrderingComposer,
      $$CardDefinitionsTableAnnotationComposer,
      $$CardDefinitionsTableCreateCompanionBuilder,
      $$CardDefinitionsTableUpdateCompanionBuilder,
      (CardDefinition, $$CardDefinitionsTableReferences),
      CardDefinition,
      PrefetchHooks Function({
        bool cardItemsRefs,
        bool cardSetMembersRefs,
        bool cardTagsRefs,
        bool seriesCardsRefs,
        bool organizationFieldValuesRefs,
      })
    >;
typedef $$CardItemsTableCreateCompanionBuilder =
    CardItemsCompanion Function({
      required String id,
      required String definitionId,
      Value<int> quantity,
      Value<DateTime?> acquiredAt,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CardItemsTableUpdateCompanionBuilder =
    CardItemsCompanion Function({
      Value<String> id,
      Value<String> definitionId,
      Value<int> quantity,
      Value<DateTime?> acquiredAt,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CardItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CardItemsTable, CardItem> {
  $$CardItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardDefinitionsTable _definitionIdTable(_$AppDatabase db) => db
      .cardDefinitions
      .createAlias('card_items__definition_id__card_definitions__id');

  $$CardDefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<String>('definition_id')!;

    final manager = $$CardDefinitionsTableTableManager(
      $_db,
      $_db.cardDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardImagesTable, List<CardImage>>
  _cardImagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardImages,
    aliasName: 'card_items__id__card_images__card_item_id',
  );

  $$CardImagesTableProcessedTableManager get cardImagesRefs {
    final manager = $$CardImagesTableTableManager(
      $_db,
      $_db.cardImages,
    ).filter((f) => f.cardItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardImagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CardItemsTable> {
  $$CardItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardDefinitionsTableFilterComposer get definitionId {
    final $$CardDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardImagesRefs(
    Expression<bool> Function($$CardImagesTableFilterComposer f) f,
  ) {
    final $$CardImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardImages,
      getReferencedColumn: (t) => t.cardItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardImagesTableFilterComposer(
            $db: $db,
            $table: $db.cardImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardItemsTable> {
  $$CardItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardDefinitionsTableOrderingComposer get definitionId {
    final $$CardDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardItemsTable> {
  $$CardItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get acquiredAt => $composableBuilder(
    column: $table.acquiredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CardDefinitionsTableAnnotationComposer get definitionId {
    final $$CardDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardImagesRefs<T extends Object>(
    Expression<T> Function($$CardImagesTableAnnotationComposer a) f,
  ) {
    final $$CardImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardImages,
      getReferencedColumn: (t) => t.cardItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardItemsTable,
          CardItem,
          $$CardItemsTableFilterComposer,
          $$CardItemsTableOrderingComposer,
          $$CardItemsTableAnnotationComposer,
          $$CardItemsTableCreateCompanionBuilder,
          $$CardItemsTableUpdateCompanionBuilder,
          (CardItem, $$CardItemsTableReferences),
          CardItem,
          PrefetchHooks Function({bool definitionId, bool cardImagesRefs})
        > {
  $$CardItemsTableTableManager(_$AppDatabase db, $CardItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardItemsCompanion(
                id: id,
                definitionId: definitionId,
                quantity: quantity,
                acquiredAt: acquiredAt,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String definitionId,
                Value<int> quantity = const Value.absent(),
                Value<DateTime?> acquiredAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardItemsCompanion.insert(
                id: id,
                definitionId: definitionId,
                quantity: quantity,
                acquiredAt: acquiredAt,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({definitionId = false, cardImagesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (cardImagesRefs) db.cardImages],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (definitionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.definitionId,
                                    referencedTable: $$CardItemsTableReferences
                                        ._definitionIdTable(db),
                                    referencedColumn: $$CardItemsTableReferences
                                        ._definitionIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardImagesRefs)
                        await $_getPrefetchedData<
                          CardItem,
                          $CardItemsTable,
                          CardImage
                        >(
                          currentTable: table,
                          referencedTable: $$CardItemsTableReferences
                              ._cardImagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardImagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardItemsTable,
      CardItem,
      $$CardItemsTableFilterComposer,
      $$CardItemsTableOrderingComposer,
      $$CardItemsTableAnnotationComposer,
      $$CardItemsTableCreateCompanionBuilder,
      $$CardItemsTableUpdateCompanionBuilder,
      (CardItem, $$CardItemsTableReferences),
      CardItem,
      PrefetchHooks Function({bool definitionId, bool cardImagesRefs})
    >;
typedef $$CardImagesTableCreateCompanionBuilder =
    CardImagesCompanion Function({
      required String id,
      required String cardItemId,
      required CardImageKind kind,
      required String relativePath,
      Value<String?> derivedRelativePath,
      Value<int> sortOrder,
      Value<bool> isCover,
      required String checksum,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CardImagesTableUpdateCompanionBuilder =
    CardImagesCompanion Function({
      Value<String> id,
      Value<String> cardItemId,
      Value<CardImageKind> kind,
      Value<String> relativePath,
      Value<String?> derivedRelativePath,
      Value<int> sortOrder,
      Value<bool> isCover,
      Value<String> checksum,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CardImagesTableReferences
    extends BaseReferences<_$AppDatabase, $CardImagesTable, CardImage> {
  $$CardImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardItemsTable _cardItemIdTable(_$AppDatabase db) =>
      db.cardItems.createAlias('card_images__card_item_id__card_items__id');

  $$CardItemsTableProcessedTableManager get cardItemId {
    final $_column = $_itemColumn<String>('card_item_id')!;

    final manager = $$CardItemsTableTableManager(
      $_db,
      $_db.cardItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardSetsTable, List<CardSet>> _cardSetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cardSets,
    aliasName: 'card_images__id__card_sets__cover_image_id',
  );

  $$CardSetsTableProcessedTableManager get cardSetsRefs {
    final manager = $$CardSetsTableTableManager(
      $_db,
      $_db.cardSets,
    ).filter((f) => f.coverImageId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardImagesTableFilterComposer
    extends Composer<_$AppDatabase, $CardImagesTable> {
  $$CardImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CardImageKind, CardImageKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get derivedRelativePath => $composableBuilder(
    column: $table.derivedRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCover => $composableBuilder(
    column: $table.isCover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardItemsTableFilterComposer get cardItemId {
    final $$CardItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardItemId,
      referencedTable: $db.cardItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardItemsTableFilterComposer(
            $db: $db,
            $table: $db.cardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardSetsRefs(
    Expression<bool> Function($$CardSetsTableFilterComposer f) f,
  ) {
    final $$CardSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.coverImageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableFilterComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardImagesTable> {
  $$CardImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get derivedRelativePath => $composableBuilder(
    column: $table.derivedRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCover => $composableBuilder(
    column: $table.isCover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardItemsTableOrderingComposer get cardItemId {
    final $$CardItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardItemId,
      referencedTable: $db.cardItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardItemsTableOrderingComposer(
            $db: $db,
            $table: $db.cardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardImagesTable> {
  $$CardImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CardImageKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get derivedRelativePath => $composableBuilder(
    column: $table.derivedRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isCover =>
      $composableBuilder(column: $table.isCover, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CardItemsTableAnnotationComposer get cardItemId {
    final $$CardItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardItemId,
      referencedTable: $db.cardItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardSetsRefs<T extends Object>(
    Expression<T> Function($$CardSetsTableAnnotationComposer a) f,
  ) {
    final $$CardSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.coverImageId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardImagesTable,
          CardImage,
          $$CardImagesTableFilterComposer,
          $$CardImagesTableOrderingComposer,
          $$CardImagesTableAnnotationComposer,
          $$CardImagesTableCreateCompanionBuilder,
          $$CardImagesTableUpdateCompanionBuilder,
          (CardImage, $$CardImagesTableReferences),
          CardImage,
          PrefetchHooks Function({bool cardItemId, bool cardSetsRefs})
        > {
  $$CardImagesTableTableManager(_$AppDatabase db, $CardImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> cardItemId = const Value.absent(),
                Value<CardImageKind> kind = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String?> derivedRelativePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isCover = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardImagesCompanion(
                id: id,
                cardItemId: cardItemId,
                kind: kind,
                relativePath: relativePath,
                derivedRelativePath: derivedRelativePath,
                sortOrder: sortOrder,
                isCover: isCover,
                checksum: checksum,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardItemId,
                required CardImageKind kind,
                required String relativePath,
                Value<String?> derivedRelativePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isCover = const Value.absent(),
                required String checksum,
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardImagesCompanion.insert(
                id: id,
                cardItemId: cardItemId,
                kind: kind,
                relativePath: relativePath,
                derivedRelativePath: derivedRelativePath,
                sortOrder: sortOrder,
                isCover: isCover,
                checksum: checksum,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardImagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cardItemId = false, cardSetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardSetsRefs) db.cardSets],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (cardItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cardItemId,
                                referencedTable: $$CardImagesTableReferences
                                    ._cardItemIdTable(db),
                                referencedColumn: $$CardImagesTableReferences
                                    ._cardItemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardSetsRefs)
                    await $_getPrefetchedData<
                      CardImage,
                      $CardImagesTable,
                      CardSet
                    >(
                      currentTable: table,
                      referencedTable: $$CardImagesTableReferences
                          ._cardSetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CardImagesTableReferences(
                            db,
                            table,
                            p0,
                          ).cardSetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.coverImageId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CardImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardImagesTable,
      CardImage,
      $$CardImagesTableFilterComposer,
      $$CardImagesTableOrderingComposer,
      $$CardImagesTableAnnotationComposer,
      $$CardImagesTableCreateCompanionBuilder,
      $$CardImagesTableUpdateCompanionBuilder,
      (CardImage, $$CardImagesTableReferences),
      CardImage,
      PrefetchHooks Function({bool cardItemId, bool cardSetsRefs})
    >;
typedef $$CardSetsTableCreateCompanionBuilder =
    CardSetsCompanion Function({
      required String id,
      required String name,
      Value<int?> expectedCount,
      required bool countKnown,
      Value<String?> issueInfo,
      Value<String?> notes,
      Value<String?> coverImageId,
      Value<String?> coverRelativePath,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CardSetsTableUpdateCompanionBuilder =
    CardSetsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int?> expectedCount,
      Value<bool> countKnown,
      Value<String?> issueInfo,
      Value<String?> notes,
      Value<String?> coverImageId,
      Value<String?> coverRelativePath,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CardSetsTableReferences
    extends BaseReferences<_$AppDatabase, $CardSetsTable, CardSet> {
  $$CardSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardImagesTable _coverImageIdTable(_$AppDatabase db) =>
      db.cardImages.createAlias('card_sets__cover_image_id__card_images__id');

  $$CardImagesTableProcessedTableManager? get coverImageId {
    final $_column = $_itemColumn<String>('cover_image_id');
    if ($_column == null) return null;
    final manager = $$CardImagesTableTableManager(
      $_db,
      $_db.cardImages,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_coverImageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CardSetMembersTable, List<CardSetMember>>
  _cardSetMembersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cardSetMembers,
    aliasName: 'card_sets__id__card_set_members__set_id',
  );

  $$CardSetMembersTableProcessedTableManager get cardSetMembersRefs {
    final manager = $$CardSetMembersTableTableManager(
      $_db,
      $_db.cardSetMembers,
    ).filter((f) => f.setId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardSetMembersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SeriesSetsTable, List<SeriesSet>>
  _seriesSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesSets,
    aliasName: 'card_sets__id__series_sets__set_id',
  );

  $$SeriesSetsTableProcessedTableManager get seriesSetsRefs {
    final manager = $$SeriesSetsTableTableManager(
      $_db,
      $_db.seriesSets,
    ).filter((f) => f.setId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardSetsTableFilterComposer
    extends Composer<_$AppDatabase, $CardSetsTable> {
  $$CardSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedCount => $composableBuilder(
    column: $table.expectedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get countKnown => $composableBuilder(
    column: $table.countKnown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get issueInfo => $composableBuilder(
    column: $table.issueInfo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverRelativePath => $composableBuilder(
    column: $table.coverRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardImagesTableFilterComposer get coverImageId {
    final $$CardImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.coverImageId,
      referencedTable: $db.cardImages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardImagesTableFilterComposer(
            $db: $db,
            $table: $db.cardImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cardSetMembersRefs(
    Expression<bool> Function($$CardSetMembersTableFilterComposer f) f,
  ) {
    final $$CardSetMembersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSetMembers,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetMembersTableFilterComposer(
            $db: $db,
            $table: $db.cardSetMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> seriesSetsRefs(
    Expression<bool> Function($$SeriesSetsTableFilterComposer f) f,
  ) {
    final $$SeriesSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSets,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSetsTableFilterComposer(
            $db: $db,
            $table: $db.seriesSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardSetsTable> {
  $$CardSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCount => $composableBuilder(
    column: $table.expectedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get countKnown => $composableBuilder(
    column: $table.countKnown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get issueInfo => $composableBuilder(
    column: $table.issueInfo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverRelativePath => $composableBuilder(
    column: $table.coverRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardImagesTableOrderingComposer get coverImageId {
    final $$CardImagesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.coverImageId,
      referencedTable: $db.cardImages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardImagesTableOrderingComposer(
            $db: $db,
            $table: $db.cardImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardSetsTable> {
  $$CardSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get expectedCount => $composableBuilder(
    column: $table.expectedCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get countKnown => $composableBuilder(
    column: $table.countKnown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get issueInfo =>
      $composableBuilder(column: $table.issueInfo, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get coverRelativePath => $composableBuilder(
    column: $table.coverRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CardImagesTableAnnotationComposer get coverImageId {
    final $$CardImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.coverImageId,
      referencedTable: $db.cardImages,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.cardImages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cardSetMembersRefs<T extends Object>(
    Expression<T> Function($$CardSetMembersTableAnnotationComposer a) f,
  ) {
    final $$CardSetMembersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardSetMembers,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetMembersTableAnnotationComposer(
            $db: $db,
            $table: $db.cardSetMembers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> seriesSetsRefs<T extends Object>(
    Expression<T> Function($$SeriesSetsTableAnnotationComposer a) f,
  ) {
    final $$SeriesSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSets,
      getReferencedColumn: (t) => t.setId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardSetsTable,
          CardSet,
          $$CardSetsTableFilterComposer,
          $$CardSetsTableOrderingComposer,
          $$CardSetsTableAnnotationComposer,
          $$CardSetsTableCreateCompanionBuilder,
          $$CardSetsTableUpdateCompanionBuilder,
          (CardSet, $$CardSetsTableReferences),
          CardSet,
          PrefetchHooks Function({
            bool coverImageId,
            bool cardSetMembersRefs,
            bool seriesSetsRefs,
          })
        > {
  $$CardSetsTableTableManager(_$AppDatabase db, $CardSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> expectedCount = const Value.absent(),
                Value<bool> countKnown = const Value.absent(),
                Value<String?> issueInfo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> coverImageId = const Value.absent(),
                Value<String?> coverRelativePath = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardSetsCompanion(
                id: id,
                name: name,
                expectedCount: expectedCount,
                countKnown: countKnown,
                issueInfo: issueInfo,
                notes: notes,
                coverImageId: coverImageId,
                coverRelativePath: coverRelativePath,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> expectedCount = const Value.absent(),
                required bool countKnown,
                Value<String?> issueInfo = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> coverImageId = const Value.absent(),
                Value<String?> coverRelativePath = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardSetsCompanion.insert(
                id: id,
                name: name,
                expectedCount: expectedCount,
                countKnown: countKnown,
                issueInfo: issueInfo,
                notes: notes,
                coverImageId: coverImageId,
                coverRelativePath: coverRelativePath,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                coverImageId = false,
                cardSetMembersRefs = false,
                seriesSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardSetMembersRefs) db.cardSetMembers,
                    if (seriesSetsRefs) db.seriesSets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (coverImageId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.coverImageId,
                                    referencedTable: $$CardSetsTableReferences
                                        ._coverImageIdTable(db),
                                    referencedColumn: $$CardSetsTableReferences
                                        ._coverImageIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cardSetMembersRefs)
                        await $_getPrefetchedData<
                          CardSet,
                          $CardSetsTable,
                          CardSetMember
                        >(
                          currentTable: table,
                          referencedTable: $$CardSetsTableReferences
                              ._cardSetMembersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardSetsTableReferences(
                                db,
                                table,
                                p0,
                              ).cardSetMembersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.setId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (seriesSetsRefs)
                        await $_getPrefetchedData<
                          CardSet,
                          $CardSetsTable,
                          SeriesSet
                        >(
                          currentTable: table,
                          referencedTable: $$CardSetsTableReferences
                              ._seriesSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardSetsTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.setId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardSetsTable,
      CardSet,
      $$CardSetsTableFilterComposer,
      $$CardSetsTableOrderingComposer,
      $$CardSetsTableAnnotationComposer,
      $$CardSetsTableCreateCompanionBuilder,
      $$CardSetsTableUpdateCompanionBuilder,
      (CardSet, $$CardSetsTableReferences),
      CardSet,
      PrefetchHooks Function({
        bool coverImageId,
        bool cardSetMembersRefs,
        bool seriesSetsRefs,
      })
    >;
typedef $$CardSetMembersTableCreateCompanionBuilder =
    CardSetMembersCompanion Function({
      required String id,
      required String setId,
      required String definitionId,
      Value<String?> memberNo,
      Value<bool> required,
      Value<int> sortOrder,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CardSetMembersTableUpdateCompanionBuilder =
    CardSetMembersCompanion Function({
      Value<String> id,
      Value<String> setId,
      Value<String> definitionId,
      Value<String?> memberNo,
      Value<bool> required,
      Value<int> sortOrder,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CardSetMembersTableReferences
    extends BaseReferences<_$AppDatabase, $CardSetMembersTable, CardSetMember> {
  $$CardSetMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CardSetsTable _setIdTable(_$AppDatabase db) =>
      db.cardSets.createAlias('card_set_members__set_id__card_sets__id');

  $$CardSetsTableProcessedTableManager get setId {
    final $_column = $_itemColumn<String>('set_id')!;

    final manager = $$CardSetsTableTableManager(
      $_db,
      $_db.cardSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CardDefinitionsTable _definitionIdTable(_$AppDatabase db) => db
      .cardDefinitions
      .createAlias('card_set_members__definition_id__card_definitions__id');

  $$CardDefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<String>('definition_id')!;

    final manager = $$CardDefinitionsTableTableManager(
      $_db,
      $_db.cardDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardSetMembersTableFilterComposer
    extends Composer<_$AppDatabase, $CardSetMembersTable> {
  $$CardSetMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberNo => $composableBuilder(
    column: $table.memberNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CardSetsTableFilterComposer get setId {
    final $$CardSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableFilterComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableFilterComposer get definitionId {
    final $$CardDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardSetMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $CardSetMembersTable> {
  $$CardSetMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberNo => $composableBuilder(
    column: $table.memberNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get required => $composableBuilder(
    column: $table.required,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CardSetsTableOrderingComposer get setId {
    final $$CardSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableOrderingComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableOrderingComposer get definitionId {
    final $$CardDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardSetMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardSetMembersTable> {
  $$CardSetMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memberNo =>
      $composableBuilder(column: $table.memberNo, builder: (column) => column);

  GeneratedColumn<bool> get required =>
      $composableBuilder(column: $table.required, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CardSetsTableAnnotationComposer get setId {
    final $$CardSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableAnnotationComposer get definitionId {
    final $$CardDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardSetMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardSetMembersTable,
          CardSetMember,
          $$CardSetMembersTableFilterComposer,
          $$CardSetMembersTableOrderingComposer,
          $$CardSetMembersTableAnnotationComposer,
          $$CardSetMembersTableCreateCompanionBuilder,
          $$CardSetMembersTableUpdateCompanionBuilder,
          (CardSetMember, $$CardSetMembersTableReferences),
          CardSetMember,
          PrefetchHooks Function({bool setId, bool definitionId})
        > {
  $$CardSetMembersTableTableManager(
    _$AppDatabase db,
    $CardSetMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardSetMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardSetMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardSetMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> setId = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<String?> memberNo = const Value.absent(),
                Value<bool> required = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardSetMembersCompanion(
                id: id,
                setId: setId,
                definitionId: definitionId,
                memberNo: memberNo,
                required: required,
                sortOrder: sortOrder,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String setId,
                required String definitionId,
                Value<String?> memberNo = const Value.absent(),
                Value<bool> required = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardSetMembersCompanion.insert(
                id: id,
                setId: setId,
                definitionId: definitionId,
                memberNo: memberNo,
                required: required,
                sortOrder: sortOrder,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardSetMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({setId = false, definitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (setId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.setId,
                                referencedTable: $$CardSetMembersTableReferences
                                    ._setIdTable(db),
                                referencedColumn:
                                    $$CardSetMembersTableReferences
                                        ._setIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (definitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.definitionId,
                                referencedTable: $$CardSetMembersTableReferences
                                    ._definitionIdTable(db),
                                referencedColumn:
                                    $$CardSetMembersTableReferences
                                        ._definitionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardSetMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardSetMembersTable,
      CardSetMember,
      $$CardSetMembersTableFilterComposer,
      $$CardSetMembersTableOrderingComposer,
      $$CardSetMembersTableAnnotationComposer,
      $$CardSetMembersTableCreateCompanionBuilder,
      $$CardSetMembersTableUpdateCompanionBuilder,
      (CardSetMember, $$CardSetMembersTableReferences),
      CardSetMember,
      PrefetchHooks Function({bool setId, bool definitionId})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      required String normalizedName,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardTagsTable, List<CardTag>> _cardTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cardTags,
    aliasName: 'tags__id__card_tags__tag_id',
  );

  $$CardTagsTableProcessedTableManager get cardTagsRefs {
    final manager = $$CardTagsTableTableManager(
      $_db,
      $_db.cardTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cardTagsRefs(
    Expression<bool> Function($$CardTagsTableFilterComposer f) f,
  ) {
    final $$CardTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableFilterComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> cardTagsRefs<T extends Object>(
    Expression<T> Function($$CardTagsTableAnnotationComposer a) f,
  ) {
    final $$CardTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cardTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool cardTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedName,
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({cardTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardTagsRefs) db.cardTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, CardTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._cardTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).cardTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool cardTagsRefs})
    >;
typedef $$CardTagsTableCreateCompanionBuilder =
    CardTagsCompanion Function({
      required String tagId,
      required String definitionId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CardTagsTableUpdateCompanionBuilder =
    CardTagsCompanion Function({
      Value<String> tagId,
      Value<String> definitionId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CardTagsTableReferences
    extends BaseReferences<_$AppDatabase, $CardTagsTable, CardTag> {
  $$CardTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('card_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CardDefinitionsTable _definitionIdTable(_$AppDatabase db) => db
      .cardDefinitions
      .createAlias('card_tags__definition_id__card_definitions__id');

  $$CardDefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<String>('definition_id')!;

    final manager = $$CardDefinitionsTableTableManager(
      $_db,
      $_db.cardDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CardTagsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTagsTable> {
  $$CardTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableFilterComposer get definitionId {
    final $$CardDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTagsTable> {
  $$CardTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableOrderingComposer get definitionId {
    final $$CardDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTagsTable> {
  $$CardTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableAnnotationComposer get definitionId {
    final $$CardDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CardTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTagsTable,
          CardTag,
          $$CardTagsTableFilterComposer,
          $$CardTagsTableOrderingComposer,
          $$CardTagsTableAnnotationComposer,
          $$CardTagsTableCreateCompanionBuilder,
          $$CardTagsTableUpdateCompanionBuilder,
          (CardTag, $$CardTagsTableReferences),
          CardTag,
          PrefetchHooks Function({bool tagId, bool definitionId})
        > {
  $$CardTagsTableTableManager(_$AppDatabase db, $CardTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tagId = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTagsCompanion(
                tagId: tagId,
                definitionId: definitionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tagId,
                required String definitionId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardTagsCompanion.insert(
                tagId: tagId,
                definitionId: definitionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CardTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tagId = false, definitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$CardTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$CardTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (definitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.definitionId,
                                referencedTable: $$CardTagsTableReferences
                                    ._definitionIdTable(db),
                                referencedColumn: $$CardTagsTableReferences
                                    ._definitionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CardTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTagsTable,
      CardTag,
      $$CardTagsTableFilterComposer,
      $$CardTagsTableOrderingComposer,
      $$CardTagsTableAnnotationComposer,
      $$CardTagsTableCreateCompanionBuilder,
      $$CardTagsTableUpdateCompanionBuilder,
      (CardTag, $$CardTagsTableReferences),
      CardTag,
      PrefetchHooks Function({bool tagId, bool definitionId})
    >;
typedef $$SeriesRecordsTableCreateCompanionBuilder =
    SeriesRecordsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> coverRelativePath,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$SeriesRecordsTableUpdateCompanionBuilder =
    SeriesRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> coverRelativePath,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$SeriesRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $SeriesRecordsTable, SeriesRecord> {
  $$SeriesRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SeriesCardsTable, List<SeriesCard>>
  _seriesCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesCards,
    aliasName: 'series_records__id__series_cards__series_id',
  );

  $$SeriesCardsTableProcessedTableManager get seriesCardsRefs {
    final manager = $$SeriesCardsTableTableManager(
      $_db,
      $_db.seriesCards,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SeriesSetsTable, List<SeriesSet>>
  _seriesSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.seriesSets,
    aliasName: 'series_records__id__series_sets__series_id',
  );

  $$SeriesSetsTableProcessedTableManager get seriesSetsRefs {
    final manager = $$SeriesSetsTableTableManager(
      $_db,
      $_db.seriesSets,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_seriesSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SeriesRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesRecordsTable> {
  $$SeriesRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverRelativePath => $composableBuilder(
    column: $table.coverRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> seriesCardsRefs(
    Expression<bool> Function($$SeriesCardsTableFilterComposer f) f,
  ) {
    final $$SeriesCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesCards,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesCardsTableFilterComposer(
            $db: $db,
            $table: $db.seriesCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> seriesSetsRefs(
    Expression<bool> Function($$SeriesSetsTableFilterComposer f) f,
  ) {
    final $$SeriesSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSets,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSetsTableFilterComposer(
            $db: $db,
            $table: $db.seriesSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesRecordsTable> {
  $$SeriesRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverRelativePath => $composableBuilder(
    column: $table.coverRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesRecordsTable> {
  $$SeriesRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverRelativePath => $composableBuilder(
    column: $table.coverRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> seriesCardsRefs<T extends Object>(
    Expression<T> Function($$SeriesCardsTableAnnotationComposer a) f,
  ) {
    final $$SeriesCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesCards,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> seriesSetsRefs<T extends Object>(
    Expression<T> Function($$SeriesSetsTableAnnotationComposer a) f,
  ) {
    final $$SeriesSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.seriesSets,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SeriesRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesRecordsTable,
          SeriesRecord,
          $$SeriesRecordsTableFilterComposer,
          $$SeriesRecordsTableOrderingComposer,
          $$SeriesRecordsTableAnnotationComposer,
          $$SeriesRecordsTableCreateCompanionBuilder,
          $$SeriesRecordsTableUpdateCompanionBuilder,
          (SeriesRecord, $$SeriesRecordsTableReferences),
          SeriesRecord,
          PrefetchHooks Function({bool seriesCardsRefs, bool seriesSetsRefs})
        > {
  $$SeriesRecordsTableTableManager(_$AppDatabase db, $SeriesRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverRelativePath = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesRecordsCompanion(
                id: id,
                name: name,
                description: description,
                coverRelativePath: coverRelativePath,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> coverRelativePath = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesRecordsCompanion.insert(
                id: id,
                name: name,
                description: description,
                coverRelativePath: coverRelativePath,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SeriesRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({seriesCardsRefs = false, seriesSetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (seriesCardsRefs) db.seriesCards,
                    if (seriesSetsRefs) db.seriesSets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (seriesCardsRefs)
                        await $_getPrefetchedData<
                          SeriesRecord,
                          $SeriesRecordsTable,
                          SeriesCard
                        >(
                          currentTable: table,
                          referencedTable: $$SeriesRecordsTableReferences
                              ._seriesCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SeriesRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (seriesSetsRefs)
                        await $_getPrefetchedData<
                          SeriesRecord,
                          $SeriesRecordsTable,
                          SeriesSet
                        >(
                          currentTable: table,
                          referencedTable: $$SeriesRecordsTableReferences
                              ._seriesSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SeriesRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).seriesSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SeriesRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesRecordsTable,
      SeriesRecord,
      $$SeriesRecordsTableFilterComposer,
      $$SeriesRecordsTableOrderingComposer,
      $$SeriesRecordsTableAnnotationComposer,
      $$SeriesRecordsTableCreateCompanionBuilder,
      $$SeriesRecordsTableUpdateCompanionBuilder,
      (SeriesRecord, $$SeriesRecordsTableReferences),
      SeriesRecord,
      PrefetchHooks Function({bool seriesCardsRefs, bool seriesSetsRefs})
    >;
typedef $$SeriesCardsTableCreateCompanionBuilder =
    SeriesCardsCompanion Function({
      required String seriesId,
      required String definitionId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SeriesCardsTableUpdateCompanionBuilder =
    SeriesCardsCompanion Function({
      Value<String> seriesId,
      Value<String> definitionId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SeriesCardsTableReferences
    extends BaseReferences<_$AppDatabase, $SeriesCardsTable, SeriesCard> {
  $$SeriesCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeriesRecordsTable _seriesIdTable(_$AppDatabase db) => db
      .seriesRecords
      .createAlias('series_cards__series_id__series_records__id');

  $$SeriesRecordsTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<String>('series_id')!;

    final manager = $$SeriesRecordsTableTableManager(
      $_db,
      $_db.seriesRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CardDefinitionsTable _definitionIdTable(_$AppDatabase db) => db
      .cardDefinitions
      .createAlias('series_cards__definition_id__card_definitions__id');

  $$CardDefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<String>('definition_id')!;

    final manager = $$CardDefinitionsTableTableManager(
      $_db,
      $_db.cardDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SeriesCardsTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesCardsTable> {
  $$SeriesCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SeriesRecordsTableFilterComposer get seriesId {
    final $$SeriesRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesRecordsTableFilterComposer(
            $db: $db,
            $table: $db.seriesRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableFilterComposer get definitionId {
    final $$CardDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesCardsTable> {
  $$SeriesCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SeriesRecordsTableOrderingComposer get seriesId {
    final $$SeriesRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.seriesRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableOrderingComposer get definitionId {
    final $$CardDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesCardsTable> {
  $$SeriesCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SeriesRecordsTableAnnotationComposer get seriesId {
    final $$SeriesRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardDefinitionsTableAnnotationComposer get definitionId {
    final $$CardDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesCardsTable,
          SeriesCard,
          $$SeriesCardsTableFilterComposer,
          $$SeriesCardsTableOrderingComposer,
          $$SeriesCardsTableAnnotationComposer,
          $$SeriesCardsTableCreateCompanionBuilder,
          $$SeriesCardsTableUpdateCompanionBuilder,
          (SeriesCard, $$SeriesCardsTableReferences),
          SeriesCard,
          PrefetchHooks Function({bool seriesId, bool definitionId})
        > {
  $$SeriesCardsTableTableManager(_$AppDatabase db, $SeriesCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> seriesId = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesCardsCompanion(
                seriesId: seriesId,
                definitionId: definitionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String seriesId,
                required String definitionId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SeriesCardsCompanion.insert(
                seriesId: seriesId,
                definitionId: definitionId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SeriesCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false, definitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.seriesId,
                                referencedTable: $$SeriesCardsTableReferences
                                    ._seriesIdTable(db),
                                referencedColumn: $$SeriesCardsTableReferences
                                    ._seriesIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (definitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.definitionId,
                                referencedTable: $$SeriesCardsTableReferences
                                    ._definitionIdTable(db),
                                referencedColumn: $$SeriesCardsTableReferences
                                    ._definitionIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SeriesCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesCardsTable,
      SeriesCard,
      $$SeriesCardsTableFilterComposer,
      $$SeriesCardsTableOrderingComposer,
      $$SeriesCardsTableAnnotationComposer,
      $$SeriesCardsTableCreateCompanionBuilder,
      $$SeriesCardsTableUpdateCompanionBuilder,
      (SeriesCard, $$SeriesCardsTableReferences),
      SeriesCard,
      PrefetchHooks Function({bool seriesId, bool definitionId})
    >;
typedef $$SeriesSetsTableCreateCompanionBuilder =
    SeriesSetsCompanion Function({
      required String seriesId,
      required String setId,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SeriesSetsTableUpdateCompanionBuilder =
    SeriesSetsCompanion Function({
      Value<String> seriesId,
      Value<String> setId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SeriesSetsTableReferences
    extends BaseReferences<_$AppDatabase, $SeriesSetsTable, SeriesSet> {
  $$SeriesSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SeriesRecordsTable _seriesIdTable(_$AppDatabase db) => db
      .seriesRecords
      .createAlias('series_sets__series_id__series_records__id');

  $$SeriesRecordsTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<String>('series_id')!;

    final manager = $$SeriesRecordsTableTableManager(
      $_db,
      $_db.seriesRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CardSetsTable _setIdTable(_$AppDatabase db) =>
      db.cardSets.createAlias('series_sets__set_id__card_sets__id');

  $$CardSetsTableProcessedTableManager get setId {
    final $_column = $_itemColumn<String>('set_id')!;

    final manager = $$CardSetsTableTableManager(
      $_db,
      $_db.cardSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_setIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SeriesSetsTableFilterComposer
    extends Composer<_$AppDatabase, $SeriesSetsTable> {
  $$SeriesSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SeriesRecordsTableFilterComposer get seriesId {
    final $$SeriesRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesRecordsTableFilterComposer(
            $db: $db,
            $table: $db.seriesRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardSetsTableFilterComposer get setId {
    final $$CardSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableFilterComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeriesSetsTable> {
  $$SeriesSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SeriesRecordsTableOrderingComposer get seriesId {
    final $$SeriesRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.seriesRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardSetsTableOrderingComposer get setId {
    final $$CardSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableOrderingComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeriesSetsTable> {
  $$SeriesSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SeriesRecordsTableAnnotationComposer get seriesId {
    final $$SeriesRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.seriesRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SeriesRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.seriesRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardSetsTableAnnotationComposer get setId {
    final $$CardSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.setId,
      referencedTable: $db.cardSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SeriesSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeriesSetsTable,
          SeriesSet,
          $$SeriesSetsTableFilterComposer,
          $$SeriesSetsTableOrderingComposer,
          $$SeriesSetsTableAnnotationComposer,
          $$SeriesSetsTableCreateCompanionBuilder,
          $$SeriesSetsTableUpdateCompanionBuilder,
          (SeriesSet, $$SeriesSetsTableReferences),
          SeriesSet,
          PrefetchHooks Function({bool seriesId, bool setId})
        > {
  $$SeriesSetsTableTableManager(_$AppDatabase db, $SeriesSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> seriesId = const Value.absent(),
                Value<String> setId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeriesSetsCompanion(
                seriesId: seriesId,
                setId: setId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String seriesId,
                required String setId,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SeriesSetsCompanion.insert(
                seriesId: seriesId,
                setId: setId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SeriesSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false, setId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.seriesId,
                                referencedTable: $$SeriesSetsTableReferences
                                    ._seriesIdTable(db),
                                referencedColumn: $$SeriesSetsTableReferences
                                    ._seriesIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (setId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.setId,
                                referencedTable: $$SeriesSetsTableReferences
                                    ._setIdTable(db),
                                referencedColumn: $$SeriesSetsTableReferences
                                    ._setIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SeriesSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeriesSetsTable,
      SeriesSet,
      $$SeriesSetsTableFilterComposer,
      $$SeriesSetsTableOrderingComposer,
      $$SeriesSetsTableAnnotationComposer,
      $$SeriesSetsTableCreateCompanionBuilder,
      $$SeriesSetsTableUpdateCompanionBuilder,
      (SeriesSet, $$SeriesSetsTableReferences),
      SeriesSet,
      PrefetchHooks Function({bool seriesId, bool setId})
    >;
typedef $$OrganizationFieldDefinitionsTableCreateCompanionBuilder =
    OrganizationFieldDefinitionsCompanion Function({
      required String id,
      required String name,
      required String normalizedName,
      required CustomFieldType fieldType,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$OrganizationFieldDefinitionsTableUpdateCompanionBuilder =
    OrganizationFieldDefinitionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<CustomFieldType> fieldType,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$OrganizationFieldDefinitionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OrganizationFieldDefinitionsTable,
          OrganizationFieldDefinition
        > {
  $$OrganizationFieldDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $OrganizationFieldValuesTable,
    List<OrganizationFieldValue>
  >
  _organizationFieldValuesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.organizationFieldValues,
        aliasName:
            'custom_field_definitions__id__custom_field_values__field_id',
      );

  $$OrganizationFieldValuesTableProcessedTableManager
  get organizationFieldValuesRefs {
    final manager = $$OrganizationFieldValuesTableTableManager(
      $_db,
      $_db.organizationFieldValues,
    ).filter((f) => f.fieldId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _organizationFieldValuesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OrganizationFieldDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationFieldDefinitionsTable> {
  $$OrganizationFieldDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CustomFieldType, CustomFieldType, String>
  get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> organizationFieldValuesRefs(
    Expression<bool> Function($$OrganizationFieldValuesTableFilterComposer f) f,
  ) {
    final $$OrganizationFieldValuesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.organizationFieldValues,
          getReferencedColumn: (t) => t.fieldId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrganizationFieldValuesTableFilterComposer(
                $db: $db,
                $table: $db.organizationFieldValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$OrganizationFieldDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationFieldDefinitionsTable> {
  $$OrganizationFieldDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OrganizationFieldDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationFieldDefinitionsTable> {
  $$OrganizationFieldDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CustomFieldType, String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> organizationFieldValuesRefs<T extends Object>(
    Expression<T> Function($$OrganizationFieldValuesTableAnnotationComposer a)
    f,
  ) {
    final $$OrganizationFieldValuesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.organizationFieldValues,
          getReferencedColumn: (t) => t.fieldId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrganizationFieldValuesTableAnnotationComposer(
                $db: $db,
                $table: $db.organizationFieldValues,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$OrganizationFieldDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrganizationFieldDefinitionsTable,
          OrganizationFieldDefinition,
          $$OrganizationFieldDefinitionsTableFilterComposer,
          $$OrganizationFieldDefinitionsTableOrderingComposer,
          $$OrganizationFieldDefinitionsTableAnnotationComposer,
          $$OrganizationFieldDefinitionsTableCreateCompanionBuilder,
          $$OrganizationFieldDefinitionsTableUpdateCompanionBuilder,
          (
            OrganizationFieldDefinition,
            $$OrganizationFieldDefinitionsTableReferences,
          ),
          OrganizationFieldDefinition,
          PrefetchHooks Function({bool organizationFieldValuesRefs})
        > {
  $$OrganizationFieldDefinitionsTableTableManager(
    _$AppDatabase db,
    $OrganizationFieldDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationFieldDefinitionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OrganizationFieldDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OrganizationFieldDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<CustomFieldType> fieldType = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrganizationFieldDefinitionsCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                fieldType: fieldType,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedName,
                required CustomFieldType fieldType,
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrganizationFieldDefinitionsCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                fieldType: fieldType,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrganizationFieldDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({organizationFieldValuesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (organizationFieldValuesRefs) db.organizationFieldValues,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (organizationFieldValuesRefs)
                    await $_getPrefetchedData<
                      OrganizationFieldDefinition,
                      $OrganizationFieldDefinitionsTable,
                      OrganizationFieldValue
                    >(
                      currentTable: table,
                      referencedTable:
                          $$OrganizationFieldDefinitionsTableReferences
                              ._organizationFieldValuesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$OrganizationFieldDefinitionsTableReferences(
                            db,
                            table,
                            p0,
                          ).organizationFieldValuesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.fieldId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$OrganizationFieldDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrganizationFieldDefinitionsTable,
      OrganizationFieldDefinition,
      $$OrganizationFieldDefinitionsTableFilterComposer,
      $$OrganizationFieldDefinitionsTableOrderingComposer,
      $$OrganizationFieldDefinitionsTableAnnotationComposer,
      $$OrganizationFieldDefinitionsTableCreateCompanionBuilder,
      $$OrganizationFieldDefinitionsTableUpdateCompanionBuilder,
      (
        OrganizationFieldDefinition,
        $$OrganizationFieldDefinitionsTableReferences,
      ),
      OrganizationFieldDefinition,
      PrefetchHooks Function({bool organizationFieldValuesRefs})
    >;
typedef $$OrganizationFieldValuesTableCreateCompanionBuilder =
    OrganizationFieldValuesCompanion Function({
      required String fieldId,
      required String definitionId,
      Value<String?> textValue,
      Value<double?> numberValue,
      Value<DateTime?> dateValue,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$OrganizationFieldValuesTableUpdateCompanionBuilder =
    OrganizationFieldValuesCompanion Function({
      Value<String> fieldId,
      Value<String> definitionId,
      Value<String?> textValue,
      Value<double?> numberValue,
      Value<DateTime?> dateValue,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$OrganizationFieldValuesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OrganizationFieldValuesTable,
          OrganizationFieldValue
        > {
  $$OrganizationFieldValuesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $OrganizationFieldDefinitionsTable _fieldIdTable(_$AppDatabase db) =>
      db.organizationFieldDefinitions.createAlias(
        'custom_field_values__field_id__custom_field_definitions__id',
      );

  $$OrganizationFieldDefinitionsTableProcessedTableManager get fieldId {
    final $_column = $_itemColumn<String>('field_id')!;

    final manager = $$OrganizationFieldDefinitionsTableTableManager(
      $_db,
      $_db.organizationFieldDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CardDefinitionsTable _definitionIdTable(_$AppDatabase db) => db
      .cardDefinitions
      .createAlias('custom_field_values__definition_id__card_definitions__id');

  $$CardDefinitionsTableProcessedTableManager get definitionId {
    final $_column = $_itemColumn<String>('definition_id')!;

    final manager = $$CardDefinitionsTableTableManager(
      $_db,
      $_db.cardDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_definitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$OrganizationFieldValuesTableFilterComposer
    extends Composer<_$AppDatabase, $OrganizationFieldValuesTable> {
  $$OrganizationFieldValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateValue => $composableBuilder(
    column: $table.dateValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$OrganizationFieldDefinitionsTableFilterComposer get fieldId {
    final $$OrganizationFieldDefinitionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.fieldId,
          referencedTable: $db.organizationFieldDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrganizationFieldDefinitionsTableFilterComposer(
                $db: $db,
                $table: $db.organizationFieldDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CardDefinitionsTableFilterComposer get definitionId {
    final $$CardDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrganizationFieldValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrganizationFieldValuesTable> {
  $$OrganizationFieldValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get textValue => $composableBuilder(
    column: $table.textValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateValue => $composableBuilder(
    column: $table.dateValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$OrganizationFieldDefinitionsTableOrderingComposer get fieldId {
    final $$OrganizationFieldDefinitionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.fieldId,
          referencedTable: $db.organizationFieldDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrganizationFieldDefinitionsTableOrderingComposer(
                $db: $db,
                $table: $db.organizationFieldDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CardDefinitionsTableOrderingComposer get definitionId {
    final $$CardDefinitionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableOrderingComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrganizationFieldValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrganizationFieldValuesTable> {
  $$OrganizationFieldValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get textValue =>
      $composableBuilder(column: $table.textValue, builder: (column) => column);

  GeneratedColumn<double> get numberValue => $composableBuilder(
    column: $table.numberValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateValue =>
      $composableBuilder(column: $table.dateValue, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$OrganizationFieldDefinitionsTableAnnotationComposer get fieldId {
    final $$OrganizationFieldDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.fieldId,
          referencedTable: $db.organizationFieldDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OrganizationFieldDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.organizationFieldDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CardDefinitionsTableAnnotationComposer get definitionId {
    final $$CardDefinitionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.definitionId,
      referencedTable: $db.cardDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardDefinitionsTableAnnotationComposer(
            $db: $db,
            $table: $db.cardDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OrganizationFieldValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OrganizationFieldValuesTable,
          OrganizationFieldValue,
          $$OrganizationFieldValuesTableFilterComposer,
          $$OrganizationFieldValuesTableOrderingComposer,
          $$OrganizationFieldValuesTableAnnotationComposer,
          $$OrganizationFieldValuesTableCreateCompanionBuilder,
          $$OrganizationFieldValuesTableUpdateCompanionBuilder,
          (OrganizationFieldValue, $$OrganizationFieldValuesTableReferences),
          OrganizationFieldValue,
          PrefetchHooks Function({bool fieldId, bool definitionId})
        > {
  $$OrganizationFieldValuesTableTableManager(
    _$AppDatabase db,
    $OrganizationFieldValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrganizationFieldValuesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$OrganizationFieldValuesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$OrganizationFieldValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> fieldId = const Value.absent(),
                Value<String> definitionId = const Value.absent(),
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<DateTime?> dateValue = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OrganizationFieldValuesCompanion(
                fieldId: fieldId,
                definitionId: definitionId,
                textValue: textValue,
                numberValue: numberValue,
                dateValue: dateValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String fieldId,
                required String definitionId,
                Value<String?> textValue = const Value.absent(),
                Value<double?> numberValue = const Value.absent(),
                Value<DateTime?> dateValue = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => OrganizationFieldValuesCompanion.insert(
                fieldId: fieldId,
                definitionId: definitionId,
                textValue: textValue,
                numberValue: numberValue,
                dateValue: dateValue,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OrganizationFieldValuesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fieldId = false, definitionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fieldId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fieldId,
                                referencedTable:
                                    $$OrganizationFieldValuesTableReferences
                                        ._fieldIdTable(db),
                                referencedColumn:
                                    $$OrganizationFieldValuesTableReferences
                                        ._fieldIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (definitionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.definitionId,
                                referencedTable:
                                    $$OrganizationFieldValuesTableReferences
                                        ._definitionIdTable(db),
                                referencedColumn:
                                    $$OrganizationFieldValuesTableReferences
                                        ._definitionIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$OrganizationFieldValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OrganizationFieldValuesTable,
      OrganizationFieldValue,
      $$OrganizationFieldValuesTableFilterComposer,
      $$OrganizationFieldValuesTableOrderingComposer,
      $$OrganizationFieldValuesTableAnnotationComposer,
      $$OrganizationFieldValuesTableCreateCompanionBuilder,
      $$OrganizationFieldValuesTableUpdateCompanionBuilder,
      (OrganizationFieldValue, $$OrganizationFieldValuesTableReferences),
      OrganizationFieldValue,
      PrefetchHooks Function({bool fieldId, bool definitionId})
    >;
typedef $$PurchasesTableCreateCompanionBuilder =
    PurchasesCompanion Function({
      required String id,
      required DateTime purchasedAt,
      required int amountMinor,
      required String currency,
      Value<int> shippingMinor,
      Value<int> feesMinor,
      Value<String?> channel,
      Value<String?> seller,
      Value<String?> notes,
      Value<String?> adjustmentOfId,
      Value<int> version,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PurchasesTableUpdateCompanionBuilder =
    PurchasesCompanion Function({
      Value<String> id,
      Value<DateTime> purchasedAt,
      Value<int> amountMinor,
      Value<String> currency,
      Value<int> shippingMinor,
      Value<int> feesMinor,
      Value<String?> channel,
      Value<String?> seller,
      Value<String?> notes,
      Value<String?> adjustmentOfId,
      Value<int> version,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$PurchasesTableReferences
    extends BaseReferences<_$AppDatabase, $PurchasesTable, Purchase> {
  $$PurchasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PurchasesTable _adjustmentOfIdTable(_$AppDatabase db) =>
      db.purchases.createAlias('purchases__adjustment_of_id__purchases__id');

  $$PurchasesTableProcessedTableManager? get adjustmentOfId {
    final $_column = $_itemColumn<String>('adjustment_of_id');
    if ($_column == null) return null;
    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_adjustmentOfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PurchaseItemsTable, List<PurchaseItem>>
  _purchaseItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.purchaseItems,
    aliasName: 'purchases__id__purchase_items__purchase_id',
  );

  $$PurchaseItemsTableProcessedTableManager get purchaseItemsRefs {
    final manager = $$PurchaseItemsTableTableManager(
      $_db,
      $_db.purchaseItems,
    ).filter((f) => f.purchaseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_purchaseItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shippingMinor => $composableBuilder(
    column: $table.shippingMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get feesMinor => $composableBuilder(
    column: $table.feesMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seller => $composableBuilder(
    column: $table.seller,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableFilterComposer get adjustmentOfId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adjustmentOfId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> purchaseItemsRefs(
    Expression<bool> Function($$PurchaseItemsTableFilterComposer f) f,
  ) {
    final $$PurchaseItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableFilterComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shippingMinor => $composableBuilder(
    column: $table.shippingMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get feesMinor => $composableBuilder(
    column: $table.feesMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seller => $composableBuilder(
    column: $table.seller,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableOrderingComposer get adjustmentOfId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adjustmentOfId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get shippingMinor => $composableBuilder(
    column: $table.shippingMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get feesMinor =>
      $composableBuilder(column: $table.feesMinor, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get seller =>
      $composableBuilder(column: $table.seller, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PurchasesTableAnnotationComposer get adjustmentOfId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.adjustmentOfId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> purchaseItemsRefs<T extends Object>(
    Expression<T> Function($$PurchaseItemsTableAnnotationComposer a) f,
  ) {
    final $$PurchaseItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.purchaseItems,
      getReferencedColumn: (t) => t.purchaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchaseItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.purchaseItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          Purchase,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (Purchase, $$PurchasesTableReferences),
          Purchase,
          PrefetchHooks Function({bool adjustmentOfId, bool purchaseItemsRefs})
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> purchasedAt = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> shippingMinor = const Value.absent(),
                Value<int> feesMinor = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                Value<String?> seller = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> adjustmentOfId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion(
                id: id,
                purchasedAt: purchasedAt,
                amountMinor: amountMinor,
                currency: currency,
                shippingMinor: shippingMinor,
                feesMinor: feesMinor,
                channel: channel,
                seller: seller,
                notes: notes,
                adjustmentOfId: adjustmentOfId,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime purchasedAt,
                required int amountMinor,
                required String currency,
                Value<int> shippingMinor = const Value.absent(),
                Value<int> feesMinor = const Value.absent(),
                Value<String?> channel = const Value.absent(),
                Value<String?> seller = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> adjustmentOfId = const Value.absent(),
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion.insert(
                id: id,
                purchasedAt: purchasedAt,
                amountMinor: amountMinor,
                currency: currency,
                shippingMinor: shippingMinor,
                feesMinor: feesMinor,
                channel: channel,
                seller: seller,
                notes: notes,
                adjustmentOfId: adjustmentOfId,
                version: version,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PurchasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({adjustmentOfId = false, purchaseItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (purchaseItemsRefs) db.purchaseItems,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (adjustmentOfId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.adjustmentOfId,
                                    referencedTable: $$PurchasesTableReferences
                                        ._adjustmentOfIdTable(db),
                                    referencedColumn: $$PurchasesTableReferences
                                        ._adjustmentOfIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (purchaseItemsRefs)
                        await $_getPrefetchedData<
                          Purchase,
                          $PurchasesTable,
                          PurchaseItem
                        >(
                          currentTable: table,
                          referencedTable: $$PurchasesTableReferences
                              ._purchaseItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PurchasesTableReferences(
                                db,
                                table,
                                p0,
                              ).purchaseItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.purchaseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      Purchase,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (Purchase, $$PurchasesTableReferences),
      Purchase,
      PrefetchHooks Function({bool adjustmentOfId, bool purchaseItemsRefs})
    >;
typedef $$PurchaseItemsTableCreateCompanionBuilder =
    PurchaseItemsCompanion Function({
      required String purchaseId,
      required PurchaseTargetType targetType,
      required String targetId,
      required String targetName,
      Value<int?> allocatedMinor,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PurchaseItemsTableUpdateCompanionBuilder =
    PurchaseItemsCompanion Function({
      Value<String> purchaseId,
      Value<PurchaseTargetType> targetType,
      Value<String> targetId,
      Value<String> targetName,
      Value<int?> allocatedMinor,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$PurchaseItemsTableReferences
    extends BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItem> {
  $$PurchaseItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PurchasesTable _purchaseIdTable(_$AppDatabase db) =>
      db.purchases.createAlias('purchase_items__purchase_id__purchases__id');

  $$PurchasesTableProcessedTableManager get purchaseId {
    final $_column = $_itemColumn<String>('purchase_id')!;

    final manager = $$PurchasesTableTableManager(
      $_db,
      $_db.purchases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_purchaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PurchaseItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<PurchaseTargetType, PurchaseTargetType, String>
  get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allocatedMinor => $composableBuilder(
    column: $table.allocatedMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PurchasesTableFilterComposer get purchaseId {
    final $$PurchasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableFilterComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allocatedMinor => $composableBuilder(
    column: $table.allocatedMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PurchasesTableOrderingComposer get purchaseId {
    final $$PurchasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableOrderingComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<PurchaseTargetType, String> get targetType =>
      $composableBuilder(
        column: $table.targetType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get targetName => $composableBuilder(
    column: $table.targetName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get allocatedMinor => $composableBuilder(
    column: $table.allocatedMinor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$PurchasesTableAnnotationComposer get purchaseId {
    final $$PurchasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.purchaseId,
      referencedTable: $db.purchases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PurchasesTableAnnotationComposer(
            $db: $db,
            $table: $db.purchases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PurchaseItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchaseItemsTable,
          PurchaseItem,
          $$PurchaseItemsTableFilterComposer,
          $$PurchaseItemsTableOrderingComposer,
          $$PurchaseItemsTableAnnotationComposer,
          $$PurchaseItemsTableCreateCompanionBuilder,
          $$PurchaseItemsTableUpdateCompanionBuilder,
          (PurchaseItem, $$PurchaseItemsTableReferences),
          PurchaseItem,
          PrefetchHooks Function({bool purchaseId})
        > {
  $$PurchaseItemsTableTableManager(_$AppDatabase db, $PurchaseItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> purchaseId = const Value.absent(),
                Value<PurchaseTargetType> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<String> targetName = const Value.absent(),
                Value<int?> allocatedMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchaseItemsCompanion(
                purchaseId: purchaseId,
                targetType: targetType,
                targetId: targetId,
                targetName: targetName,
                allocatedMinor: allocatedMinor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String purchaseId,
                required PurchaseTargetType targetType,
                required String targetId,
                required String targetName,
                Value<int?> allocatedMinor = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PurchaseItemsCompanion.insert(
                purchaseId: purchaseId,
                targetType: targetType,
                targetId: targetId,
                targetName: targetName,
                allocatedMinor: allocatedMinor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PurchaseItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({purchaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (purchaseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.purchaseId,
                                referencedTable: $$PurchaseItemsTableReferences
                                    ._purchaseIdTable(db),
                                referencedColumn: $$PurchaseItemsTableReferences
                                    ._purchaseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PurchaseItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchaseItemsTable,
      PurchaseItem,
      $$PurchaseItemsTableFilterComposer,
      $$PurchaseItemsTableOrderingComposer,
      $$PurchaseItemsTableAnnotationComposer,
      $$PurchaseItemsTableCreateCompanionBuilder,
      $$PurchaseItemsTableUpdateCompanionBuilder,
      (PurchaseItem, $$PurchaseItemsTableReferences),
      PurchaseItem,
      PrefetchHooks Function({bool purchaseId})
    >;
typedef $$ExchangeRatesTableCreateCompanionBuilder =
    ExchangeRatesCompanion Function({
      required String baseCurrency,
      required String quoteCurrency,
      required DateTime rateDate,
      required int numerator,
      required int denominator,
      required String source,
      required DateTime capturedAt,
      Value<int> rowid,
    });
typedef $$ExchangeRatesTableUpdateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<String> baseCurrency,
      Value<String> quoteCurrency,
      Value<DateTime> rateDate,
      Value<int> numerator,
      Value<int> denominator,
      Value<String> source,
      Value<DateTime> capturedAt,
      Value<int> rowid,
    });

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numerator => $composableBuilder(
    column: $table.numerator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get denominator => $composableBuilder(
    column: $table.denominator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rateDate => $composableBuilder(
    column: $table.rateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numerator => $composableBuilder(
    column: $table.numerator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get denominator => $composableBuilder(
    column: $table.denominator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get baseCurrency => $composableBuilder(
    column: $table.baseCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteCurrency => $composableBuilder(
    column: $table.quoteCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rateDate =>
      $composableBuilder(column: $table.rateDate, builder: (column) => column);

  GeneratedColumn<int> get numerator =>
      $composableBuilder(column: $table.numerator, builder: (column) => column);

  GeneratedColumn<int> get denominator => $composableBuilder(
    column: $table.denominator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );
}

class $$ExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRatesTable,
          ExchangeRate,
          $$ExchangeRatesTableFilterComposer,
          $$ExchangeRatesTableOrderingComposer,
          $$ExchangeRatesTableAnnotationComposer,
          $$ExchangeRatesTableCreateCompanionBuilder,
          $$ExchangeRatesTableUpdateCompanionBuilder,
          (
            ExchangeRate,
            BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
          ),
          ExchangeRate,
          PrefetchHooks Function()
        > {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> baseCurrency = const Value.absent(),
                Value<String> quoteCurrency = const Value.absent(),
                Value<DateTime> rateDate = const Value.absent(),
                Value<int> numerator = const Value.absent(),
                Value<int> denominator = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion(
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rateDate: rateDate,
                numerator: numerator,
                denominator: denominator,
                source: source,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String baseCurrency,
                required String quoteCurrency,
                required DateTime rateDate,
                required int numerator,
                required int denominator,
                required String source,
                required DateTime capturedAt,
                Value<int> rowid = const Value.absent(),
              }) => ExchangeRatesCompanion.insert(
                baseCurrency: baseCurrency,
                quoteCurrency: quoteCurrency,
                rateDate: rateDate,
                numerator: numerator,
                denominator: denominator,
                source: source,
                capturedAt: capturedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRatesTable,
      ExchangeRate,
      $$ExchangeRatesTableFilterComposer,
      $$ExchangeRatesTableOrderingComposer,
      $$ExchangeRatesTableAnnotationComposer,
      $$ExchangeRatesTableCreateCompanionBuilder,
      $$ExchangeRatesTableUpdateCompanionBuilder,
      (
        ExchangeRate,
        BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRate>,
      ),
      ExchangeRate,
      PrefetchHooks Function()
    >;
typedef $$RecycleBinSettingsRowsTableCreateCompanionBuilder =
    RecycleBinSettingsRowsCompanion Function({
      Value<int> id,
      Value<int> retentionDays,
      required DateTime updatedAt,
    });
typedef $$RecycleBinSettingsRowsTableUpdateCompanionBuilder =
    RecycleBinSettingsRowsCompanion Function({
      Value<int> id,
      Value<int> retentionDays,
      Value<DateTime> updatedAt,
    });

class $$RecycleBinSettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $RecycleBinSettingsRowsTable> {
  $$RecycleBinSettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retentionDays => $composableBuilder(
    column: $table.retentionDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecycleBinSettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecycleBinSettingsRowsTable> {
  $$RecycleBinSettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retentionDays => $composableBuilder(
    column: $table.retentionDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecycleBinSettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecycleBinSettingsRowsTable> {
  $$RecycleBinSettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get retentionDays => $composableBuilder(
    column: $table.retentionDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RecycleBinSettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecycleBinSettingsRowsTable,
          RecycleBinSettingsRow,
          $$RecycleBinSettingsRowsTableFilterComposer,
          $$RecycleBinSettingsRowsTableOrderingComposer,
          $$RecycleBinSettingsRowsTableAnnotationComposer,
          $$RecycleBinSettingsRowsTableCreateCompanionBuilder,
          $$RecycleBinSettingsRowsTableUpdateCompanionBuilder,
          (
            RecycleBinSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $RecycleBinSettingsRowsTable,
              RecycleBinSettingsRow
            >,
          ),
          RecycleBinSettingsRow,
          PrefetchHooks Function()
        > {
  $$RecycleBinSettingsRowsTableTableManager(
    _$AppDatabase db,
    $RecycleBinSettingsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecycleBinSettingsRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecycleBinSettingsRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecycleBinSettingsRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> retentionDays = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RecycleBinSettingsRowsCompanion(
                id: id,
                retentionDays: retentionDays,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> retentionDays = const Value.absent(),
                required DateTime updatedAt,
              }) => RecycleBinSettingsRowsCompanion.insert(
                id: id,
                retentionDays: retentionDays,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecycleBinSettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecycleBinSettingsRowsTable,
      RecycleBinSettingsRow,
      $$RecycleBinSettingsRowsTableFilterComposer,
      $$RecycleBinSettingsRowsTableOrderingComposer,
      $$RecycleBinSettingsRowsTableAnnotationComposer,
      $$RecycleBinSettingsRowsTableCreateCompanionBuilder,
      $$RecycleBinSettingsRowsTableUpdateCompanionBuilder,
      (
        RecycleBinSettingsRow,
        BaseReferences<
          _$AppDatabase,
          $RecycleBinSettingsRowsTable,
          RecycleBinSettingsRow
        >,
      ),
      RecycleBinSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$FileCleanupQueueEntriesTableCreateCompanionBuilder =
    FileCleanupQueueEntriesCompanion Function({
      required String relativePath,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<DateTime?> lastAttemptAt,
      Value<int> rowid,
    });
typedef $$FileCleanupQueueEntriesTableUpdateCompanionBuilder =
    FileCleanupQueueEntriesCompanion Function({
      Value<String> relativePath,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<DateTime?> lastAttemptAt,
      Value<int> rowid,
    });

class $$FileCleanupQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FileCleanupQueueEntriesTable> {
  $$FileCleanupQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FileCleanupQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FileCleanupQueueEntriesTable> {
  $$FileCleanupQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FileCleanupQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FileCleanupQueueEntriesTable> {
  $$FileCleanupQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );
}

class $$FileCleanupQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FileCleanupQueueEntriesTable,
          FileCleanupQueueEntry,
          $$FileCleanupQueueEntriesTableFilterComposer,
          $$FileCleanupQueueEntriesTableOrderingComposer,
          $$FileCleanupQueueEntriesTableAnnotationComposer,
          $$FileCleanupQueueEntriesTableCreateCompanionBuilder,
          $$FileCleanupQueueEntriesTableUpdateCompanionBuilder,
          (
            FileCleanupQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $FileCleanupQueueEntriesTable,
              FileCleanupQueueEntry
            >,
          ),
          FileCleanupQueueEntry,
          PrefetchHooks Function()
        > {
  $$FileCleanupQueueEntriesTableTableManager(
    _$AppDatabase db,
    $FileCleanupQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FileCleanupQueueEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$FileCleanupQueueEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$FileCleanupQueueEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> relativePath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileCleanupQueueEntriesCompanion(
                relativePath: relativePath,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String relativePath,
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FileCleanupQueueEntriesCompanion.insert(
                relativePath: relativePath,
                createdAt: createdAt,
                attemptCount: attemptCount,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FileCleanupQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FileCleanupQueueEntriesTable,
      FileCleanupQueueEntry,
      $$FileCleanupQueueEntriesTableFilterComposer,
      $$FileCleanupQueueEntriesTableOrderingComposer,
      $$FileCleanupQueueEntriesTableAnnotationComposer,
      $$FileCleanupQueueEntriesTableCreateCompanionBuilder,
      $$FileCleanupQueueEntriesTableUpdateCompanionBuilder,
      (
        FileCleanupQueueEntry,
        BaseReferences<
          _$AppDatabase,
          $FileCleanupQueueEntriesTable,
          FileCleanupQueueEntry
        >,
      ),
      FileCleanupQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncSettingsRowsTableCreateCompanionBuilder =
    SyncSettingsRowsCompanion Function({
      Value<int> id,
      required String deviceId,
      Value<bool> enabled,
      Value<String?> cursor,
      Value<String?> accountUserId,
      Value<String?> accountEmail,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastErrorCode,
      required DateTime updatedAt,
    });
typedef $$SyncSettingsRowsTableUpdateCompanionBuilder =
    SyncSettingsRowsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<bool> enabled,
      Value<String?> cursor,
      Value<String?> accountUserId,
      Value<String?> accountEmail,
      Value<DateTime?> lastSyncedAt,
      Value<String?> lastErrorCode,
      Value<DateTime> updatedAt,
    });

class $$SyncSettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncSettingsRowsTable> {
  $$SyncSettingsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountUserId => $composableBuilder(
    column: $table.accountUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountEmail => $composableBuilder(
    column: $table.accountEmail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncSettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncSettingsRowsTable> {
  $$SyncSettingsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountUserId => $composableBuilder(
    column: $table.accountUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountEmail => $composableBuilder(
    column: $table.accountEmail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncSettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncSettingsRowsTable> {
  $$SyncSettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<String> get accountUserId => $composableBuilder(
    column: $table.accountUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountEmail => $composableBuilder(
    column: $table.accountEmail,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncSettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncSettingsRowsTable,
          SyncSettingsRow,
          $$SyncSettingsRowsTableFilterComposer,
          $$SyncSettingsRowsTableOrderingComposer,
          $$SyncSettingsRowsTableAnnotationComposer,
          $$SyncSettingsRowsTableCreateCompanionBuilder,
          $$SyncSettingsRowsTableUpdateCompanionBuilder,
          (
            SyncSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $SyncSettingsRowsTable,
              SyncSettingsRow
            >,
          ),
          SyncSettingsRow,
          PrefetchHooks Function()
        > {
  $$SyncSettingsRowsTableTableManager(
    _$AppDatabase db,
    $SyncSettingsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncSettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncSettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncSettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<String?> accountUserId = const Value.absent(),
                Value<String?> accountEmail = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => SyncSettingsRowsCompanion(
                id: id,
                deviceId: deviceId,
                enabled: enabled,
                cursor: cursor,
                accountUserId: accountUserId,
                accountEmail: accountEmail,
                lastSyncedAt: lastSyncedAt,
                lastErrorCode: lastErrorCode,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                Value<bool> enabled = const Value.absent(),
                Value<String?> cursor = const Value.absent(),
                Value<String?> accountUserId = const Value.absent(),
                Value<String?> accountEmail = const Value.absent(),
                Value<DateTime?> lastSyncedAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                required DateTime updatedAt,
              }) => SyncSettingsRowsCompanion.insert(
                id: id,
                deviceId: deviceId,
                enabled: enabled,
                cursor: cursor,
                accountUserId: accountUserId,
                accountEmail: accountEmail,
                lastSyncedAt: lastSyncedAt,
                lastErrorCode: lastErrorCode,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncSettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncSettingsRowsTable,
      SyncSettingsRow,
      $$SyncSettingsRowsTableFilterComposer,
      $$SyncSettingsRowsTableOrderingComposer,
      $$SyncSettingsRowsTableAnnotationComposer,
      $$SyncSettingsRowsTableCreateCompanionBuilder,
      $$SyncSettingsRowsTableUpdateCompanionBuilder,
      (
        SyncSettingsRow,
        BaseReferences<_$AppDatabase, $SyncSettingsRowsTable, SyncSettingsRow>,
      ),
      SyncSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$SyncEntityStateRowsTableCreateCompanionBuilder =
    SyncEntityStateRowsCompanion Function({
      required String entityType,
      required String entityId,
      required int serverVersion,
      Value<String?> payloadJson,
      Value<bool> deleted,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncEntityStateRowsTableUpdateCompanionBuilder =
    SyncEntityStateRowsCompanion Function({
      Value<String> entityType,
      Value<String> entityId,
      Value<int> serverVersion,
      Value<String?> payloadJson,
      Value<bool> deleted,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncEntityStateRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncEntityStateRowsTable> {
  $$SyncEntityStateRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncEntityStateRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncEntityStateRowsTable> {
  $$SyncEntityStateRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncEntityStateRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncEntityStateRowsTable> {
  $$SyncEntityStateRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get serverVersion => $composableBuilder(
    column: $table.serverVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncEntityStateRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncEntityStateRowsTable,
          SyncEntityStateRow,
          $$SyncEntityStateRowsTableFilterComposer,
          $$SyncEntityStateRowsTableOrderingComposer,
          $$SyncEntityStateRowsTableAnnotationComposer,
          $$SyncEntityStateRowsTableCreateCompanionBuilder,
          $$SyncEntityStateRowsTableUpdateCompanionBuilder,
          (
            SyncEntityStateRow,
            BaseReferences<
              _$AppDatabase,
              $SyncEntityStateRowsTable,
              SyncEntityStateRow
            >,
          ),
          SyncEntityStateRow,
          PrefetchHooks Function()
        > {
  $$SyncEntityStateRowsTableTableManager(
    _$AppDatabase db,
    $SyncEntityStateRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncEntityStateRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncEntityStateRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SyncEntityStateRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> serverVersion = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStateRowsCompanion(
                entityType: entityType,
                entityId: entityId,
                serverVersion: serverVersion,
                payloadJson: payloadJson,
                deleted: deleted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityType,
                required String entityId,
                required int serverVersion,
                Value<String?> payloadJson = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncEntityStateRowsCompanion.insert(
                entityType: entityType,
                entityId: entityId,
                serverVersion: serverVersion,
                payloadJson: payloadJson,
                deleted: deleted,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncEntityStateRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncEntityStateRowsTable,
      SyncEntityStateRow,
      $$SyncEntityStateRowsTableFilterComposer,
      $$SyncEntityStateRowsTableOrderingComposer,
      $$SyncEntityStateRowsTableAnnotationComposer,
      $$SyncEntityStateRowsTableCreateCompanionBuilder,
      $$SyncEntityStateRowsTableUpdateCompanionBuilder,
      (
        SyncEntityStateRow,
        BaseReferences<
          _$AppDatabase,
          $SyncEntityStateRowsTable,
          SyncEntityStateRow
        >,
      ),
      SyncEntityStateRow,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxEntriesTableCreateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      required String operationId,
      required String entityType,
      required String entityId,
      required String operation,
      required int baseServerVersion,
      Value<String?> payloadJson,
      required String changedFieldsJson,
      required DateTime createdAt,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });
typedef $$SyncOutboxEntriesTableUpdateCompanionBuilder =
    SyncOutboxEntriesCompanion Function({
      Value<String> operationId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operation,
      Value<int> baseServerVersion,
      Value<String?> payloadJson,
      Value<String> changedFieldsJson,
      Value<DateTime> createdAt,
      Value<int> attemptCount,
      Value<DateTime?> nextAttemptAt,
      Value<String?> lastErrorCode,
      Value<int> rowid,
    });

class $$SyncOutboxEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changedFieldsJson => $composableBuilder(
    column: $table.changedFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedFieldsJson => $composableBuilder(
    column: $table.changedFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxEntriesTable> {
  $$SyncOutboxEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<int> get baseServerVersion => $composableBuilder(
    column: $table.baseServerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get changedFieldsJson => $composableBuilder(
    column: $table.changedFieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastErrorCode => $composableBuilder(
    column: $table.lastErrorCode,
    builder: (column) => column,
  );
}

class $$SyncOutboxEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxEntriesTable,
          SyncOutboxEntry,
          $$SyncOutboxEntriesTableFilterComposer,
          $$SyncOutboxEntriesTableOrderingComposer,
          $$SyncOutboxEntriesTableAnnotationComposer,
          $$SyncOutboxEntriesTableCreateCompanionBuilder,
          $$SyncOutboxEntriesTableUpdateCompanionBuilder,
          (
            SyncOutboxEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncOutboxEntriesTable,
              SyncOutboxEntry
            >,
          ),
          SyncOutboxEntry,
          PrefetchHooks Function()
        > {
  $$SyncOutboxEntriesTableTableManager(
    _$AppDatabase db,
    $SyncOutboxEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> operationId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<int> baseServerVersion = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String> changedFieldsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion(
                operationId: operationId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                baseServerVersion: baseServerVersion,
                payloadJson: payloadJson,
                changedFieldsJson: changedFieldsJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String operationId,
                required String entityType,
                required String entityId,
                required String operation,
                required int baseServerVersion,
                Value<String?> payloadJson = const Value.absent(),
                required String changedFieldsJson,
                required DateTime createdAt,
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<String?> lastErrorCode = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxEntriesCompanion.insert(
                operationId: operationId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                baseServerVersion: baseServerVersion,
                payloadJson: payloadJson,
                changedFieldsJson: changedFieldsJson,
                createdAt: createdAt,
                attemptCount: attemptCount,
                nextAttemptAt: nextAttemptAt,
                lastErrorCode: lastErrorCode,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxEntriesTable,
      SyncOutboxEntry,
      $$SyncOutboxEntriesTableFilterComposer,
      $$SyncOutboxEntriesTableOrderingComposer,
      $$SyncOutboxEntriesTableAnnotationComposer,
      $$SyncOutboxEntriesTableCreateCompanionBuilder,
      $$SyncOutboxEntriesTableUpdateCompanionBuilder,
      (
        SyncOutboxEntry,
        BaseReferences<_$AppDatabase, $SyncOutboxEntriesTable, SyncOutboxEntry>,
      ),
      SyncOutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$SyncConflictRowsTableCreateCompanionBuilder =
    SyncConflictRowsCompanion Function({
      required String id,
      required String entityType,
      required String entityId,
      required String localOperation,
      Value<String?> localPayloadJson,
      required String remoteOperation,
      Value<String?> remotePayloadJson,
      required int remoteServerVersion,
      required String conflictingFieldsJson,
      required DateTime detectedAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$SyncConflictRowsTableUpdateCompanionBuilder =
    SyncConflictRowsCompanion Function({
      Value<String> id,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> localOperation,
      Value<String?> localPayloadJson,
      Value<String> remoteOperation,
      Value<String?> remotePayloadJson,
      Value<int> remoteServerVersion,
      Value<String> conflictingFieldsJson,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$SyncConflictRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncConflictRowsTable> {
  $$SyncConflictRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localOperation => $composableBuilder(
    column: $table.localOperation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteOperation => $composableBuilder(
    column: $table.remoteOperation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remotePayloadJson => $composableBuilder(
    column: $table.remotePayloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get remoteServerVersion => $composableBuilder(
    column: $table.remoteServerVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conflictingFieldsJson => $composableBuilder(
    column: $table.conflictingFieldsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncConflictRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncConflictRowsTable> {
  $$SyncConflictRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localOperation => $composableBuilder(
    column: $table.localOperation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteOperation => $composableBuilder(
    column: $table.remoteOperation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remotePayloadJson => $composableBuilder(
    column: $table.remotePayloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get remoteServerVersion => $composableBuilder(
    column: $table.remoteServerVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conflictingFieldsJson => $composableBuilder(
    column: $table.conflictingFieldsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncConflictRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncConflictRowsTable> {
  $$SyncConflictRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get localOperation => $composableBuilder(
    column: $table.localOperation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPayloadJson => $composableBuilder(
    column: $table.localPayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteOperation => $composableBuilder(
    column: $table.remoteOperation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remotePayloadJson => $composableBuilder(
    column: $table.remotePayloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get remoteServerVersion => $composableBuilder(
    column: $table.remoteServerVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conflictingFieldsJson => $composableBuilder(
    column: $table.conflictingFieldsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$SyncConflictRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncConflictRowsTable,
          SyncConflictRow,
          $$SyncConflictRowsTableFilterComposer,
          $$SyncConflictRowsTableOrderingComposer,
          $$SyncConflictRowsTableAnnotationComposer,
          $$SyncConflictRowsTableCreateCompanionBuilder,
          $$SyncConflictRowsTableUpdateCompanionBuilder,
          (
            SyncConflictRow,
            BaseReferences<
              _$AppDatabase,
              $SyncConflictRowsTable,
              SyncConflictRow
            >,
          ),
          SyncConflictRow,
          PrefetchHooks Function()
        > {
  $$SyncConflictRowsTableTableManager(
    _$AppDatabase db,
    $SyncConflictRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncConflictRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncConflictRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncConflictRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> localOperation = const Value.absent(),
                Value<String?> localPayloadJson = const Value.absent(),
                Value<String> remoteOperation = const Value.absent(),
                Value<String?> remotePayloadJson = const Value.absent(),
                Value<int> remoteServerVersion = const Value.absent(),
                Value<String> conflictingFieldsJson = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictRowsCompanion(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localOperation: localOperation,
                localPayloadJson: localPayloadJson,
                remoteOperation: remoteOperation,
                remotePayloadJson: remotePayloadJson,
                remoteServerVersion: remoteServerVersion,
                conflictingFieldsJson: conflictingFieldsJson,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityType,
                required String entityId,
                required String localOperation,
                Value<String?> localPayloadJson = const Value.absent(),
                required String remoteOperation,
                Value<String?> remotePayloadJson = const Value.absent(),
                required int remoteServerVersion,
                required String conflictingFieldsJson,
                required DateTime detectedAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncConflictRowsCompanion.insert(
                id: id,
                entityType: entityType,
                entityId: entityId,
                localOperation: localOperation,
                localPayloadJson: localPayloadJson,
                remoteOperation: remoteOperation,
                remotePayloadJson: remotePayloadJson,
                remoteServerVersion: remoteServerVersion,
                conflictingFieldsJson: conflictingFieldsJson,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncConflictRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncConflictRowsTable,
      SyncConflictRow,
      $$SyncConflictRowsTableFilterComposer,
      $$SyncConflictRowsTableOrderingComposer,
      $$SyncConflictRowsTableAnnotationComposer,
      $$SyncConflictRowsTableCreateCompanionBuilder,
      $$SyncConflictRowsTableUpdateCompanionBuilder,
      (
        SyncConflictRow,
        BaseReferences<_$AppDatabase, $SyncConflictRowsTable, SyncConflictRow>,
      ),
      SyncConflictRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardDefinitionsTableTableManager get cardDefinitions =>
      $$CardDefinitionsTableTableManager(_db, _db.cardDefinitions);
  $$CardItemsTableTableManager get cardItems =>
      $$CardItemsTableTableManager(_db, _db.cardItems);
  $$CardImagesTableTableManager get cardImages =>
      $$CardImagesTableTableManager(_db, _db.cardImages);
  $$CardSetsTableTableManager get cardSets =>
      $$CardSetsTableTableManager(_db, _db.cardSets);
  $$CardSetMembersTableTableManager get cardSetMembers =>
      $$CardSetMembersTableTableManager(_db, _db.cardSetMembers);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$CardTagsTableTableManager get cardTags =>
      $$CardTagsTableTableManager(_db, _db.cardTags);
  $$SeriesRecordsTableTableManager get seriesRecords =>
      $$SeriesRecordsTableTableManager(_db, _db.seriesRecords);
  $$SeriesCardsTableTableManager get seriesCards =>
      $$SeriesCardsTableTableManager(_db, _db.seriesCards);
  $$SeriesSetsTableTableManager get seriesSets =>
      $$SeriesSetsTableTableManager(_db, _db.seriesSets);
  $$OrganizationFieldDefinitionsTableTableManager
  get organizationFieldDefinitions =>
      $$OrganizationFieldDefinitionsTableTableManager(
        _db,
        _db.organizationFieldDefinitions,
      );
  $$OrganizationFieldValuesTableTableManager get organizationFieldValues =>
      $$OrganizationFieldValuesTableTableManager(
        _db,
        _db.organizationFieldValues,
      );
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseItemsTableTableManager get purchaseItems =>
      $$PurchaseItemsTableTableManager(_db, _db.purchaseItems);
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
  $$RecycleBinSettingsRowsTableTableManager get recycleBinSettingsRows =>
      $$RecycleBinSettingsRowsTableTableManager(
        _db,
        _db.recycleBinSettingsRows,
      );
  $$FileCleanupQueueEntriesTableTableManager get fileCleanupQueueEntries =>
      $$FileCleanupQueueEntriesTableTableManager(
        _db,
        _db.fileCleanupQueueEntries,
      );
  $$SyncSettingsRowsTableTableManager get syncSettingsRows =>
      $$SyncSettingsRowsTableTableManager(_db, _db.syncSettingsRows);
  $$SyncEntityStateRowsTableTableManager get syncEntityStateRows =>
      $$SyncEntityStateRowsTableTableManager(_db, _db.syncEntityStateRows);
  $$SyncOutboxEntriesTableTableManager get syncOutboxEntries =>
      $$SyncOutboxEntriesTableTableManager(_db, _db.syncOutboxEntries);
  $$SyncConflictRowsTableTableManager get syncConflictRows =>
      $$SyncConflictRowsTableTableManager(_db, _db.syncConflictRows);
}
