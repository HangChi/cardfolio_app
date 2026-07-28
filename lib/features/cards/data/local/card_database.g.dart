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
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 软删除标记。Feature 001 恒为 null。
  final DateTime? deletedAt;
  const CardItem({
    required this.id,
    required this.definitionId,
    required this.quantity,
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
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CardItem(
    id: id ?? this.id,
    definitionId: definitionId ?? this.definitionId,
    quantity: quantity ?? this.quantity,
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
          other.version == this.version &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CardItemsCompanion extends UpdateCompanion<CardItem> {
  final Value<String> id;
  final Value<String> definitionId;
  final Value<int> quantity;
  final Value<int> version;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CardItemsCompanion({
    this.id = const Value.absent(),
    this.definitionId = const Value.absent(),
    this.quantity = const Value.absent(),
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
          PrefetchHooks Function({bool cardItemsRefs, bool cardSetMembersRefs})
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
              ({cardItemsRefs = false, cardSetMembersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardItemsRefs) db.cardItems,
                    if (cardSetMembersRefs) db.cardSetMembers,
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
      PrefetchHooks Function({bool cardItemsRefs, bool cardSetMembersRefs})
    >;
typedef $$CardItemsTableCreateCompanionBuilder =
    CardItemsCompanion Function({
      required String id,
      required String definitionId,
      Value<int> quantity,
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
                Value<int> version = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardItemsCompanion(
                id: id,
                definitionId: definitionId,
                quantity: quantity,
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
                Value<int> version = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardItemsCompanion.insert(
                id: id,
                definitionId: definitionId,
                quantity: quantity,
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
          PrefetchHooks Function({bool coverImageId, bool cardSetMembersRefs})
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
              ({coverImageId = false, cardSetMembersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cardSetMembersRefs) db.cardSetMembers,
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
      PrefetchHooks Function({bool coverImageId, bool cardSetMembersRefs})
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
}
