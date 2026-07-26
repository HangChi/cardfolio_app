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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cardItemId,
    kind,
    relativePath,
    sortOrder,
    checksum,
    createdAt,
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
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
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
  final int sortOrder;

  /// 源文件 SHA-256，用于完整性校验与去重判断。
  final String checksum;
  final DateTime createdAt;
  const CardImage({
    required this.id,
    required this.cardItemId,
    required this.kind,
    required this.relativePath,
    required this.sortOrder,
    required this.checksum,
    required this.createdAt,
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
    map['sort_order'] = Variable<int>(sortOrder);
    map['checksum'] = Variable<String>(checksum);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CardImagesCompanion toCompanion(bool nullToAbsent) {
    return CardImagesCompanion(
      id: Value(id),
      cardItemId: Value(cardItemId),
      kind: Value(kind),
      relativePath: Value(relativePath),
      sortOrder: Value(sortOrder),
      checksum: Value(checksum),
      createdAt: Value(createdAt),
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
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      checksum: serializer.fromJson<String>(json['checksum']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
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
      'sortOrder': serializer.toJson<int>(sortOrder),
      'checksum': serializer.toJson<String>(checksum),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CardImage copyWith({
    String? id,
    String? cardItemId,
    CardImageKind? kind,
    String? relativePath,
    int? sortOrder,
    String? checksum,
    DateTime? createdAt,
  }) => CardImage(
    id: id ?? this.id,
    cardItemId: cardItemId ?? this.cardItemId,
    kind: kind ?? this.kind,
    relativePath: relativePath ?? this.relativePath,
    sortOrder: sortOrder ?? this.sortOrder,
    checksum: checksum ?? this.checksum,
    createdAt: createdAt ?? this.createdAt,
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
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardImage(')
          ..write('id: $id, ')
          ..write('cardItemId: $cardItemId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cardItemId,
    kind,
    relativePath,
    sortOrder,
    checksum,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardImage &&
          other.id == this.id &&
          other.cardItemId == this.cardItemId &&
          other.kind == this.kind &&
          other.relativePath == this.relativePath &&
          other.sortOrder == this.sortOrder &&
          other.checksum == this.checksum &&
          other.createdAt == this.createdAt);
}

class CardImagesCompanion extends UpdateCompanion<CardImage> {
  final Value<String> id;
  final Value<String> cardItemId;
  final Value<CardImageKind> kind;
  final Value<String> relativePath;
  final Value<int> sortOrder;
  final Value<String> checksum;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CardImagesCompanion({
    this.id = const Value.absent(),
    this.cardItemId = const Value.absent(),
    this.kind = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.checksum = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardImagesCompanion.insert({
    required String id,
    required String cardItemId,
    required CardImageKind kind,
    required String relativePath,
    this.sortOrder = const Value.absent(),
    required String checksum,
    required DateTime createdAt,
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
    Expression<int>? sortOrder,
    Expression<String>? checksum,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardItemId != null) 'card_item_id': cardItemId,
      if (kind != null) 'kind': kind,
      if (relativePath != null) 'relative_path': relativePath,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (checksum != null) 'checksum': checksum,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardImagesCompanion copyWith({
    Value<String>? id,
    Value<String>? cardItemId,
    Value<CardImageKind>? kind,
    Value<String>? relativePath,
    Value<int>? sortOrder,
    Value<String>? checksum,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CardImagesCompanion(
      id: id ?? this.id,
      cardItemId: cardItemId ?? this.cardItemId,
      kind: kind ?? this.kind,
      relativePath: relativePath ?? this.relativePath,
      sortOrder: sortOrder ?? this.sortOrder,
      checksum: checksum ?? this.checksum,
      createdAt: createdAt ?? this.createdAt,
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
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
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
    return (StringBuffer('CardImagesCompanion(')
          ..write('id: $id, ')
          ..write('cardItemId: $cardItemId, ')
          ..write('kind: $kind, ')
          ..write('relativePath: $relativePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('checksum: $checksum, ')
          ..write('createdAt: $createdAt, ')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cardDefinitions,
    cardItems,
    cardImages,
    idxCardDefinitionsDeletedAt,
    idxCardItemsDefinitionId,
    idxCardItemsDeletedAt,
    idxCardItemsCreatedAt,
    idxCardImagesCardItemId,
    idxCardImagesSortOrder,
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
          PrefetchHooks Function({bool cardItemsRefs})
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
          prefetchHooksCallback: ({cardItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardItemsRefs) db.cardItems],
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
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
      PrefetchHooks Function({bool cardItemsRefs})
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
      Value<int> sortOrder,
      required String checksum,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CardImagesTableUpdateCompanionBuilder =
    CardImagesCompanion Function({
      Value<String> id,
      Value<String> cardItemId,
      Value<CardImageKind> kind,
      Value<String> relativePath,
      Value<int> sortOrder,
      Value<String> checksum,
      Value<DateTime> createdAt,
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

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
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

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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
          PrefetchHooks Function({bool cardItemId})
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
                Value<int> sortOrder = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardImagesCompanion(
                id: id,
                cardItemId: cardItemId,
                kind: kind,
                relativePath: relativePath,
                sortOrder: sortOrder,
                checksum: checksum,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String cardItemId,
                required CardImageKind kind,
                required String relativePath,
                Value<int> sortOrder = const Value.absent(),
                required String checksum,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CardImagesCompanion.insert(
                id: id,
                cardItemId: cardItemId,
                kind: kind,
                relativePath: relativePath,
                sortOrder: sortOrder,
                checksum: checksum,
                createdAt: createdAt,
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
          prefetchHooksCallback: ({cardItemId = false}) {
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
                return [];
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
      PrefetchHooks Function({bool cardItemId})
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
}
