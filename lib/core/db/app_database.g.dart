// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SchemaMetaTable extends SchemaMeta
    with TableInfo<$SchemaMetaTable, SchemaMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchemaMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SchemaMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchemaMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SchemaMetaTable createAlias(String alias) {
    return $SchemaMetaTable(attachedDatabase, alias);
  }
}

class SchemaMetaData extends DataClass implements Insertable<SchemaMetaData> {
  final String key;
  final String value;
  const SchemaMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SchemaMetaCompanion toCompanion(bool nullToAbsent) {
    return SchemaMetaCompanion(key: Value(key), value: Value(value));
  }

  factory SchemaMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchemaMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SchemaMetaData copyWith({String? key, String? value}) =>
      SchemaMetaData(key: key ?? this.key, value: value ?? this.value);
  SchemaMetaData copyWithCompanion(SchemaMetaCompanion data) {
    return SchemaMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchemaMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SchemaMetaCompanion extends UpdateCompanion<SchemaMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SchemaMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchemaMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SchemaMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchemaMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SchemaMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
    'difficulty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryMusclesMeta = const VerificationMeta(
    'primaryMuscles',
  );
  @override
  late final GeneratedColumn<String> primaryMuscles = GeneratedColumn<String>(
    'primary_muscles',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _muscleGroupsMeta = const VerificationMeta(
    'muscleGroups',
  );
  @override
  late final GeneratedColumn<String> muscleGroups = GeneratedColumn<String>(
    'muscle_groups',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modalityMeta = const VerificationMeta(
    'modality',
  );
  @override
  late final GeneratedColumn<String> modality = GeneratedColumn<String>(
    'modality',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _forceMeta = const VerificationMeta('force');
  @override
  late final GeneratedColumn<String> force = GeneratedColumn<String>(
    'force',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mechanicMeta = const VerificationMeta(
    'mechanic',
  );
  @override
  late final GeneratedColumn<String> mechanic = GeneratedColumn<String>(
    'mechanic',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gripsMeta = const VerificationMeta('grips');
  @override
  late final GeneratedColumn<String> grips = GeneratedColumn<String>(
    'grips',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<int> externalId = GeneratedColumn<int>(
    'external_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    difficulty,
    primaryMuscles,
    muscleGroups,
    category,
    modality,
    equipment,
    force,
    mechanic,
    grips,
    steps,
    source,
    isFavorite,
    externalId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('primary_muscles')) {
      context.handle(
        _primaryMusclesMeta,
        primaryMuscles.isAcceptableOrUnknown(
          data['primary_muscles']!,
          _primaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('muscle_groups')) {
      context.handle(
        _muscleGroupsMeta,
        muscleGroups.isAcceptableOrUnknown(
          data['muscle_groups']!,
          _muscleGroupsMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('modality')) {
      context.handle(
        _modalityMeta,
        modality.isAcceptableOrUnknown(data['modality']!, _modalityMeta),
      );
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    }
    if (data.containsKey('force')) {
      context.handle(
        _forceMeta,
        force.isAcceptableOrUnknown(data['force']!, _forceMeta),
      );
    }
    if (data.containsKey('mechanic')) {
      context.handle(
        _mechanicMeta,
        mechanic.isAcceptableOrUnknown(data['mechanic']!, _mechanicMeta),
      );
    }
    if (data.containsKey('grips')) {
      context.handle(
        _gripsMeta,
        grips.isAcceptableOrUnknown(data['grips']!, _gripsMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      primaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles'],
      ),
      muscleGroups: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_groups'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      modality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modality'],
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      ),
      force: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}force'],
      ),
      mechanic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mechanic'],
      ),
      grips: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grips'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}external_id'],
      ),
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final String name;
  final String? difficulty;
  final String? primaryMuscles;
  final String? muscleGroups;
  final String? category;
  final String? modality;
  final String? equipment;
  final String? force;
  final String? mechanic;
  final String? grips;
  final String? steps;
  final String source;
  final bool isFavorite;
  final int? externalId;
  const Exercise({
    required this.id,
    required this.name,
    this.difficulty,
    this.primaryMuscles,
    this.muscleGroups,
    this.category,
    this.modality,
    this.equipment,
    this.force,
    this.mechanic,
    this.grips,
    this.steps,
    required this.source,
    required this.isFavorite,
    this.externalId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    if (!nullToAbsent || primaryMuscles != null) {
      map['primary_muscles'] = Variable<String>(primaryMuscles);
    }
    if (!nullToAbsent || muscleGroups != null) {
      map['muscle_groups'] = Variable<String>(muscleGroups);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || modality != null) {
      map['modality'] = Variable<String>(modality);
    }
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    if (!nullToAbsent || force != null) {
      map['force'] = Variable<String>(force);
    }
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(mechanic);
    }
    if (!nullToAbsent || grips != null) {
      map['grips'] = Variable<String>(grips);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<String>(steps);
    }
    map['source'] = Variable<String>(source);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || externalId != null) {
      map['external_id'] = Variable<int>(externalId);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      primaryMuscles: primaryMuscles == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryMuscles),
      muscleGroups: muscleGroups == null && nullToAbsent
          ? const Value.absent()
          : Value(muscleGroups),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      modality: modality == null && nullToAbsent
          ? const Value.absent()
          : Value(modality),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      force: force == null && nullToAbsent
          ? const Value.absent()
          : Value(force),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      grips: grips == null && nullToAbsent
          ? const Value.absent()
          : Value(grips),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
      source: Value(source),
      isFavorite: Value(isFavorite),
      externalId: externalId == null && nullToAbsent
          ? const Value.absent()
          : Value(externalId),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      primaryMuscles: serializer.fromJson<String?>(json['primaryMuscles']),
      muscleGroups: serializer.fromJson<String?>(json['muscleGroups']),
      category: serializer.fromJson<String?>(json['category']),
      modality: serializer.fromJson<String?>(json['modality']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      force: serializer.fromJson<String?>(json['force']),
      mechanic: serializer.fromJson<String?>(json['mechanic']),
      grips: serializer.fromJson<String?>(json['grips']),
      steps: serializer.fromJson<String?>(json['steps']),
      source: serializer.fromJson<String>(json['source']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      externalId: serializer.fromJson<int?>(json['externalId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'difficulty': serializer.toJson<String?>(difficulty),
      'primaryMuscles': serializer.toJson<String?>(primaryMuscles),
      'muscleGroups': serializer.toJson<String?>(muscleGroups),
      'category': serializer.toJson<String?>(category),
      'modality': serializer.toJson<String?>(modality),
      'equipment': serializer.toJson<String?>(equipment),
      'force': serializer.toJson<String?>(force),
      'mechanic': serializer.toJson<String?>(mechanic),
      'grips': serializer.toJson<String?>(grips),
      'steps': serializer.toJson<String?>(steps),
      'source': serializer.toJson<String>(source),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'externalId': serializer.toJson<int?>(externalId),
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    Value<String?> difficulty = const Value.absent(),
    Value<String?> primaryMuscles = const Value.absent(),
    Value<String?> muscleGroups = const Value.absent(),
    Value<String?> category = const Value.absent(),
    Value<String?> modality = const Value.absent(),
    Value<String?> equipment = const Value.absent(),
    Value<String?> force = const Value.absent(),
    Value<String?> mechanic = const Value.absent(),
    Value<String?> grips = const Value.absent(),
    Value<String?> steps = const Value.absent(),
    String? source,
    bool? isFavorite,
    Value<int?> externalId = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    name: name ?? this.name,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    primaryMuscles: primaryMuscles.present
        ? primaryMuscles.value
        : this.primaryMuscles,
    muscleGroups: muscleGroups.present ? muscleGroups.value : this.muscleGroups,
    category: category.present ? category.value : this.category,
    modality: modality.present ? modality.value : this.modality,
    equipment: equipment.present ? equipment.value : this.equipment,
    force: force.present ? force.value : this.force,
    mechanic: mechanic.present ? mechanic.value : this.mechanic,
    grips: grips.present ? grips.value : this.grips,
    steps: steps.present ? steps.value : this.steps,
    source: source ?? this.source,
    isFavorite: isFavorite ?? this.isFavorite,
    externalId: externalId.present ? externalId.value : this.externalId,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      primaryMuscles: data.primaryMuscles.present
          ? data.primaryMuscles.value
          : this.primaryMuscles,
      muscleGroups: data.muscleGroups.present
          ? data.muscleGroups.value
          : this.muscleGroups,
      category: data.category.present ? data.category.value : this.category,
      modality: data.modality.present ? data.modality.value : this.modality,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      force: data.force.present ? data.force.value : this.force,
      mechanic: data.mechanic.present ? data.mechanic.value : this.mechanic,
      grips: data.grips.present ? data.grips.value : this.grips,
      steps: data.steps.present ? data.steps.value : this.steps,
      source: data.source.present ? data.source.value : this.source,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('difficulty: $difficulty, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('muscleGroups: $muscleGroups, ')
          ..write('category: $category, ')
          ..write('modality: $modality, ')
          ..write('equipment: $equipment, ')
          ..write('force: $force, ')
          ..write('mechanic: $mechanic, ')
          ..write('grips: $grips, ')
          ..write('steps: $steps, ')
          ..write('source: $source, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    difficulty,
    primaryMuscles,
    muscleGroups,
    category,
    modality,
    equipment,
    force,
    mechanic,
    grips,
    steps,
    source,
    isFavorite,
    externalId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.name == this.name &&
          other.difficulty == this.difficulty &&
          other.primaryMuscles == this.primaryMuscles &&
          other.muscleGroups == this.muscleGroups &&
          other.category == this.category &&
          other.modality == this.modality &&
          other.equipment == this.equipment &&
          other.force == this.force &&
          other.mechanic == this.mechanic &&
          other.grips == this.grips &&
          other.steps == this.steps &&
          other.source == this.source &&
          other.isFavorite == this.isFavorite &&
          other.externalId == this.externalId);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> difficulty;
  final Value<String?> primaryMuscles;
  final Value<String?> muscleGroups;
  final Value<String?> category;
  final Value<String?> modality;
  final Value<String?> equipment;
  final Value<String?> force;
  final Value<String?> mechanic;
  final Value<String?> grips;
  final Value<String?> steps;
  final Value<String> source;
  final Value<bool> isFavorite;
  final Value<int?> externalId;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.muscleGroups = const Value.absent(),
    this.category = const Value.absent(),
    this.modality = const Value.absent(),
    this.equipment = const Value.absent(),
    this.force = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.grips = const Value.absent(),
    this.steps = const Value.absent(),
    this.source = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.externalId = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.difficulty = const Value.absent(),
    this.primaryMuscles = const Value.absent(),
    this.muscleGroups = const Value.absent(),
    this.category = const Value.absent(),
    this.modality = const Value.absent(),
    this.equipment = const Value.absent(),
    this.force = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.grips = const Value.absent(),
    this.steps = const Value.absent(),
    required String source,
    this.isFavorite = const Value.absent(),
    this.externalId = const Value.absent(),
  }) : name = Value(name),
       source = Value(source);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? difficulty,
    Expression<String>? primaryMuscles,
    Expression<String>? muscleGroups,
    Expression<String>? category,
    Expression<String>? modality,
    Expression<String>? equipment,
    Expression<String>? force,
    Expression<String>? mechanic,
    Expression<String>? grips,
    Expression<String>? steps,
    Expression<String>? source,
    Expression<bool>? isFavorite,
    Expression<int>? externalId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (difficulty != null) 'difficulty': difficulty,
      if (primaryMuscles != null) 'primary_muscles': primaryMuscles,
      if (muscleGroups != null) 'muscle_groups': muscleGroups,
      if (category != null) 'category': category,
      if (modality != null) 'modality': modality,
      if (equipment != null) 'equipment': equipment,
      if (force != null) 'force': force,
      if (mechanic != null) 'mechanic': mechanic,
      if (grips != null) 'grips': grips,
      if (steps != null) 'steps': steps,
      if (source != null) 'source': source,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (externalId != null) 'external_id': externalId,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? difficulty,
    Value<String?>? primaryMuscles,
    Value<String?>? muscleGroups,
    Value<String?>? category,
    Value<String?>? modality,
    Value<String?>? equipment,
    Value<String?>? force,
    Value<String?>? mechanic,
    Value<String?>? grips,
    Value<String?>? steps,
    Value<String>? source,
    Value<bool>? isFavorite,
    Value<int?>? externalId,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      muscleGroups: muscleGroups ?? this.muscleGroups,
      category: category ?? this.category,
      modality: modality ?? this.modality,
      equipment: equipment ?? this.equipment,
      force: force ?? this.force,
      mechanic: mechanic ?? this.mechanic,
      grips: grips ?? this.grips,
      steps: steps ?? this.steps,
      source: source ?? this.source,
      isFavorite: isFavorite ?? this.isFavorite,
      externalId: externalId ?? this.externalId,
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
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (primaryMuscles.present) {
      map['primary_muscles'] = Variable<String>(primaryMuscles.value);
    }
    if (muscleGroups.present) {
      map['muscle_groups'] = Variable<String>(muscleGroups.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (modality.present) {
      map['modality'] = Variable<String>(modality.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (force.present) {
      map['force'] = Variable<String>(force.value);
    }
    if (mechanic.present) {
      map['mechanic'] = Variable<String>(mechanic.value);
    }
    if (grips.present) {
      map['grips'] = Variable<String>(grips.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (externalId.present) {
      map['external_id'] = Variable<int>(externalId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('difficulty: $difficulty, ')
          ..write('primaryMuscles: $primaryMuscles, ')
          ..write('muscleGroups: $muscleGroups, ')
          ..write('category: $category, ')
          ..write('modality: $modality, ')
          ..write('equipment: $equipment, ')
          ..write('force: $force, ')
          ..write('mechanic: $mechanic, ')
          ..write('grips: $grips, ')
          ..write('steps: $steps, ')
          ..write('source: $source, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('externalId: $externalId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchemaMetaTable schemaMeta = $SchemaMetaTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [schemaMeta, exercises];
}

typedef $$SchemaMetaTableCreateCompanionBuilder =
    SchemaMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SchemaMetaTableUpdateCompanionBuilder =
    SchemaMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SchemaMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchemaMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchemaMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchemaMetaTable> {
  $$SchemaMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SchemaMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchemaMetaTable,
          SchemaMetaData,
          $$SchemaMetaTableFilterComposer,
          $$SchemaMetaTableOrderingComposer,
          $$SchemaMetaTableAnnotationComposer,
          $$SchemaMetaTableCreateCompanionBuilder,
          $$SchemaMetaTableUpdateCompanionBuilder,
          (
            SchemaMetaData,
            BaseReferences<_$AppDatabase, $SchemaMetaTable, SchemaMetaData>,
          ),
          SchemaMetaData,
          PrefetchHooks Function()
        > {
  $$SchemaMetaTableTableManager(_$AppDatabase db, $SchemaMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchemaMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchemaMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchemaMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SchemaMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchemaMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchemaMetaTable,
      SchemaMetaData,
      $$SchemaMetaTableFilterComposer,
      $$SchemaMetaTableOrderingComposer,
      $$SchemaMetaTableAnnotationComposer,
      $$SchemaMetaTableCreateCompanionBuilder,
      $$SchemaMetaTableUpdateCompanionBuilder,
      (
        SchemaMetaData,
        BaseReferences<_$AppDatabase, $SchemaMetaTable, SchemaMetaData>,
      ),
      SchemaMetaData,
      PrefetchHooks Function()
    >;
typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> difficulty,
      Value<String?> primaryMuscles,
      Value<String?> muscleGroups,
      Value<String?> category,
      Value<String?> modality,
      Value<String?> equipment,
      Value<String?> force,
      Value<String?> mechanic,
      Value<String?> grips,
      Value<String?> steps,
      required String source,
      Value<bool> isFavorite,
      Value<int?> externalId,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> difficulty,
      Value<String?> primaryMuscles,
      Value<String?> muscleGroups,
      Value<String?> category,
      Value<String?> modality,
      Value<String?> equipment,
      Value<String?> force,
      Value<String?> mechanic,
      Value<String?> grips,
      Value<String?> steps,
      Value<String> source,
      Value<bool> isFavorite,
      Value<int?> externalId,
    });

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroups => $composableBuilder(
    column: $table.muscleGroups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grips => $composableBuilder(
    column: $table.grips,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroups => $composableBuilder(
    column: $table.muscleGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modality => $composableBuilder(
    column: $table.modality,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get force => $composableBuilder(
    column: $table.force,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mechanic => $composableBuilder(
    column: $table.mechanic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grips => $composableBuilder(
    column: $table.grips,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryMuscles => $composableBuilder(
    column: $table.primaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<String> get muscleGroups => $composableBuilder(
    column: $table.muscleGroups,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get modality =>
      $composableBuilder(column: $table.modality, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get force =>
      $composableBuilder(column: $table.force, builder: (column) => column);

  GeneratedColumn<String> get mechanic =>
      $composableBuilder(column: $table.mechanic, builder: (column) => column);

  GeneratedColumn<String> get grips =>
      $composableBuilder(column: $table.grips, builder: (column) => column);

  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
          Exercise,
          PrefetchHooks Function()
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<String?> primaryMuscles = const Value.absent(),
                Value<String?> muscleGroups = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> modality = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> grips = const Value.absent(),
                Value<String?> steps = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> externalId = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                difficulty: difficulty,
                primaryMuscles: primaryMuscles,
                muscleGroups: muscleGroups,
                category: category,
                modality: modality,
                equipment: equipment,
                force: force,
                mechanic: mechanic,
                grips: grips,
                steps: steps,
                source: source,
                isFavorite: isFavorite,
                externalId: externalId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> difficulty = const Value.absent(),
                Value<String?> primaryMuscles = const Value.absent(),
                Value<String?> muscleGroups = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String?> modality = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String?> grips = const Value.absent(),
                Value<String?> steps = const Value.absent(),
                required String source,
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> externalId = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                difficulty: difficulty,
                primaryMuscles: primaryMuscles,
                muscleGroups: muscleGroups,
                category: category,
                modality: modality,
                equipment: equipment,
                force: force,
                mechanic: mechanic,
                grips: grips,
                steps: steps,
                source: source,
                isFavorite: isFavorite,
                externalId: externalId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, BaseReferences<_$AppDatabase, $ExercisesTable, Exercise>),
      Exercise,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchemaMetaTableTableManager get schemaMeta =>
      $$SchemaMetaTableTableManager(_db, _db.schemaMeta);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
}
