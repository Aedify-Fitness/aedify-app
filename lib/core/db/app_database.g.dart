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
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _customExerciseUuidMeta =
      const VerificationMeta('customExerciseUuid');
  @override
  late final GeneratedColumn<String> customExerciseUuid =
      GeneratedColumn<String>(
        'custom_exercise_uuid',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _sourceDatasetVersionMeta =
      const VerificationMeta('sourceDatasetVersion');
  @override
  late final GeneratedColumn<String> sourceDatasetVersion =
      GeneratedColumn<String>(
        'source_dataset_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sourceSchemaVersionMeta =
      const VerificationMeta('sourceSchemaVersion');
  @override
  late final GeneratedColumn<int> sourceSchemaVersion = GeneratedColumn<int>(
    'source_schema_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _nameNormalizedMeta = const VerificationMeta(
    'nameNormalized',
  );
  @override
  late final GeneratedColumn<String> nameNormalized = GeneratedColumn<String>(
    'name_normalized',
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
  static const VerificationMeta _primaryMusclesJsonMeta =
      const VerificationMeta('primaryMusclesJson');
  @override
  late final GeneratedColumn<String> primaryMusclesJson =
      GeneratedColumn<String>(
        'primary_muscles_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _muscleGroupsJsonMeta = const VerificationMeta(
    'muscleGroupsJson',
  );
  @override
  late final GeneratedColumn<String> muscleGroupsJson = GeneratedColumn<String>(
    'muscle_groups_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _gripsJsonMeta = const VerificationMeta(
    'gripsJson',
  );
  @override
  late final GeneratedColumn<String> gripsJson = GeneratedColumn<String>(
    'grips_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsJsonMeta = const VerificationMeta(
    'stepsJson',
  );
  @override
  late final GeneratedColumn<String> stepsJson = GeneratedColumn<String>(
    'steps_json',
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
  static const VerificationMeta _isSubstitutedOutMeta = const VerificationMeta(
    'isSubstitutedOut',
  );
  @override
  late final GeneratedColumn<bool> isSubstitutedOut = GeneratedColumn<bool>(
    'is_substituted_out',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_substituted_out" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userNotesMeta = const VerificationMeta(
    'userNotes',
  );
  @override
  late final GeneratedColumn<String> userNotes = GeneratedColumn<String>(
    'user_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedFromShareMeta = const VerificationMeta(
    'importedFromShare',
  );
  @override
  late final GeneratedColumn<bool> importedFromShare = GeneratedColumn<bool>(
    'imported_from_share',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("imported_from_share" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _originalShareKeyMeta = const VerificationMeta(
    'originalShareKey',
  );
  @override
  late final GeneratedColumn<String> originalShareKey = GeneratedColumn<String>(
    'original_share_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    isCustom,
    customExerciseUuid,
    source,
    sourceDatasetVersion,
    sourceSchemaVersion,
    name,
    nameNormalized,
    difficulty,
    primaryMusclesJson,
    muscleGroupsJson,
    category,
    modality,
    equipment,
    force,
    mechanic,
    gripsJson,
    stepsJson,
    isFavorite,
    isSubstitutedOut,
    userNotes,
    importedFromShare,
    originalShareKey,
    createdAt,
    updatedAt,
    deletedAt,
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
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('custom_exercise_uuid')) {
      context.handle(
        _customExerciseUuidMeta,
        customExerciseUuid.isAcceptableOrUnknown(
          data['custom_exercise_uuid']!,
          _customExerciseUuidMeta,
        ),
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
    if (data.containsKey('source_dataset_version')) {
      context.handle(
        _sourceDatasetVersionMeta,
        sourceDatasetVersion.isAcceptableOrUnknown(
          data['source_dataset_version']!,
          _sourceDatasetVersionMeta,
        ),
      );
    }
    if (data.containsKey('source_schema_version')) {
      context.handle(
        _sourceSchemaVersionMeta,
        sourceSchemaVersion.isAcceptableOrUnknown(
          data['source_schema_version']!,
          _sourceSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_normalized')) {
      context.handle(
        _nameNormalizedMeta,
        nameNormalized.isAcceptableOrUnknown(
          data['name_normalized']!,
          _nameNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameNormalizedMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    if (data.containsKey('primary_muscles_json')) {
      context.handle(
        _primaryMusclesJsonMeta,
        primaryMusclesJson.isAcceptableOrUnknown(
          data['primary_muscles_json']!,
          _primaryMusclesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryMusclesJsonMeta);
    }
    if (data.containsKey('muscle_groups_json')) {
      context.handle(
        _muscleGroupsJsonMeta,
        muscleGroupsJson.isAcceptableOrUnknown(
          data['muscle_groups_json']!,
          _muscleGroupsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_muscleGroupsJsonMeta);
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
    } else if (isInserting) {
      context.missing(_modalityMeta);
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
    if (data.containsKey('grips_json')) {
      context.handle(
        _gripsJsonMeta,
        gripsJson.isAcceptableOrUnknown(data['grips_json']!, _gripsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_gripsJsonMeta);
    }
    if (data.containsKey('steps_json')) {
      context.handle(
        _stepsJsonMeta,
        stepsJson.isAcceptableOrUnknown(data['steps_json']!, _stepsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsJsonMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_substituted_out')) {
      context.handle(
        _isSubstitutedOutMeta,
        isSubstitutedOut.isAcceptableOrUnknown(
          data['is_substituted_out']!,
          _isSubstitutedOutMeta,
        ),
      );
    }
    if (data.containsKey('user_notes')) {
      context.handle(
        _userNotesMeta,
        userNotes.isAcceptableOrUnknown(data['user_notes']!, _userNotesMeta),
      );
    }
    if (data.containsKey('imported_from_share')) {
      context.handle(
        _importedFromShareMeta,
        importedFromShare.isAcceptableOrUnknown(
          data['imported_from_share']!,
          _importedFromShareMeta,
        ),
      );
    }
    if (data.containsKey('original_share_key')) {
      context.handle(
        _originalShareKeyMeta,
        originalShareKey.isAcceptableOrUnknown(
          data['original_share_key']!,
          _originalShareKeyMeta,
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
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      customExerciseUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_exercise_uuid'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceDatasetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_dataset_version'],
      ),
      sourceSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_schema_version'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_normalized'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}difficulty'],
      ),
      primaryMusclesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscles_json'],
      )!,
      muscleGroupsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}muscle_groups_json'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      modality: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modality'],
      )!,
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
      gripsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grips_json'],
      )!,
      stepsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps_json'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isSubstitutedOut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_substituted_out'],
      )!,
      userNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_notes'],
      ),
      importedFromShare: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}imported_from_share'],
      )!,
      originalShareKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_share_key'],
      ),
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
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final int id;
  final bool isCustom;
  final String? customExerciseUuid;
  final String source;
  final String? sourceDatasetVersion;
  final int? sourceSchemaVersion;
  final String name;
  final String nameNormalized;
  final String? difficulty;
  final String primaryMusclesJson;
  final String muscleGroupsJson;
  final String? category;
  final String modality;
  final String? equipment;
  final String? force;
  final String? mechanic;
  final String gripsJson;
  final String stepsJson;
  final bool isFavorite;
  final bool isSubstitutedOut;
  final String? userNotes;
  final bool importedFromShare;
  final String? originalShareKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const Exercise({
    required this.id,
    required this.isCustom,
    this.customExerciseUuid,
    required this.source,
    this.sourceDatasetVersion,
    this.sourceSchemaVersion,
    required this.name,
    required this.nameNormalized,
    this.difficulty,
    required this.primaryMusclesJson,
    required this.muscleGroupsJson,
    this.category,
    required this.modality,
    this.equipment,
    this.force,
    this.mechanic,
    required this.gripsJson,
    required this.stepsJson,
    required this.isFavorite,
    required this.isSubstitutedOut,
    this.userNotes,
    required this.importedFromShare,
    this.originalShareKey,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || customExerciseUuid != null) {
      map['custom_exercise_uuid'] = Variable<String>(customExerciseUuid);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceDatasetVersion != null) {
      map['source_dataset_version'] = Variable<String>(sourceDatasetVersion);
    }
    if (!nullToAbsent || sourceSchemaVersion != null) {
      map['source_schema_version'] = Variable<int>(sourceSchemaVersion);
    }
    map['name'] = Variable<String>(name);
    map['name_normalized'] = Variable<String>(nameNormalized);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    map['primary_muscles_json'] = Variable<String>(primaryMusclesJson);
    map['muscle_groups_json'] = Variable<String>(muscleGroupsJson);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['modality'] = Variable<String>(modality);
    if (!nullToAbsent || equipment != null) {
      map['equipment'] = Variable<String>(equipment);
    }
    if (!nullToAbsent || force != null) {
      map['force'] = Variable<String>(force);
    }
    if (!nullToAbsent || mechanic != null) {
      map['mechanic'] = Variable<String>(mechanic);
    }
    map['grips_json'] = Variable<String>(gripsJson);
    map['steps_json'] = Variable<String>(stepsJson);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_substituted_out'] = Variable<bool>(isSubstitutedOut);
    if (!nullToAbsent || userNotes != null) {
      map['user_notes'] = Variable<String>(userNotes);
    }
    map['imported_from_share'] = Variable<bool>(importedFromShare);
    if (!nullToAbsent || originalShareKey != null) {
      map['original_share_key'] = Variable<String>(originalShareKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      isCustom: Value(isCustom),
      customExerciseUuid: customExerciseUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(customExerciseUuid),
      source: Value(source),
      sourceDatasetVersion: sourceDatasetVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceDatasetVersion),
      sourceSchemaVersion: sourceSchemaVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceSchemaVersion),
      name: Value(name),
      nameNormalized: Value(nameNormalized),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      primaryMusclesJson: Value(primaryMusclesJson),
      muscleGroupsJson: Value(muscleGroupsJson),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      modality: Value(modality),
      equipment: equipment == null && nullToAbsent
          ? const Value.absent()
          : Value(equipment),
      force: force == null && nullToAbsent
          ? const Value.absent()
          : Value(force),
      mechanic: mechanic == null && nullToAbsent
          ? const Value.absent()
          : Value(mechanic),
      gripsJson: Value(gripsJson),
      stepsJson: Value(stepsJson),
      isFavorite: Value(isFavorite),
      isSubstitutedOut: Value(isSubstitutedOut),
      userNotes: userNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(userNotes),
      importedFromShare: Value(importedFromShare),
      originalShareKey: originalShareKey == null && nullToAbsent
          ? const Value.absent()
          : Value(originalShareKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<int>(json['id']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      customExerciseUuid: serializer.fromJson<String?>(
        json['customExerciseUuid'],
      ),
      source: serializer.fromJson<String>(json['source']),
      sourceDatasetVersion: serializer.fromJson<String?>(
        json['sourceDatasetVersion'],
      ),
      sourceSchemaVersion: serializer.fromJson<int?>(
        json['sourceSchemaVersion'],
      ),
      name: serializer.fromJson<String>(json['name']),
      nameNormalized: serializer.fromJson<String>(json['nameNormalized']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      primaryMusclesJson: serializer.fromJson<String>(
        json['primaryMusclesJson'],
      ),
      muscleGroupsJson: serializer.fromJson<String>(json['muscleGroupsJson']),
      category: serializer.fromJson<String?>(json['category']),
      modality: serializer.fromJson<String>(json['modality']),
      equipment: serializer.fromJson<String?>(json['equipment']),
      force: serializer.fromJson<String?>(json['force']),
      mechanic: serializer.fromJson<String?>(json['mechanic']),
      gripsJson: serializer.fromJson<String>(json['gripsJson']),
      stepsJson: serializer.fromJson<String>(json['stepsJson']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isSubstitutedOut: serializer.fromJson<bool>(json['isSubstitutedOut']),
      userNotes: serializer.fromJson<String?>(json['userNotes']),
      importedFromShare: serializer.fromJson<bool>(json['importedFromShare']),
      originalShareKey: serializer.fromJson<String?>(json['originalShareKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'isCustom': serializer.toJson<bool>(isCustom),
      'customExerciseUuid': serializer.toJson<String?>(customExerciseUuid),
      'source': serializer.toJson<String>(source),
      'sourceDatasetVersion': serializer.toJson<String?>(sourceDatasetVersion),
      'sourceSchemaVersion': serializer.toJson<int?>(sourceSchemaVersion),
      'name': serializer.toJson<String>(name),
      'nameNormalized': serializer.toJson<String>(nameNormalized),
      'difficulty': serializer.toJson<String?>(difficulty),
      'primaryMusclesJson': serializer.toJson<String>(primaryMusclesJson),
      'muscleGroupsJson': serializer.toJson<String>(muscleGroupsJson),
      'category': serializer.toJson<String?>(category),
      'modality': serializer.toJson<String>(modality),
      'equipment': serializer.toJson<String?>(equipment),
      'force': serializer.toJson<String?>(force),
      'mechanic': serializer.toJson<String?>(mechanic),
      'gripsJson': serializer.toJson<String>(gripsJson),
      'stepsJson': serializer.toJson<String>(stepsJson),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isSubstitutedOut': serializer.toJson<bool>(isSubstitutedOut),
      'userNotes': serializer.toJson<String?>(userNotes),
      'importedFromShare': serializer.toJson<bool>(importedFromShare),
      'originalShareKey': serializer.toJson<String?>(originalShareKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Exercise copyWith({
    int? id,
    bool? isCustom,
    Value<String?> customExerciseUuid = const Value.absent(),
    String? source,
    Value<String?> sourceDatasetVersion = const Value.absent(),
    Value<int?> sourceSchemaVersion = const Value.absent(),
    String? name,
    String? nameNormalized,
    Value<String?> difficulty = const Value.absent(),
    String? primaryMusclesJson,
    String? muscleGroupsJson,
    Value<String?> category = const Value.absent(),
    String? modality,
    Value<String?> equipment = const Value.absent(),
    Value<String?> force = const Value.absent(),
    Value<String?> mechanic = const Value.absent(),
    String? gripsJson,
    String? stepsJson,
    bool? isFavorite,
    bool? isSubstitutedOut,
    Value<String?> userNotes = const Value.absent(),
    bool? importedFromShare,
    Value<String?> originalShareKey = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Exercise(
    id: id ?? this.id,
    isCustom: isCustom ?? this.isCustom,
    customExerciseUuid: customExerciseUuid.present
        ? customExerciseUuid.value
        : this.customExerciseUuid,
    source: source ?? this.source,
    sourceDatasetVersion: sourceDatasetVersion.present
        ? sourceDatasetVersion.value
        : this.sourceDatasetVersion,
    sourceSchemaVersion: sourceSchemaVersion.present
        ? sourceSchemaVersion.value
        : this.sourceSchemaVersion,
    name: name ?? this.name,
    nameNormalized: nameNormalized ?? this.nameNormalized,
    difficulty: difficulty.present ? difficulty.value : this.difficulty,
    primaryMusclesJson: primaryMusclesJson ?? this.primaryMusclesJson,
    muscleGroupsJson: muscleGroupsJson ?? this.muscleGroupsJson,
    category: category.present ? category.value : this.category,
    modality: modality ?? this.modality,
    equipment: equipment.present ? equipment.value : this.equipment,
    force: force.present ? force.value : this.force,
    mechanic: mechanic.present ? mechanic.value : this.mechanic,
    gripsJson: gripsJson ?? this.gripsJson,
    stepsJson: stepsJson ?? this.stepsJson,
    isFavorite: isFavorite ?? this.isFavorite,
    isSubstitutedOut: isSubstitutedOut ?? this.isSubstitutedOut,
    userNotes: userNotes.present ? userNotes.value : this.userNotes,
    importedFromShare: importedFromShare ?? this.importedFromShare,
    originalShareKey: originalShareKey.present
        ? originalShareKey.value
        : this.originalShareKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      customExerciseUuid: data.customExerciseUuid.present
          ? data.customExerciseUuid.value
          : this.customExerciseUuid,
      source: data.source.present ? data.source.value : this.source,
      sourceDatasetVersion: data.sourceDatasetVersion.present
          ? data.sourceDatasetVersion.value
          : this.sourceDatasetVersion,
      sourceSchemaVersion: data.sourceSchemaVersion.present
          ? data.sourceSchemaVersion.value
          : this.sourceSchemaVersion,
      name: data.name.present ? data.name.value : this.name,
      nameNormalized: data.nameNormalized.present
          ? data.nameNormalized.value
          : this.nameNormalized,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      primaryMusclesJson: data.primaryMusclesJson.present
          ? data.primaryMusclesJson.value
          : this.primaryMusclesJson,
      muscleGroupsJson: data.muscleGroupsJson.present
          ? data.muscleGroupsJson.value
          : this.muscleGroupsJson,
      category: data.category.present ? data.category.value : this.category,
      modality: data.modality.present ? data.modality.value : this.modality,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      force: data.force.present ? data.force.value : this.force,
      mechanic: data.mechanic.present ? data.mechanic.value : this.mechanic,
      gripsJson: data.gripsJson.present ? data.gripsJson.value : this.gripsJson,
      stepsJson: data.stepsJson.present ? data.stepsJson.value : this.stepsJson,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isSubstitutedOut: data.isSubstitutedOut.present
          ? data.isSubstitutedOut.value
          : this.isSubstitutedOut,
      userNotes: data.userNotes.present ? data.userNotes.value : this.userNotes,
      importedFromShare: data.importedFromShare.present
          ? data.importedFromShare.value
          : this.importedFromShare,
      originalShareKey: data.originalShareKey.present
          ? data.originalShareKey.value
          : this.originalShareKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('isCustom: $isCustom, ')
          ..write('customExerciseUuid: $customExerciseUuid, ')
          ..write('source: $source, ')
          ..write('sourceDatasetVersion: $sourceDatasetVersion, ')
          ..write('sourceSchemaVersion: $sourceSchemaVersion, ')
          ..write('name: $name, ')
          ..write('nameNormalized: $nameNormalized, ')
          ..write('difficulty: $difficulty, ')
          ..write('primaryMusclesJson: $primaryMusclesJson, ')
          ..write('muscleGroupsJson: $muscleGroupsJson, ')
          ..write('category: $category, ')
          ..write('modality: $modality, ')
          ..write('equipment: $equipment, ')
          ..write('force: $force, ')
          ..write('mechanic: $mechanic, ')
          ..write('gripsJson: $gripsJson, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isSubstitutedOut: $isSubstitutedOut, ')
          ..write('userNotes: $userNotes, ')
          ..write('importedFromShare: $importedFromShare, ')
          ..write('originalShareKey: $originalShareKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    isCustom,
    customExerciseUuid,
    source,
    sourceDatasetVersion,
    sourceSchemaVersion,
    name,
    nameNormalized,
    difficulty,
    primaryMusclesJson,
    muscleGroupsJson,
    category,
    modality,
    equipment,
    force,
    mechanic,
    gripsJson,
    stepsJson,
    isFavorite,
    isSubstitutedOut,
    userNotes,
    importedFromShare,
    originalShareKey,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.isCustom == this.isCustom &&
          other.customExerciseUuid == this.customExerciseUuid &&
          other.source == this.source &&
          other.sourceDatasetVersion == this.sourceDatasetVersion &&
          other.sourceSchemaVersion == this.sourceSchemaVersion &&
          other.name == this.name &&
          other.nameNormalized == this.nameNormalized &&
          other.difficulty == this.difficulty &&
          other.primaryMusclesJson == this.primaryMusclesJson &&
          other.muscleGroupsJson == this.muscleGroupsJson &&
          other.category == this.category &&
          other.modality == this.modality &&
          other.equipment == this.equipment &&
          other.force == this.force &&
          other.mechanic == this.mechanic &&
          other.gripsJson == this.gripsJson &&
          other.stepsJson == this.stepsJson &&
          other.isFavorite == this.isFavorite &&
          other.isSubstitutedOut == this.isSubstitutedOut &&
          other.userNotes == this.userNotes &&
          other.importedFromShare == this.importedFromShare &&
          other.originalShareKey == this.originalShareKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<int> id;
  final Value<bool> isCustom;
  final Value<String?> customExerciseUuid;
  final Value<String> source;
  final Value<String?> sourceDatasetVersion;
  final Value<int?> sourceSchemaVersion;
  final Value<String> name;
  final Value<String> nameNormalized;
  final Value<String?> difficulty;
  final Value<String> primaryMusclesJson;
  final Value<String> muscleGroupsJson;
  final Value<String?> category;
  final Value<String> modality;
  final Value<String?> equipment;
  final Value<String?> force;
  final Value<String?> mechanic;
  final Value<String> gripsJson;
  final Value<String> stepsJson;
  final Value<bool> isFavorite;
  final Value<bool> isSubstitutedOut;
  final Value<String?> userNotes;
  final Value<bool> importedFromShare;
  final Value<String?> originalShareKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.customExerciseUuid = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceDatasetVersion = const Value.absent(),
    this.sourceSchemaVersion = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNormalized = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.primaryMusclesJson = const Value.absent(),
    this.muscleGroupsJson = const Value.absent(),
    this.category = const Value.absent(),
    this.modality = const Value.absent(),
    this.equipment = const Value.absent(),
    this.force = const Value.absent(),
    this.mechanic = const Value.absent(),
    this.gripsJson = const Value.absent(),
    this.stepsJson = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isSubstitutedOut = const Value.absent(),
    this.userNotes = const Value.absent(),
    this.importedFromShare = const Value.absent(),
    this.originalShareKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.customExerciseUuid = const Value.absent(),
    required String source,
    this.sourceDatasetVersion = const Value.absent(),
    this.sourceSchemaVersion = const Value.absent(),
    required String name,
    required String nameNormalized,
    this.difficulty = const Value.absent(),
    required String primaryMusclesJson,
    required String muscleGroupsJson,
    this.category = const Value.absent(),
    required String modality,
    this.equipment = const Value.absent(),
    this.force = const Value.absent(),
    this.mechanic = const Value.absent(),
    required String gripsJson,
    required String stepsJson,
    this.isFavorite = const Value.absent(),
    this.isSubstitutedOut = const Value.absent(),
    this.userNotes = const Value.absent(),
    this.importedFromShare = const Value.absent(),
    this.originalShareKey = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : source = Value(source),
       name = Value(name),
       nameNormalized = Value(nameNormalized),
       primaryMusclesJson = Value(primaryMusclesJson),
       muscleGroupsJson = Value(muscleGroupsJson),
       modality = Value(modality),
       gripsJson = Value(gripsJson),
       stepsJson = Value(stepsJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Exercise> custom({
    Expression<int>? id,
    Expression<bool>? isCustom,
    Expression<String>? customExerciseUuid,
    Expression<String>? source,
    Expression<String>? sourceDatasetVersion,
    Expression<int>? sourceSchemaVersion,
    Expression<String>? name,
    Expression<String>? nameNormalized,
    Expression<String>? difficulty,
    Expression<String>? primaryMusclesJson,
    Expression<String>? muscleGroupsJson,
    Expression<String>? category,
    Expression<String>? modality,
    Expression<String>? equipment,
    Expression<String>? force,
    Expression<String>? mechanic,
    Expression<String>? gripsJson,
    Expression<String>? stepsJson,
    Expression<bool>? isFavorite,
    Expression<bool>? isSubstitutedOut,
    Expression<String>? userNotes,
    Expression<bool>? importedFromShare,
    Expression<String>? originalShareKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (isCustom != null) 'is_custom': isCustom,
      if (customExerciseUuid != null)
        'custom_exercise_uuid': customExerciseUuid,
      if (source != null) 'source': source,
      if (sourceDatasetVersion != null)
        'source_dataset_version': sourceDatasetVersion,
      if (sourceSchemaVersion != null)
        'source_schema_version': sourceSchemaVersion,
      if (name != null) 'name': name,
      if (nameNormalized != null) 'name_normalized': nameNormalized,
      if (difficulty != null) 'difficulty': difficulty,
      if (primaryMusclesJson != null)
        'primary_muscles_json': primaryMusclesJson,
      if (muscleGroupsJson != null) 'muscle_groups_json': muscleGroupsJson,
      if (category != null) 'category': category,
      if (modality != null) 'modality': modality,
      if (equipment != null) 'equipment': equipment,
      if (force != null) 'force': force,
      if (mechanic != null) 'mechanic': mechanic,
      if (gripsJson != null) 'grips_json': gripsJson,
      if (stepsJson != null) 'steps_json': stepsJson,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isSubstitutedOut != null) 'is_substituted_out': isSubstitutedOut,
      if (userNotes != null) 'user_notes': userNotes,
      if (importedFromShare != null) 'imported_from_share': importedFromShare,
      if (originalShareKey != null) 'original_share_key': originalShareKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ExercisesCompanion copyWith({
    Value<int>? id,
    Value<bool>? isCustom,
    Value<String?>? customExerciseUuid,
    Value<String>? source,
    Value<String?>? sourceDatasetVersion,
    Value<int?>? sourceSchemaVersion,
    Value<String>? name,
    Value<String>? nameNormalized,
    Value<String?>? difficulty,
    Value<String>? primaryMusclesJson,
    Value<String>? muscleGroupsJson,
    Value<String?>? category,
    Value<String>? modality,
    Value<String?>? equipment,
    Value<String?>? force,
    Value<String?>? mechanic,
    Value<String>? gripsJson,
    Value<String>? stepsJson,
    Value<bool>? isFavorite,
    Value<bool>? isSubstitutedOut,
    Value<String?>? userNotes,
    Value<bool>? importedFromShare,
    Value<String?>? originalShareKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      isCustom: isCustom ?? this.isCustom,
      customExerciseUuid: customExerciseUuid ?? this.customExerciseUuid,
      source: source ?? this.source,
      sourceDatasetVersion: sourceDatasetVersion ?? this.sourceDatasetVersion,
      sourceSchemaVersion: sourceSchemaVersion ?? this.sourceSchemaVersion,
      name: name ?? this.name,
      nameNormalized: nameNormalized ?? this.nameNormalized,
      difficulty: difficulty ?? this.difficulty,
      primaryMusclesJson: primaryMusclesJson ?? this.primaryMusclesJson,
      muscleGroupsJson: muscleGroupsJson ?? this.muscleGroupsJson,
      category: category ?? this.category,
      modality: modality ?? this.modality,
      equipment: equipment ?? this.equipment,
      force: force ?? this.force,
      mechanic: mechanic ?? this.mechanic,
      gripsJson: gripsJson ?? this.gripsJson,
      stepsJson: stepsJson ?? this.stepsJson,
      isFavorite: isFavorite ?? this.isFavorite,
      isSubstitutedOut: isSubstitutedOut ?? this.isSubstitutedOut,
      userNotes: userNotes ?? this.userNotes,
      importedFromShare: importedFromShare ?? this.importedFromShare,
      originalShareKey: originalShareKey ?? this.originalShareKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (customExerciseUuid.present) {
      map['custom_exercise_uuid'] = Variable<String>(customExerciseUuid.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceDatasetVersion.present) {
      map['source_dataset_version'] = Variable<String>(
        sourceDatasetVersion.value,
      );
    }
    if (sourceSchemaVersion.present) {
      map['source_schema_version'] = Variable<int>(sourceSchemaVersion.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNormalized.present) {
      map['name_normalized'] = Variable<String>(nameNormalized.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (primaryMusclesJson.present) {
      map['primary_muscles_json'] = Variable<String>(primaryMusclesJson.value);
    }
    if (muscleGroupsJson.present) {
      map['muscle_groups_json'] = Variable<String>(muscleGroupsJson.value);
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
    if (gripsJson.present) {
      map['grips_json'] = Variable<String>(gripsJson.value);
    }
    if (stepsJson.present) {
      map['steps_json'] = Variable<String>(stepsJson.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isSubstitutedOut.present) {
      map['is_substituted_out'] = Variable<bool>(isSubstitutedOut.value);
    }
    if (userNotes.present) {
      map['user_notes'] = Variable<String>(userNotes.value);
    }
    if (importedFromShare.present) {
      map['imported_from_share'] = Variable<bool>(importedFromShare.value);
    }
    if (originalShareKey.present) {
      map['original_share_key'] = Variable<String>(originalShareKey.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('isCustom: $isCustom, ')
          ..write('customExerciseUuid: $customExerciseUuid, ')
          ..write('source: $source, ')
          ..write('sourceDatasetVersion: $sourceDatasetVersion, ')
          ..write('sourceSchemaVersion: $sourceSchemaVersion, ')
          ..write('name: $name, ')
          ..write('nameNormalized: $nameNormalized, ')
          ..write('difficulty: $difficulty, ')
          ..write('primaryMusclesJson: $primaryMusclesJson, ')
          ..write('muscleGroupsJson: $muscleGroupsJson, ')
          ..write('category: $category, ')
          ..write('modality: $modality, ')
          ..write('equipment: $equipment, ')
          ..write('force: $force, ')
          ..write('mechanic: $mechanic, ')
          ..write('gripsJson: $gripsJson, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isSubstitutedOut: $isSubstitutedOut, ')
          ..write('userNotes: $userNotes, ')
          ..write('importedFromShare: $importedFromShare, ')
          ..write('originalShareKey: $originalShareKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $LocalFileRecordsTable extends LocalFileRecords
    with TableInfo<$LocalFileRecordsTable, LocalFileRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalFileRecordsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerTypeMeta = const VerificationMeta(
    'ownerType',
  );
  @override
  late final GeneratedColumn<String> ownerType = GeneratedColumn<String>(
    'owner_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localRelativePathMeta = const VerificationMeta(
    'localRelativePath',
  );
  @override
  late final GeneratedColumn<String> localRelativePath =
      GeneratedColumn<String>(
        'local_relative_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
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
  static const VerificationMeta _lastVerifiedAtMeta = const VerificationMeta(
    'lastVerifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastVerifiedAt =
      GeneratedColumn<DateTime>(
        'last_verified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    ownerType,
    ownerId,
    localRelativePath,
    fileSizeBytes,
    contentHash,
    mimeType,
    width,
    height,
    durationSeconds,
    createdAt,
    lastVerifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_file_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalFileRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('owner_type')) {
      context.handle(
        _ownerTypeMeta,
        ownerType.isAcceptableOrUnknown(data['owner_type']!, _ownerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerTypeMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    }
    if (data.containsKey('local_relative_path')) {
      context.handle(
        _localRelativePathMeta,
        localRelativePath.isAcceptableOrUnknown(
          data['local_relative_path']!,
          _localRelativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localRelativePathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
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
    if (data.containsKey('last_verified_at')) {
      context.handle(
        _lastVerifiedAtMeta,
        lastVerifiedAt.isAcceptableOrUnknown(
          data['last_verified_at']!,
          _lastVerifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalFileRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalFileRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      ownerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_type'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      ),
      localRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_relative_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastVerifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_verified_at'],
      ),
    );
  }

  @override
  $LocalFileRecordsTable createAlias(String alias) {
    return $LocalFileRecordsTable(attachedDatabase, alias);
  }
}

class LocalFileRecord extends DataClass implements Insertable<LocalFileRecord> {
  final int id;
  final String category;
  final String ownerType;
  final String? ownerId;
  final String localRelativePath;
  final int fileSizeBytes;
  final String? contentHash;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final DateTime createdAt;
  final DateTime? lastVerifiedAt;
  const LocalFileRecord({
    required this.id,
    required this.category,
    required this.ownerType,
    this.ownerId,
    required this.localRelativePath,
    required this.fileSizeBytes,
    this.contentHash,
    this.mimeType,
    this.width,
    this.height,
    this.durationSeconds,
    required this.createdAt,
    this.lastVerifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['category'] = Variable<String>(category);
    map['owner_type'] = Variable<String>(ownerType);
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['local_relative_path'] = Variable<String>(localRelativePath);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastVerifiedAt != null) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt);
    }
    return map;
  }

  LocalFileRecordsCompanion toCompanion(bool nullToAbsent) {
    return LocalFileRecordsCompanion(
      id: Value(id),
      category: Value(category),
      ownerType: Value(ownerType),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      localRelativePath: Value(localRelativePath),
      fileSizeBytes: Value(fileSizeBytes),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      createdAt: Value(createdAt),
      lastVerifiedAt: lastVerifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerifiedAt),
    );
  }

  factory LocalFileRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalFileRecord(
      id: serializer.fromJson<int>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      ownerType: serializer.fromJson<String>(json['ownerType']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      localRelativePath: serializer.fromJson<String>(json['localRelativePath']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      contentHash: serializer.fromJson<String?>(json['contentHash']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastVerifiedAt: serializer.fromJson<DateTime?>(json['lastVerifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'category': serializer.toJson<String>(category),
      'ownerType': serializer.toJson<String>(ownerType),
      'ownerId': serializer.toJson<String?>(ownerId),
      'localRelativePath': serializer.toJson<String>(localRelativePath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'contentHash': serializer.toJson<String?>(contentHash),
      'mimeType': serializer.toJson<String?>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastVerifiedAt': serializer.toJson<DateTime?>(lastVerifiedAt),
    };
  }

  LocalFileRecord copyWith({
    int? id,
    String? category,
    String? ownerType,
    Value<String?> ownerId = const Value.absent(),
    String? localRelativePath,
    int? fileSizeBytes,
    Value<String?> contentHash = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> lastVerifiedAt = const Value.absent(),
  }) => LocalFileRecord(
    id: id ?? this.id,
    category: category ?? this.category,
    ownerType: ownerType ?? this.ownerType,
    ownerId: ownerId.present ? ownerId.value : this.ownerId,
    localRelativePath: localRelativePath ?? this.localRelativePath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    createdAt: createdAt ?? this.createdAt,
    lastVerifiedAt: lastVerifiedAt.present
        ? lastVerifiedAt.value
        : this.lastVerifiedAt,
  );
  LocalFileRecord copyWithCompanion(LocalFileRecordsCompanion data) {
    return LocalFileRecord(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      ownerType: data.ownerType.present ? data.ownerType.value : this.ownerType,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      localRelativePath: data.localRelativePath.present
          ? data.localRelativePath.value
          : this.localRelativePath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastVerifiedAt: data.lastVerifiedAt.present
          ? data.lastVerifiedAt.value
          : this.lastVerifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalFileRecord(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('localRelativePath: $localRelativePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    ownerType,
    ownerId,
    localRelativePath,
    fileSizeBytes,
    contentHash,
    mimeType,
    width,
    height,
    durationSeconds,
    createdAt,
    lastVerifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalFileRecord &&
          other.id == this.id &&
          other.category == this.category &&
          other.ownerType == this.ownerType &&
          other.ownerId == this.ownerId &&
          other.localRelativePath == this.localRelativePath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.contentHash == this.contentHash &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.durationSeconds == this.durationSeconds &&
          other.createdAt == this.createdAt &&
          other.lastVerifiedAt == this.lastVerifiedAt);
}

class LocalFileRecordsCompanion extends UpdateCompanion<LocalFileRecord> {
  final Value<int> id;
  final Value<String> category;
  final Value<String> ownerType;
  final Value<String?> ownerId;
  final Value<String> localRelativePath;
  final Value<int> fileSizeBytes;
  final Value<String?> contentHash;
  final Value<String?> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> durationSeconds;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastVerifiedAt;
  const LocalFileRecordsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.ownerType = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.localRelativePath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastVerifiedAt = const Value.absent(),
  });
  LocalFileRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String category,
    required String ownerType,
    this.ownerId = const Value.absent(),
    required String localRelativePath,
    required int fileSizeBytes,
    this.contentHash = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required DateTime createdAt,
    this.lastVerifiedAt = const Value.absent(),
  }) : category = Value(category),
       ownerType = Value(ownerType),
       localRelativePath = Value(localRelativePath),
       fileSizeBytes = Value(fileSizeBytes),
       createdAt = Value(createdAt);
  static Insertable<LocalFileRecord> custom({
    Expression<int>? id,
    Expression<String>? category,
    Expression<String>? ownerType,
    Expression<String>? ownerId,
    Expression<String>? localRelativePath,
    Expression<int>? fileSizeBytes,
    Expression<String>? contentHash,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? durationSeconds,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastVerifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (ownerType != null) 'owner_type': ownerType,
      if (ownerId != null) 'owner_id': ownerId,
      if (localRelativePath != null) 'local_relative_path': localRelativePath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (contentHash != null) 'content_hash': contentHash,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (createdAt != null) 'created_at': createdAt,
      if (lastVerifiedAt != null) 'last_verified_at': lastVerifiedAt,
    });
  }

  LocalFileRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? category,
    Value<String>? ownerType,
    Value<String?>? ownerId,
    Value<String>? localRelativePath,
    Value<int>? fileSizeBytes,
    Value<String?>? contentHash,
    Value<String?>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? durationSeconds,
    Value<DateTime>? createdAt,
    Value<DateTime?>? lastVerifiedAt,
  }) {
    return LocalFileRecordsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      localRelativePath: localRelativePath ?? this.localRelativePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      contentHash: contentHash ?? this.contentHash,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (ownerType.present) {
      map['owner_type'] = Variable<String>(ownerType.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (localRelativePath.present) {
      map['local_relative_path'] = Variable<String>(localRelativePath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastVerifiedAt.present) {
      map['last_verified_at'] = Variable<DateTime>(lastVerifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalFileRecordsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('ownerType: $ownerType, ')
          ..write('ownerId: $ownerId, ')
          ..write('localRelativePath: $localRelativePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastVerifiedAt: $lastVerifiedAt')
          ..write(')'))
        .toString();
  }
}

class $SchemaMigrationsLogTable extends SchemaMigrationsLog
    with TableInfo<$SchemaMigrationsLogTable, SchemaMigrationsLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchemaMigrationsLogTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fromVersionMeta = const VerificationMeta(
    'fromVersion',
  );
  @override
  late final GeneratedColumn<int> fromVersion = GeneratedColumn<int>(
    'from_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toVersionMeta = const VerificationMeta(
    'toVersion',
  );
  @override
  late final GeneratedColumn<int> toVersion = GeneratedColumn<int>(
    'to_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedAtMeta = const VerificationMeta(
    'appliedAt',
  );
  @override
  late final GeneratedColumn<DateTime> appliedAt = GeneratedColumn<DateTime>(
    'applied_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromVersion,
    toVersion,
    appliedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schema_migrations_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<SchemaMigrationsLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('from_version')) {
      context.handle(
        _fromVersionMeta,
        fromVersion.isAcceptableOrUnknown(
          data['from_version']!,
          _fromVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromVersionMeta);
    }
    if (data.containsKey('to_version')) {
      context.handle(
        _toVersionMeta,
        toVersion.isAcceptableOrUnknown(data['to_version']!, _toVersionMeta),
      );
    } else if (isInserting) {
      context.missing(_toVersionMeta);
    }
    if (data.containsKey('applied_at')) {
      context.handle(
        _appliedAtMeta,
        appliedAt.isAcceptableOrUnknown(data['applied_at']!, _appliedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_appliedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SchemaMigrationsLogData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SchemaMigrationsLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fromVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_version'],
      )!,
      toVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_version'],
      )!,
      appliedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}applied_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SchemaMigrationsLogTable createAlias(String alias) {
    return $SchemaMigrationsLogTable(attachedDatabase, alias);
  }
}

class SchemaMigrationsLogData extends DataClass
    implements Insertable<SchemaMigrationsLogData> {
  final int id;
  final int fromVersion;
  final int toVersion;
  final DateTime appliedAt;
  final String? notes;
  const SchemaMigrationsLogData({
    required this.id,
    required this.fromVersion,
    required this.toVersion,
    required this.appliedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['from_version'] = Variable<int>(fromVersion);
    map['to_version'] = Variable<int>(toVersion);
    map['applied_at'] = Variable<DateTime>(appliedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SchemaMigrationsLogCompanion toCompanion(bool nullToAbsent) {
    return SchemaMigrationsLogCompanion(
      id: Value(id),
      fromVersion: Value(fromVersion),
      toVersion: Value(toVersion),
      appliedAt: Value(appliedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SchemaMigrationsLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SchemaMigrationsLogData(
      id: serializer.fromJson<int>(json['id']),
      fromVersion: serializer.fromJson<int>(json['fromVersion']),
      toVersion: serializer.fromJson<int>(json['toVersion']),
      appliedAt: serializer.fromJson<DateTime>(json['appliedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fromVersion': serializer.toJson<int>(fromVersion),
      'toVersion': serializer.toJson<int>(toVersion),
      'appliedAt': serializer.toJson<DateTime>(appliedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SchemaMigrationsLogData copyWith({
    int? id,
    int? fromVersion,
    int? toVersion,
    DateTime? appliedAt,
    Value<String?> notes = const Value.absent(),
  }) => SchemaMigrationsLogData(
    id: id ?? this.id,
    fromVersion: fromVersion ?? this.fromVersion,
    toVersion: toVersion ?? this.toVersion,
    appliedAt: appliedAt ?? this.appliedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  SchemaMigrationsLogData copyWithCompanion(SchemaMigrationsLogCompanion data) {
    return SchemaMigrationsLogData(
      id: data.id.present ? data.id.value : this.id,
      fromVersion: data.fromVersion.present
          ? data.fromVersion.value
          : this.fromVersion,
      toVersion: data.toVersion.present ? data.toVersion.value : this.toVersion,
      appliedAt: data.appliedAt.present ? data.appliedAt.value : this.appliedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMigrationsLogData(')
          ..write('id: $id, ')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fromVersion, toVersion, appliedAt, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SchemaMigrationsLogData &&
          other.id == this.id &&
          other.fromVersion == this.fromVersion &&
          other.toVersion == this.toVersion &&
          other.appliedAt == this.appliedAt &&
          other.notes == this.notes);
}

class SchemaMigrationsLogCompanion
    extends UpdateCompanion<SchemaMigrationsLogData> {
  final Value<int> id;
  final Value<int> fromVersion;
  final Value<int> toVersion;
  final Value<DateTime> appliedAt;
  final Value<String?> notes;
  const SchemaMigrationsLogCompanion({
    this.id = const Value.absent(),
    this.fromVersion = const Value.absent(),
    this.toVersion = const Value.absent(),
    this.appliedAt = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SchemaMigrationsLogCompanion.insert({
    this.id = const Value.absent(),
    required int fromVersion,
    required int toVersion,
    required DateTime appliedAt,
    this.notes = const Value.absent(),
  }) : fromVersion = Value(fromVersion),
       toVersion = Value(toVersion),
       appliedAt = Value(appliedAt);
  static Insertable<SchemaMigrationsLogData> custom({
    Expression<int>? id,
    Expression<int>? fromVersion,
    Expression<int>? toVersion,
    Expression<DateTime>? appliedAt,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromVersion != null) 'from_version': fromVersion,
      if (toVersion != null) 'to_version': toVersion,
      if (appliedAt != null) 'applied_at': appliedAt,
      if (notes != null) 'notes': notes,
    });
  }

  SchemaMigrationsLogCompanion copyWith({
    Value<int>? id,
    Value<int>? fromVersion,
    Value<int>? toVersion,
    Value<DateTime>? appliedAt,
    Value<String?>? notes,
  }) {
    return SchemaMigrationsLogCompanion(
      id: id ?? this.id,
      fromVersion: fromVersion ?? this.fromVersion,
      toVersion: toVersion ?? this.toVersion,
      appliedAt: appliedAt ?? this.appliedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fromVersion.present) {
      map['from_version'] = Variable<int>(fromVersion.value);
    }
    if (toVersion.present) {
      map['to_version'] = Variable<int>(toVersion.value);
    }
    if (appliedAt.present) {
      map['applied_at'] = Variable<DateTime>(appliedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchemaMigrationsLogCompanion(')
          ..write('id: $id, ')
          ..write('fromVersion: $fromVersion, ')
          ..write('toVersion: $toVersion, ')
          ..write('appliedAt: $appliedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $LibraryMetaTable extends LibraryMeta
    with TableInfo<$LibraryMetaTable, LibraryMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('exercise_library'),
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
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _libraryVersionMeta = const VerificationMeta(
    'libraryVersion',
  );
  @override
  late final GeneratedColumn<String> libraryVersion = GeneratedColumn<String>(
    'library_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exerciseCountMeta = const VerificationMeta(
    'exerciseCount',
  );
  @override
  late final GeneratedColumn<int> exerciseCount = GeneratedColumn<int>(
    'exercise_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _manifestLastUpdatedAtMeta =
      const VerificationMeta('manifestLastUpdatedAt');
  @override
  late final GeneratedColumn<DateTime> manifestLastUpdatedAt =
      GeneratedColumn<DateTime>(
        'manifest_last_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _manifestFilePathMeta = const VerificationMeta(
    'manifestFilePath',
  );
  @override
  late final GeneratedColumn<String> manifestFilePath = GeneratedColumn<String>(
    'manifest_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minAppSchemaVersionMeta =
      const VerificationMeta('minAppSchemaVersion');
  @override
  late final GeneratedColumn<int> minAppSchemaVersion = GeneratedColumn<int>(
    'min_app_schema_version',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSyncErrorCodeMeta = const VerificationMeta(
    'lastSyncErrorCode',
  );
  @override
  late final GeneratedColumn<String> lastSyncErrorCode =
      GeneratedColumn<String>(
        'last_sync_error_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastSyncErrorMessageMeta =
      const VerificationMeta('lastSyncErrorMessage');
  @override
  late final GeneratedColumn<String> lastSyncErrorMessage =
      GeneratedColumn<String>(
        'last_sync_error_message',
        aliasedName,
        true,
        type: DriftSqlType.string,
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
    source,
    schemaVersion,
    libraryVersion,
    generatedAt,
    downloadedAt,
    exerciseCount,
    manifestLastUpdatedAt,
    manifestFilePath,
    minAppSchemaVersion,
    syncStatus,
    lastSyncErrorCode,
    lastSyncErrorMessage,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('library_version')) {
      context.handle(
        _libraryVersionMeta,
        libraryVersion.isAcceptableOrUnknown(
          data['library_version']!,
          _libraryVersionMeta,
        ),
      );
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('exercise_count')) {
      context.handle(
        _exerciseCountMeta,
        exerciseCount.isAcceptableOrUnknown(
          data['exercise_count']!,
          _exerciseCountMeta,
        ),
      );
    }
    if (data.containsKey('manifest_last_updated_at')) {
      context.handle(
        _manifestLastUpdatedAtMeta,
        manifestLastUpdatedAt.isAcceptableOrUnknown(
          data['manifest_last_updated_at']!,
          _manifestLastUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('manifest_file_path')) {
      context.handle(
        _manifestFilePathMeta,
        manifestFilePath.isAcceptableOrUnknown(
          data['manifest_file_path']!,
          _manifestFilePathMeta,
        ),
      );
    }
    if (data.containsKey('min_app_schema_version')) {
      context.handle(
        _minAppSchemaVersionMeta,
        minAppSchemaVersion.isAcceptableOrUnknown(
          data['min_app_schema_version']!,
          _minAppSchemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    } else if (isInserting) {
      context.missing(_syncStatusMeta);
    }
    if (data.containsKey('last_sync_error_code')) {
      context.handle(
        _lastSyncErrorCodeMeta,
        lastSyncErrorCode.isAcceptableOrUnknown(
          data['last_sync_error_code']!,
          _lastSyncErrorCodeMeta,
        ),
      );
    }
    if (data.containsKey('last_sync_error_message')) {
      context.handle(
        _lastSyncErrorMessageMeta,
        lastSyncErrorMessage.isAcceptableOrUnknown(
          data['last_sync_error_message']!,
          _lastSyncErrorMessageMeta,
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
  LibraryMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryMetaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      libraryVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}library_version'],
      ),
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
      exerciseCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_count'],
      )!,
      manifestLastUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}manifest_last_updated_at'],
      ),
      manifestFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}manifest_file_path'],
      ),
      minAppSchemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_app_schema_version'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncErrorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error_code'],
      ),
      lastSyncErrorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_sync_error_message'],
      ),
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
  $LibraryMetaTable createAlias(String alias) {
    return $LibraryMetaTable(attachedDatabase, alias);
  }
}

class LibraryMetaData extends DataClass implements Insertable<LibraryMetaData> {
  final String id;
  final String source;
  final int schemaVersion;
  final String? libraryVersion;
  final DateTime? generatedAt;
  final DateTime? downloadedAt;
  final int exerciseCount;
  final DateTime? manifestLastUpdatedAt;
  final String? manifestFilePath;
  final int? minAppSchemaVersion;
  final String syncStatus;
  final String? lastSyncErrorCode;
  final String? lastSyncErrorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LibraryMetaData({
    required this.id,
    required this.source,
    required this.schemaVersion,
    this.libraryVersion,
    this.generatedAt,
    this.downloadedAt,
    required this.exerciseCount,
    this.manifestLastUpdatedAt,
    this.manifestFilePath,
    this.minAppSchemaVersion,
    required this.syncStatus,
    this.lastSyncErrorCode,
    this.lastSyncErrorMessage,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['source'] = Variable<String>(source);
    map['schema_version'] = Variable<int>(schemaVersion);
    if (!nullToAbsent || libraryVersion != null) {
      map['library_version'] = Variable<String>(libraryVersion);
    }
    if (!nullToAbsent || generatedAt != null) {
      map['generated_at'] = Variable<DateTime>(generatedAt);
    }
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    map['exercise_count'] = Variable<int>(exerciseCount);
    if (!nullToAbsent || manifestLastUpdatedAt != null) {
      map['manifest_last_updated_at'] = Variable<DateTime>(
        manifestLastUpdatedAt,
      );
    }
    if (!nullToAbsent || manifestFilePath != null) {
      map['manifest_file_path'] = Variable<String>(manifestFilePath);
    }
    if (!nullToAbsent || minAppSchemaVersion != null) {
      map['min_app_schema_version'] = Variable<int>(minAppSchemaVersion);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncErrorCode != null) {
      map['last_sync_error_code'] = Variable<String>(lastSyncErrorCode);
    }
    if (!nullToAbsent || lastSyncErrorMessage != null) {
      map['last_sync_error_message'] = Variable<String>(lastSyncErrorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LibraryMetaCompanion toCompanion(bool nullToAbsent) {
    return LibraryMetaCompanion(
      id: Value(id),
      source: Value(source),
      schemaVersion: Value(schemaVersion),
      libraryVersion: libraryVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(libraryVersion),
      generatedAt: generatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(generatedAt),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
      exerciseCount: Value(exerciseCount),
      manifestLastUpdatedAt: manifestLastUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(manifestLastUpdatedAt),
      manifestFilePath: manifestFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(manifestFilePath),
      minAppSchemaVersion: minAppSchemaVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(minAppSchemaVersion),
      syncStatus: Value(syncStatus),
      lastSyncErrorCode: lastSyncErrorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncErrorCode),
      lastSyncErrorMessage: lastSyncErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncErrorMessage),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LibraryMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryMetaData(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      libraryVersion: serializer.fromJson<String?>(json['libraryVersion']),
      generatedAt: serializer.fromJson<DateTime?>(json['generatedAt']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
      exerciseCount: serializer.fromJson<int>(json['exerciseCount']),
      manifestLastUpdatedAt: serializer.fromJson<DateTime?>(
        json['manifestLastUpdatedAt'],
      ),
      manifestFilePath: serializer.fromJson<String?>(json['manifestFilePath']),
      minAppSchemaVersion: serializer.fromJson<int?>(
        json['minAppSchemaVersion'],
      ),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncErrorCode: serializer.fromJson<String?>(
        json['lastSyncErrorCode'],
      ),
      lastSyncErrorMessage: serializer.fromJson<String?>(
        json['lastSyncErrorMessage'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'source': serializer.toJson<String>(source),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'libraryVersion': serializer.toJson<String?>(libraryVersion),
      'generatedAt': serializer.toJson<DateTime?>(generatedAt),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
      'exerciseCount': serializer.toJson<int>(exerciseCount),
      'manifestLastUpdatedAt': serializer.toJson<DateTime?>(
        manifestLastUpdatedAt,
      ),
      'manifestFilePath': serializer.toJson<String?>(manifestFilePath),
      'minAppSchemaVersion': serializer.toJson<int?>(minAppSchemaVersion),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncErrorCode': serializer.toJson<String?>(lastSyncErrorCode),
      'lastSyncErrorMessage': serializer.toJson<String?>(lastSyncErrorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LibraryMetaData copyWith({
    String? id,
    String? source,
    int? schemaVersion,
    Value<String?> libraryVersion = const Value.absent(),
    Value<DateTime?> generatedAt = const Value.absent(),
    Value<DateTime?> downloadedAt = const Value.absent(),
    int? exerciseCount,
    Value<DateTime?> manifestLastUpdatedAt = const Value.absent(),
    Value<String?> manifestFilePath = const Value.absent(),
    Value<int?> minAppSchemaVersion = const Value.absent(),
    String? syncStatus,
    Value<String?> lastSyncErrorCode = const Value.absent(),
    Value<String?> lastSyncErrorMessage = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LibraryMetaData(
    id: id ?? this.id,
    source: source ?? this.source,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    libraryVersion: libraryVersion.present
        ? libraryVersion.value
        : this.libraryVersion,
    generatedAt: generatedAt.present ? generatedAt.value : this.generatedAt,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
    exerciseCount: exerciseCount ?? this.exerciseCount,
    manifestLastUpdatedAt: manifestLastUpdatedAt.present
        ? manifestLastUpdatedAt.value
        : this.manifestLastUpdatedAt,
    manifestFilePath: manifestFilePath.present
        ? manifestFilePath.value
        : this.manifestFilePath,
    minAppSchemaVersion: minAppSchemaVersion.present
        ? minAppSchemaVersion.value
        : this.minAppSchemaVersion,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncErrorCode: lastSyncErrorCode.present
        ? lastSyncErrorCode.value
        : this.lastSyncErrorCode,
    lastSyncErrorMessage: lastSyncErrorMessage.present
        ? lastSyncErrorMessage.value
        : this.lastSyncErrorMessage,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LibraryMetaData copyWithCompanion(LibraryMetaCompanion data) {
    return LibraryMetaData(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      libraryVersion: data.libraryVersion.present
          ? data.libraryVersion.value
          : this.libraryVersion,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      exerciseCount: data.exerciseCount.present
          ? data.exerciseCount.value
          : this.exerciseCount,
      manifestLastUpdatedAt: data.manifestLastUpdatedAt.present
          ? data.manifestLastUpdatedAt.value
          : this.manifestLastUpdatedAt,
      manifestFilePath: data.manifestFilePath.present
          ? data.manifestFilePath.value
          : this.manifestFilePath,
      minAppSchemaVersion: data.minAppSchemaVersion.present
          ? data.minAppSchemaVersion.value
          : this.minAppSchemaVersion,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncErrorCode: data.lastSyncErrorCode.present
          ? data.lastSyncErrorCode.value
          : this.lastSyncErrorCode,
      lastSyncErrorMessage: data.lastSyncErrorMessage.present
          ? data.lastSyncErrorMessage.value
          : this.lastSyncErrorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryMetaData(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('libraryVersion: $libraryVersion, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('exerciseCount: $exerciseCount, ')
          ..write('manifestLastUpdatedAt: $manifestLastUpdatedAt, ')
          ..write('manifestFilePath: $manifestFilePath, ')
          ..write('minAppSchemaVersion: $minAppSchemaVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncErrorCode: $lastSyncErrorCode, ')
          ..write('lastSyncErrorMessage: $lastSyncErrorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    source,
    schemaVersion,
    libraryVersion,
    generatedAt,
    downloadedAt,
    exerciseCount,
    manifestLastUpdatedAt,
    manifestFilePath,
    minAppSchemaVersion,
    syncStatus,
    lastSyncErrorCode,
    lastSyncErrorMessage,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryMetaData &&
          other.id == this.id &&
          other.source == this.source &&
          other.schemaVersion == this.schemaVersion &&
          other.libraryVersion == this.libraryVersion &&
          other.generatedAt == this.generatedAt &&
          other.downloadedAt == this.downloadedAt &&
          other.exerciseCount == this.exerciseCount &&
          other.manifestLastUpdatedAt == this.manifestLastUpdatedAt &&
          other.manifestFilePath == this.manifestFilePath &&
          other.minAppSchemaVersion == this.minAppSchemaVersion &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncErrorCode == this.lastSyncErrorCode &&
          other.lastSyncErrorMessage == this.lastSyncErrorMessage &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LibraryMetaCompanion extends UpdateCompanion<LibraryMetaData> {
  final Value<String> id;
  final Value<String> source;
  final Value<int> schemaVersion;
  final Value<String?> libraryVersion;
  final Value<DateTime?> generatedAt;
  final Value<DateTime?> downloadedAt;
  final Value<int> exerciseCount;
  final Value<DateTime?> manifestLastUpdatedAt;
  final Value<String?> manifestFilePath;
  final Value<int?> minAppSchemaVersion;
  final Value<String> syncStatus;
  final Value<String?> lastSyncErrorCode;
  final Value<String?> lastSyncErrorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LibraryMetaCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.libraryVersion = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.exerciseCount = const Value.absent(),
    this.manifestLastUpdatedAt = const Value.absent(),
    this.manifestFilePath = const Value.absent(),
    this.minAppSchemaVersion = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncErrorCode = const Value.absent(),
    this.lastSyncErrorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryMetaCompanion.insert({
    this.id = const Value.absent(),
    required String source,
    required int schemaVersion,
    this.libraryVersion = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.exerciseCount = const Value.absent(),
    this.manifestLastUpdatedAt = const Value.absent(),
    this.manifestFilePath = const Value.absent(),
    this.minAppSchemaVersion = const Value.absent(),
    required String syncStatus,
    this.lastSyncErrorCode = const Value.absent(),
    this.lastSyncErrorMessage = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : source = Value(source),
       schemaVersion = Value(schemaVersion),
       syncStatus = Value(syncStatus),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LibraryMetaData> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<int>? schemaVersion,
    Expression<String>? libraryVersion,
    Expression<DateTime>? generatedAt,
    Expression<DateTime>? downloadedAt,
    Expression<int>? exerciseCount,
    Expression<DateTime>? manifestLastUpdatedAt,
    Expression<String>? manifestFilePath,
    Expression<int>? minAppSchemaVersion,
    Expression<String>? syncStatus,
    Expression<String>? lastSyncErrorCode,
    Expression<String>? lastSyncErrorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (libraryVersion != null) 'library_version': libraryVersion,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (exerciseCount != null) 'exercise_count': exerciseCount,
      if (manifestLastUpdatedAt != null)
        'manifest_last_updated_at': manifestLastUpdatedAt,
      if (manifestFilePath != null) 'manifest_file_path': manifestFilePath,
      if (minAppSchemaVersion != null)
        'min_app_schema_version': minAppSchemaVersion,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncErrorCode != null) 'last_sync_error_code': lastSyncErrorCode,
      if (lastSyncErrorMessage != null)
        'last_sync_error_message': lastSyncErrorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryMetaCompanion copyWith({
    Value<String>? id,
    Value<String>? source,
    Value<int>? schemaVersion,
    Value<String?>? libraryVersion,
    Value<DateTime?>? generatedAt,
    Value<DateTime?>? downloadedAt,
    Value<int>? exerciseCount,
    Value<DateTime?>? manifestLastUpdatedAt,
    Value<String?>? manifestFilePath,
    Value<int?>? minAppSchemaVersion,
    Value<String>? syncStatus,
    Value<String?>? lastSyncErrorCode,
    Value<String?>? lastSyncErrorMessage,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LibraryMetaCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      libraryVersion: libraryVersion ?? this.libraryVersion,
      generatedAt: generatedAt ?? this.generatedAt,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      manifestLastUpdatedAt:
          manifestLastUpdatedAt ?? this.manifestLastUpdatedAt,
      manifestFilePath: manifestFilePath ?? this.manifestFilePath,
      minAppSchemaVersion: minAppSchemaVersion ?? this.minAppSchemaVersion,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncErrorCode: lastSyncErrorCode ?? this.lastSyncErrorCode,
      lastSyncErrorMessage: lastSyncErrorMessage ?? this.lastSyncErrorMessage,
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
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (libraryVersion.present) {
      map['library_version'] = Variable<String>(libraryVersion.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (exerciseCount.present) {
      map['exercise_count'] = Variable<int>(exerciseCount.value);
    }
    if (manifestLastUpdatedAt.present) {
      map['manifest_last_updated_at'] = Variable<DateTime>(
        manifestLastUpdatedAt.value,
      );
    }
    if (manifestFilePath.present) {
      map['manifest_file_path'] = Variable<String>(manifestFilePath.value);
    }
    if (minAppSchemaVersion.present) {
      map['min_app_schema_version'] = Variable<int>(minAppSchemaVersion.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncErrorCode.present) {
      map['last_sync_error_code'] = Variable<String>(lastSyncErrorCode.value);
    }
    if (lastSyncErrorMessage.present) {
      map['last_sync_error_message'] = Variable<String>(
        lastSyncErrorMessage.value,
      );
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
    return (StringBuffer('LibraryMetaCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('libraryVersion: $libraryVersion, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('exerciseCount: $exerciseCount, ')
          ..write('manifestLastUpdatedAt: $manifestLastUpdatedAt, ')
          ..write('manifestFilePath: $manifestFilePath, ')
          ..write('minAppSchemaVersion: $minAppSchemaVersion, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncErrorCode: $lastSyncErrorCode, ')
          ..write('lastSyncErrorMessage: $lastSyncErrorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseVideosTable extends ExerciseVideos
    with TableInfo<$ExerciseVideosTable, ExerciseVideo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseVideosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _angleMeta = const VerificationMeta('angle');
  @override
  late final GeneratedColumn<String> angle = GeneratedColumn<String>(
    'angle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ogImageUrlMeta = const VerificationMeta(
    'ogImageUrl',
  );
  @override
  late final GeneratedColumn<String> ogImageUrl = GeneratedColumn<String>(
    'og_image_url',
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
    exerciseId,
    url,
    angle,
    gender,
    ogImageUrl,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_videos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseVideo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('angle')) {
      context.handle(
        _angleMeta,
        angle.isAcceptableOrUnknown(data['angle']!, _angleMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('og_image_url')) {
      context.handle(
        _ogImageUrlMeta,
        ogImageUrl.isAcceptableOrUnknown(
          data['og_image_url']!,
          _ogImageUrlMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseVideo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseVideo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      angle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}angle'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      ),
      ogImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}og_image_url'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ExerciseVideosTable createAlias(String alias) {
    return $ExerciseVideosTable(attachedDatabase, alias);
  }
}

class ExerciseVideo extends DataClass implements Insertable<ExerciseVideo> {
  final String id;
  final int exerciseId;
  final String url;
  final String? angle;
  final String? gender;
  final String? ogImageUrl;
  final int sortOrder;
  final DateTime createdAt;
  const ExerciseVideo({
    required this.id,
    required this.exerciseId,
    required this.url,
    this.angle,
    this.gender,
    this.ogImageUrl,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || angle != null) {
      map['angle'] = Variable<String>(angle);
    }
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || ogImageUrl != null) {
      map['og_image_url'] = Variable<String>(ogImageUrl);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ExerciseVideosCompanion toCompanion(bool nullToAbsent) {
    return ExerciseVideosCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      url: Value(url),
      angle: angle == null && nullToAbsent
          ? const Value.absent()
          : Value(angle),
      gender: gender == null && nullToAbsent
          ? const Value.absent()
          : Value(gender),
      ogImageUrl: ogImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(ogImageUrl),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ExerciseVideo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseVideo(
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      url: serializer.fromJson<String>(json['url']),
      angle: serializer.fromJson<String?>(json['angle']),
      gender: serializer.fromJson<String?>(json['gender']),
      ogImageUrl: serializer.fromJson<String?>(json['ogImageUrl']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'url': serializer.toJson<String>(url),
      'angle': serializer.toJson<String?>(angle),
      'gender': serializer.toJson<String?>(gender),
      'ogImageUrl': serializer.toJson<String?>(ogImageUrl),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ExerciseVideo copyWith({
    String? id,
    int? exerciseId,
    String? url,
    Value<String?> angle = const Value.absent(),
    Value<String?> gender = const Value.absent(),
    Value<String?> ogImageUrl = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
  }) => ExerciseVideo(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    url: url ?? this.url,
    angle: angle.present ? angle.value : this.angle,
    gender: gender.present ? gender.value : this.gender,
    ogImageUrl: ogImageUrl.present ? ogImageUrl.value : this.ogImageUrl,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  ExerciseVideo copyWithCompanion(ExerciseVideosCompanion data) {
    return ExerciseVideo(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      url: data.url.present ? data.url.value : this.url,
      angle: data.angle.present ? data.angle.value : this.angle,
      gender: data.gender.present ? data.gender.value : this.gender,
      ogImageUrl: data.ogImageUrl.present
          ? data.ogImageUrl.value
          : this.ogImageUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseVideo(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('url: $url, ')
          ..write('angle: $angle, ')
          ..write('gender: $gender, ')
          ..write('ogImageUrl: $ogImageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    url,
    angle,
    gender,
    ogImageUrl,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseVideo &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.url == this.url &&
          other.angle == this.angle &&
          other.gender == this.gender &&
          other.ogImageUrl == this.ogImageUrl &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ExerciseVideosCompanion extends UpdateCompanion<ExerciseVideo> {
  final Value<String> id;
  final Value<int> exerciseId;
  final Value<String> url;
  final Value<String?> angle;
  final Value<String?> gender;
  final Value<String?> ogImageUrl;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ExerciseVideosCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.url = const Value.absent(),
    this.angle = const Value.absent(),
    this.gender = const Value.absent(),
    this.ogImageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseVideosCompanion.insert({
    required String id,
    required int exerciseId,
    required String url,
    this.angle = const Value.absent(),
    this.gender = const Value.absent(),
    this.ogImageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       url = Value(url),
       createdAt = Value(createdAt);
  static Insertable<ExerciseVideo> custom({
    Expression<String>? id,
    Expression<int>? exerciseId,
    Expression<String>? url,
    Expression<String>? angle,
    Expression<String>? gender,
    Expression<String>? ogImageUrl,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (url != null) 'url': url,
      if (angle != null) 'angle': angle,
      if (gender != null) 'gender': gender,
      if (ogImageUrl != null) 'og_image_url': ogImageUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseVideosCompanion copyWith({
    Value<String>? id,
    Value<int>? exerciseId,
    Value<String>? url,
    Value<String?>? angle,
    Value<String?>? gender,
    Value<String?>? ogImageUrl,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ExerciseVideosCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      url: url ?? this.url,
      angle: angle ?? this.angle,
      gender: gender ?? this.gender,
      ogImageUrl: ogImageUrl ?? this.ogImageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (angle.present) {
      map['angle'] = Variable<String>(angle.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (ogImageUrl.present) {
      map['og_image_url'] = Variable<String>(ogImageUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
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
    return (StringBuffer('ExerciseVideosCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('url: $url, ')
          ..write('angle: $angle, ')
          ..write('gender: $gender, ')
          ..write('ogImageUrl: $ogImageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseAudioCacheTable extends ExerciseAudioCache
    with TableInfo<$ExerciseAudioCacheTable, ExerciseAudioCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseAudioCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<int> exerciseId = GeneratedColumn<int>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _stepIndexMeta = const VerificationMeta(
    'stepIndex',
  );
  @override
  late final GeneratedColumn<int> stepIndex = GeneratedColumn<int>(
    'step_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textHashMeta = const VerificationMeta(
    'textHash',
  );
  @override
  late final GeneratedColumn<String> textHash = GeneratedColumn<String>(
    'text_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localRelativePathMeta = const VerificationMeta(
    'localRelativePath',
  );
  @override
  late final GeneratedColumn<String> localRelativePath =
      GeneratedColumn<String>(
        'local_relative_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voiceIdMeta = const VerificationMeta(
    'voiceId',
  );
  @override
  late final GeneratedColumn<String> voiceId = GeneratedColumn<String>(
    'voice_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    stepIndex,
    textHash,
    localRelativePath,
    fileSizeBytes,
    voiceId,
    generatedAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_audio_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseAudioCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('step_index')) {
      context.handle(
        _stepIndexMeta,
        stepIndex.isAcceptableOrUnknown(data['step_index']!, _stepIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_stepIndexMeta);
    }
    if (data.containsKey('text_hash')) {
      context.handle(
        _textHashMeta,
        textHash.isAcceptableOrUnknown(data['text_hash']!, _textHashMeta),
      );
    } else if (isInserting) {
      context.missing(_textHashMeta);
    }
    if (data.containsKey('local_relative_path')) {
      context.handle(
        _localRelativePathMeta,
        localRelativePath.isAcceptableOrUnknown(
          data['local_relative_path']!,
          _localRelativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localRelativePathMeta);
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    }
    if (data.containsKey('voice_id')) {
      context.handle(
        _voiceIdMeta,
        voiceId.isAcceptableOrUnknown(data['voice_id']!, _voiceIdMeta),
      );
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseAudioCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseAudioCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exercise_id'],
      )!,
      stepIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}step_index'],
      )!,
      textHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_hash'],
      )!,
      localRelativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_relative_path'],
      )!,
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      ),
      voiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_id'],
      ),
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      ),
    );
  }

  @override
  $ExerciseAudioCacheTable createAlias(String alias) {
    return $ExerciseAudioCacheTable(attachedDatabase, alias);
  }
}

class ExerciseAudioCacheData extends DataClass
    implements Insertable<ExerciseAudioCacheData> {
  final String id;
  final int exerciseId;
  final int stepIndex;
  final String textHash;
  final String localRelativePath;
  final int? fileSizeBytes;
  final String? voiceId;
  final DateTime generatedAt;
  final DateTime? lastAccessedAt;
  const ExerciseAudioCacheData({
    required this.id,
    required this.exerciseId,
    required this.stepIndex,
    required this.textHash,
    required this.localRelativePath,
    this.fileSizeBytes,
    this.voiceId,
    required this.generatedAt,
    this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<int>(exerciseId);
    map['step_index'] = Variable<int>(stepIndex);
    map['text_hash'] = Variable<String>(textHash);
    map['local_relative_path'] = Variable<String>(localRelativePath);
    if (!nullToAbsent || fileSizeBytes != null) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    }
    if (!nullToAbsent || voiceId != null) {
      map['voice_id'] = Variable<String>(voiceId);
    }
    map['generated_at'] = Variable<DateTime>(generatedAt);
    if (!nullToAbsent || lastAccessedAt != null) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    }
    return map;
  }

  ExerciseAudioCacheCompanion toCompanion(bool nullToAbsent) {
    return ExerciseAudioCacheCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      stepIndex: Value(stepIndex),
      textHash: Value(textHash),
      localRelativePath: Value(localRelativePath),
      fileSizeBytes: fileSizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(fileSizeBytes),
      voiceId: voiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(voiceId),
      generatedAt: Value(generatedAt),
      lastAccessedAt: lastAccessedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAccessedAt),
    );
  }

  factory ExerciseAudioCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseAudioCacheData(
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<int>(json['exerciseId']),
      stepIndex: serializer.fromJson<int>(json['stepIndex']),
      textHash: serializer.fromJson<String>(json['textHash']),
      localRelativePath: serializer.fromJson<String>(json['localRelativePath']),
      fileSizeBytes: serializer.fromJson<int?>(json['fileSizeBytes']),
      voiceId: serializer.fromJson<String?>(json['voiceId']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      lastAccessedAt: serializer.fromJson<DateTime?>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<int>(exerciseId),
      'stepIndex': serializer.toJson<int>(stepIndex),
      'textHash': serializer.toJson<String>(textHash),
      'localRelativePath': serializer.toJson<String>(localRelativePath),
      'fileSizeBytes': serializer.toJson<int?>(fileSizeBytes),
      'voiceId': serializer.toJson<String?>(voiceId),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'lastAccessedAt': serializer.toJson<DateTime?>(lastAccessedAt),
    };
  }

  ExerciseAudioCacheData copyWith({
    String? id,
    int? exerciseId,
    int? stepIndex,
    String? textHash,
    String? localRelativePath,
    Value<int?> fileSizeBytes = const Value.absent(),
    Value<String?> voiceId = const Value.absent(),
    DateTime? generatedAt,
    Value<DateTime?> lastAccessedAt = const Value.absent(),
  }) => ExerciseAudioCacheData(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    stepIndex: stepIndex ?? this.stepIndex,
    textHash: textHash ?? this.textHash,
    localRelativePath: localRelativePath ?? this.localRelativePath,
    fileSizeBytes: fileSizeBytes.present
        ? fileSizeBytes.value
        : this.fileSizeBytes,
    voiceId: voiceId.present ? voiceId.value : this.voiceId,
    generatedAt: generatedAt ?? this.generatedAt,
    lastAccessedAt: lastAccessedAt.present
        ? lastAccessedAt.value
        : this.lastAccessedAt,
  );
  ExerciseAudioCacheData copyWithCompanion(ExerciseAudioCacheCompanion data) {
    return ExerciseAudioCacheData(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      stepIndex: data.stepIndex.present ? data.stepIndex.value : this.stepIndex,
      textHash: data.textHash.present ? data.textHash.value : this.textHash,
      localRelativePath: data.localRelativePath.present
          ? data.localRelativePath.value
          : this.localRelativePath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      voiceId: data.voiceId.present ? data.voiceId.value : this.voiceId,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseAudioCacheData(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('textHash: $textHash, ')
          ..write('localRelativePath: $localRelativePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('voiceId: $voiceId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    stepIndex,
    textHash,
    localRelativePath,
    fileSizeBytes,
    voiceId,
    generatedAt,
    lastAccessedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseAudioCacheData &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.stepIndex == this.stepIndex &&
          other.textHash == this.textHash &&
          other.localRelativePath == this.localRelativePath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.voiceId == this.voiceId &&
          other.generatedAt == this.generatedAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class ExerciseAudioCacheCompanion
    extends UpdateCompanion<ExerciseAudioCacheData> {
  final Value<String> id;
  final Value<int> exerciseId;
  final Value<int> stepIndex;
  final Value<String> textHash;
  final Value<String> localRelativePath;
  final Value<int?> fileSizeBytes;
  final Value<String?> voiceId;
  final Value<DateTime> generatedAt;
  final Value<DateTime?> lastAccessedAt;
  final Value<int> rowid;
  const ExerciseAudioCacheCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.stepIndex = const Value.absent(),
    this.textHash = const Value.absent(),
    this.localRelativePath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.voiceId = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseAudioCacheCompanion.insert({
    required String id,
    required int exerciseId,
    required int stepIndex,
    required String textHash,
    required String localRelativePath,
    this.fileSizeBytes = const Value.absent(),
    this.voiceId = const Value.absent(),
    required DateTime generatedAt,
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       stepIndex = Value(stepIndex),
       textHash = Value(textHash),
       localRelativePath = Value(localRelativePath),
       generatedAt = Value(generatedAt);
  static Insertable<ExerciseAudioCacheData> custom({
    Expression<String>? id,
    Expression<int>? exerciseId,
    Expression<int>? stepIndex,
    Expression<String>? textHash,
    Expression<String>? localRelativePath,
    Expression<int>? fileSizeBytes,
    Expression<String>? voiceId,
    Expression<DateTime>? generatedAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (stepIndex != null) 'step_index': stepIndex,
      if (textHash != null) 'text_hash': textHash,
      if (localRelativePath != null) 'local_relative_path': localRelativePath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (voiceId != null) 'voice_id': voiceId,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseAudioCacheCompanion copyWith({
    Value<String>? id,
    Value<int>? exerciseId,
    Value<int>? stepIndex,
    Value<String>? textHash,
    Value<String>? localRelativePath,
    Value<int?>? fileSizeBytes,
    Value<String?>? voiceId,
    Value<DateTime>? generatedAt,
    Value<DateTime?>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return ExerciseAudioCacheCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      stepIndex: stepIndex ?? this.stepIndex,
      textHash: textHash ?? this.textHash,
      localRelativePath: localRelativePath ?? this.localRelativePath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      voiceId: voiceId ?? this.voiceId,
      generatedAt: generatedAt ?? this.generatedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<int>(exerciseId.value);
    }
    if (stepIndex.present) {
      map['step_index'] = Variable<int>(stepIndex.value);
    }
    if (textHash.present) {
      map['text_hash'] = Variable<String>(textHash.value);
    }
    if (localRelativePath.present) {
      map['local_relative_path'] = Variable<String>(localRelativePath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (voiceId.present) {
      map['voice_id'] = Variable<String>(voiceId.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseAudioCacheCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('stepIndex: $stepIndex, ')
          ..write('textHash: $textHash, ')
          ..write('localRelativePath: $localRelativePath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('voiceId: $voiceId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchemaMetaTable schemaMeta = $SchemaMetaTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $LocalFileRecordsTable localFileRecords = $LocalFileRecordsTable(
    this,
  );
  late final $SchemaMigrationsLogTable schemaMigrationsLog =
      $SchemaMigrationsLogTable(this);
  late final $LibraryMetaTable libraryMeta = $LibraryMetaTable(this);
  late final $ExerciseVideosTable exerciseVideos = $ExerciseVideosTable(this);
  late final $ExerciseAudioCacheTable exerciseAudioCache =
      $ExerciseAudioCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schemaMeta,
    exercises,
    localFileRecords,
    schemaMigrationsLog,
    libraryMeta,
    exerciseVideos,
    exerciseAudioCache,
  ];
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
      Value<bool> isCustom,
      Value<String?> customExerciseUuid,
      required String source,
      Value<String?> sourceDatasetVersion,
      Value<int?> sourceSchemaVersion,
      required String name,
      required String nameNormalized,
      Value<String?> difficulty,
      required String primaryMusclesJson,
      required String muscleGroupsJson,
      Value<String?> category,
      required String modality,
      Value<String?> equipment,
      Value<String?> force,
      Value<String?> mechanic,
      required String gripsJson,
      required String stepsJson,
      Value<bool> isFavorite,
      Value<bool> isSubstitutedOut,
      Value<String?> userNotes,
      Value<bool> importedFromShare,
      Value<String?> originalShareKey,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<int> id,
      Value<bool> isCustom,
      Value<String?> customExerciseUuid,
      Value<String> source,
      Value<String?> sourceDatasetVersion,
      Value<int?> sourceSchemaVersion,
      Value<String> name,
      Value<String> nameNormalized,
      Value<String?> difficulty,
      Value<String> primaryMusclesJson,
      Value<String> muscleGroupsJson,
      Value<String?> category,
      Value<String> modality,
      Value<String?> equipment,
      Value<String?> force,
      Value<String?> mechanic,
      Value<String> gripsJson,
      Value<String> stepsJson,
      Value<bool> isFavorite,
      Value<bool> isSubstitutedOut,
      Value<String?> userNotes,
      Value<bool> importedFromShare,
      Value<String?> originalShareKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseVideosTable, List<ExerciseVideo>>
  _exerciseVideosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseVideos,
    aliasName: 'exercises__id__exercise_videos__exercise_id',
  );

  $$ExerciseVideosTableProcessedTableManager get exerciseVideosRefs {
    final manager = $$ExerciseVideosTableTableManager(
      $_db,
      $_db.exerciseVideos,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseVideosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ExerciseAudioCacheTable,
    List<ExerciseAudioCacheData>
  >
  _exerciseAudioCacheRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.exerciseAudioCache,
        aliasName: 'exercises__id__exercise_audio_cache__exercise_id',
      );

  $$ExerciseAudioCacheTableProcessedTableManager get exerciseAudioCacheRefs {
    final manager = $$ExerciseAudioCacheTableTableManager(
      $_db,
      $_db.exerciseAudioCache,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseAudioCacheRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

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

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customExerciseUuid => $composableBuilder(
    column: $table.customExerciseUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceDatasetVersion => $composableBuilder(
    column: $table.sourceDatasetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceSchemaVersion => $composableBuilder(
    column: $table.sourceSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMusclesJson => $composableBuilder(
    column: $table.primaryMusclesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get muscleGroupsJson => $composableBuilder(
    column: $table.muscleGroupsJson,
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

  ColumnFilters<String> get gripsJson => $composableBuilder(
    column: $table.gripsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSubstitutedOut => $composableBuilder(
    column: $table.isSubstitutedOut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userNotes => $composableBuilder(
    column: $table.userNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get importedFromShare => $composableBuilder(
    column: $table.importedFromShare,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalShareKey => $composableBuilder(
    column: $table.originalShareKey,
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

  Expression<bool> exerciseVideosRefs(
    Expression<bool> Function($$ExerciseVideosTableFilterComposer f) f,
  ) {
    final $$ExerciseVideosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseVideos,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseVideosTableFilterComposer(
            $db: $db,
            $table: $db.exerciseVideos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseAudioCacheRefs(
    Expression<bool> Function($$ExerciseAudioCacheTableFilterComposer f) f,
  ) {
    final $$ExerciseAudioCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseAudioCache,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseAudioCacheTableFilterComposer(
            $db: $db,
            $table: $db.exerciseAudioCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
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

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customExerciseUuid => $composableBuilder(
    column: $table.customExerciseUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceDatasetVersion => $composableBuilder(
    column: $table.sourceDatasetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceSchemaVersion => $composableBuilder(
    column: $table.sourceSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMusclesJson => $composableBuilder(
    column: $table.primaryMusclesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroupsJson => $composableBuilder(
    column: $table.muscleGroupsJson,
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

  ColumnOrderings<String> get gripsJson => $composableBuilder(
    column: $table.gripsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSubstitutedOut => $composableBuilder(
    column: $table.isSubstitutedOut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userNotes => $composableBuilder(
    column: $table.userNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get importedFromShare => $composableBuilder(
    column: $table.importedFromShare,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalShareKey => $composableBuilder(
    column: $table.originalShareKey,
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

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<String> get customExerciseUuid => $composableBuilder(
    column: $table.customExerciseUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceDatasetVersion => $composableBuilder(
    column: $table.sourceDatasetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceSchemaVersion => $composableBuilder(
    column: $table.sourceSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryMusclesJson => $composableBuilder(
    column: $table.primaryMusclesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get muscleGroupsJson => $composableBuilder(
    column: $table.muscleGroupsJson,
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

  GeneratedColumn<String> get gripsJson =>
      $composableBuilder(column: $table.gripsJson, builder: (column) => column);

  GeneratedColumn<String> get stepsJson =>
      $composableBuilder(column: $table.stepsJson, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSubstitutedOut => $composableBuilder(
    column: $table.isSubstitutedOut,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userNotes =>
      $composableBuilder(column: $table.userNotes, builder: (column) => column);

  GeneratedColumn<bool> get importedFromShare => $composableBuilder(
    column: $table.importedFromShare,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalShareKey => $composableBuilder(
    column: $table.originalShareKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> exerciseVideosRefs<T extends Object>(
    Expression<T> Function($$ExerciseVideosTableAnnotationComposer a) f,
  ) {
    final $$ExerciseVideosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseVideos,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseVideosTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseVideos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseAudioCacheRefs<T extends Object>(
    Expression<T> Function($$ExerciseAudioCacheTableAnnotationComposer a) f,
  ) {
    final $$ExerciseAudioCacheTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.exerciseAudioCache,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExerciseAudioCacheTableAnnotationComposer(
                $db: $db,
                $table: $db.exerciseAudioCache,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
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
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool exerciseVideosRefs,
            bool exerciseAudioCacheRefs,
          })
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
                Value<bool> isCustom = const Value.absent(),
                Value<String?> customExerciseUuid = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceDatasetVersion = const Value.absent(),
                Value<int?> sourceSchemaVersion = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameNormalized = const Value.absent(),
                Value<String?> difficulty = const Value.absent(),
                Value<String> primaryMusclesJson = const Value.absent(),
                Value<String> muscleGroupsJson = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<String> modality = const Value.absent(),
                Value<String?> equipment = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                Value<String> gripsJson = const Value.absent(),
                Value<String> stepsJson = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isSubstitutedOut = const Value.absent(),
                Value<String?> userNotes = const Value.absent(),
                Value<bool> importedFromShare = const Value.absent(),
                Value<String?> originalShareKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                isCustom: isCustom,
                customExerciseUuid: customExerciseUuid,
                source: source,
                sourceDatasetVersion: sourceDatasetVersion,
                sourceSchemaVersion: sourceSchemaVersion,
                name: name,
                nameNormalized: nameNormalized,
                difficulty: difficulty,
                primaryMusclesJson: primaryMusclesJson,
                muscleGroupsJson: muscleGroupsJson,
                category: category,
                modality: modality,
                equipment: equipment,
                force: force,
                mechanic: mechanic,
                gripsJson: gripsJson,
                stepsJson: stepsJson,
                isFavorite: isFavorite,
                isSubstitutedOut: isSubstitutedOut,
                userNotes: userNotes,
                importedFromShare: importedFromShare,
                originalShareKey: originalShareKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<String?> customExerciseUuid = const Value.absent(),
                required String source,
                Value<String?> sourceDatasetVersion = const Value.absent(),
                Value<int?> sourceSchemaVersion = const Value.absent(),
                required String name,
                required String nameNormalized,
                Value<String?> difficulty = const Value.absent(),
                required String primaryMusclesJson,
                required String muscleGroupsJson,
                Value<String?> category = const Value.absent(),
                required String modality,
                Value<String?> equipment = const Value.absent(),
                Value<String?> force = const Value.absent(),
                Value<String?> mechanic = const Value.absent(),
                required String gripsJson,
                required String stepsJson,
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isSubstitutedOut = const Value.absent(),
                Value<String?> userNotes = const Value.absent(),
                Value<bool> importedFromShare = const Value.absent(),
                Value<String?> originalShareKey = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                isCustom: isCustom,
                customExerciseUuid: customExerciseUuid,
                source: source,
                sourceDatasetVersion: sourceDatasetVersion,
                sourceSchemaVersion: sourceSchemaVersion,
                name: name,
                nameNormalized: nameNormalized,
                difficulty: difficulty,
                primaryMusclesJson: primaryMusclesJson,
                muscleGroupsJson: muscleGroupsJson,
                category: category,
                modality: modality,
                equipment: equipment,
                force: force,
                mechanic: mechanic,
                gripsJson: gripsJson,
                stepsJson: stepsJson,
                isFavorite: isFavorite,
                isSubstitutedOut: isSubstitutedOut,
                userNotes: userNotes,
                importedFromShare: importedFromShare,
                originalShareKey: originalShareKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({exerciseVideosRefs = false, exerciseAudioCacheRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (exerciseVideosRefs) db.exerciseVideos,
                    if (exerciseAudioCacheRefs) db.exerciseAudioCache,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (exerciseVideosRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseVideo
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseVideosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseVideosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (exerciseAudioCacheRefs)
                        await $_getPrefetchedData<
                          Exercise,
                          $ExercisesTable,
                          ExerciseAudioCacheData
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseAudioCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseAudioCacheRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
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
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool exerciseVideosRefs,
        bool exerciseAudioCacheRefs,
      })
    >;
typedef $$LocalFileRecordsTableCreateCompanionBuilder =
    LocalFileRecordsCompanion Function({
      Value<int> id,
      required String category,
      required String ownerType,
      Value<String?> ownerId,
      required String localRelativePath,
      required int fileSizeBytes,
      Value<String?> contentHash,
      Value<String?> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationSeconds,
      required DateTime createdAt,
      Value<DateTime?> lastVerifiedAt,
    });
typedef $$LocalFileRecordsTableUpdateCompanionBuilder =
    LocalFileRecordsCompanion Function({
      Value<int> id,
      Value<String> category,
      Value<String> ownerType,
      Value<String?> ownerId,
      Value<String> localRelativePath,
      Value<int> fileSizeBytes,
      Value<String?> contentHash,
      Value<String?> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationSeconds,
      Value<DateTime> createdAt,
      Value<DateTime?> lastVerifiedAt,
    });

class $$LocalFileRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalFileRecordsTable> {
  $$LocalFileRecordsTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localRelativePath => $composableBuilder(
    column: $table.localRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalFileRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalFileRecordsTable> {
  $$LocalFileRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerType => $composableBuilder(
    column: $table.ownerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localRelativePath => $composableBuilder(
    column: $table.localRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalFileRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalFileRecordsTable> {
  $$LocalFileRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get ownerType =>
      $composableBuilder(column: $table.ownerType, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get localRelativePath => $composableBuilder(
    column: $table.localRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastVerifiedAt => $composableBuilder(
    column: $table.lastVerifiedAt,
    builder: (column) => column,
  );
}

class $$LocalFileRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalFileRecordsTable,
          LocalFileRecord,
          $$LocalFileRecordsTableFilterComposer,
          $$LocalFileRecordsTableOrderingComposer,
          $$LocalFileRecordsTableAnnotationComposer,
          $$LocalFileRecordsTableCreateCompanionBuilder,
          $$LocalFileRecordsTableUpdateCompanionBuilder,
          (
            LocalFileRecord,
            BaseReferences<
              _$AppDatabase,
              $LocalFileRecordsTable,
              LocalFileRecord
            >,
          ),
          LocalFileRecord,
          PrefetchHooks Function()
        > {
  $$LocalFileRecordsTableTableManager(
    _$AppDatabase db,
    $LocalFileRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalFileRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalFileRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalFileRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> ownerType = const Value.absent(),
                Value<String?> ownerId = const Value.absent(),
                Value<String> localRelativePath = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
              }) => LocalFileRecordsCompanion(
                id: id,
                category: category,
                ownerType: ownerType,
                ownerId: ownerId,
                localRelativePath: localRelativePath,
                fileSizeBytes: fileSizeBytes,
                contentHash: contentHash,
                mimeType: mimeType,
                width: width,
                height: height,
                durationSeconds: durationSeconds,
                createdAt: createdAt,
                lastVerifiedAt: lastVerifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String category,
                required String ownerType,
                Value<String?> ownerId = const Value.absent(),
                required String localRelativePath,
                required int fileSizeBytes,
                Value<String?> contentHash = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> lastVerifiedAt = const Value.absent(),
              }) => LocalFileRecordsCompanion.insert(
                id: id,
                category: category,
                ownerType: ownerType,
                ownerId: ownerId,
                localRelativePath: localRelativePath,
                fileSizeBytes: fileSizeBytes,
                contentHash: contentHash,
                mimeType: mimeType,
                width: width,
                height: height,
                durationSeconds: durationSeconds,
                createdAt: createdAt,
                lastVerifiedAt: lastVerifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalFileRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalFileRecordsTable,
      LocalFileRecord,
      $$LocalFileRecordsTableFilterComposer,
      $$LocalFileRecordsTableOrderingComposer,
      $$LocalFileRecordsTableAnnotationComposer,
      $$LocalFileRecordsTableCreateCompanionBuilder,
      $$LocalFileRecordsTableUpdateCompanionBuilder,
      (
        LocalFileRecord,
        BaseReferences<_$AppDatabase, $LocalFileRecordsTable, LocalFileRecord>,
      ),
      LocalFileRecord,
      PrefetchHooks Function()
    >;
typedef $$SchemaMigrationsLogTableCreateCompanionBuilder =
    SchemaMigrationsLogCompanion Function({
      Value<int> id,
      required int fromVersion,
      required int toVersion,
      required DateTime appliedAt,
      Value<String?> notes,
    });
typedef $$SchemaMigrationsLogTableUpdateCompanionBuilder =
    SchemaMigrationsLogCompanion Function({
      Value<int> id,
      Value<int> fromVersion,
      Value<int> toVersion,
      Value<DateTime> appliedAt,
      Value<String?> notes,
    });

class $$SchemaMigrationsLogTableFilterComposer
    extends Composer<_$AppDatabase, $SchemaMigrationsLogTable> {
  $$SchemaMigrationsLogTableFilterComposer({
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

  ColumnFilters<int> get fromVersion => $composableBuilder(
    column: $table.fromVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toVersion => $composableBuilder(
    column: $table.toVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchemaMigrationsLogTableOrderingComposer
    extends Composer<_$AppDatabase, $SchemaMigrationsLogTable> {
  $$SchemaMigrationsLogTableOrderingComposer({
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

  ColumnOrderings<int> get fromVersion => $composableBuilder(
    column: $table.fromVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toVersion => $composableBuilder(
    column: $table.toVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get appliedAt => $composableBuilder(
    column: $table.appliedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchemaMigrationsLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchemaMigrationsLogTable> {
  $$SchemaMigrationsLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fromVersion => $composableBuilder(
    column: $table.fromVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toVersion =>
      $composableBuilder(column: $table.toVersion, builder: (column) => column);

  GeneratedColumn<DateTime> get appliedAt =>
      $composableBuilder(column: $table.appliedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$SchemaMigrationsLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchemaMigrationsLogTable,
          SchemaMigrationsLogData,
          $$SchemaMigrationsLogTableFilterComposer,
          $$SchemaMigrationsLogTableOrderingComposer,
          $$SchemaMigrationsLogTableAnnotationComposer,
          $$SchemaMigrationsLogTableCreateCompanionBuilder,
          $$SchemaMigrationsLogTableUpdateCompanionBuilder,
          (
            SchemaMigrationsLogData,
            BaseReferences<
              _$AppDatabase,
              $SchemaMigrationsLogTable,
              SchemaMigrationsLogData
            >,
          ),
          SchemaMigrationsLogData,
          PrefetchHooks Function()
        > {
  $$SchemaMigrationsLogTableTableManager(
    _$AppDatabase db,
    $SchemaMigrationsLogTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchemaMigrationsLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchemaMigrationsLogTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SchemaMigrationsLogTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> fromVersion = const Value.absent(),
                Value<int> toVersion = const Value.absent(),
                Value<DateTime> appliedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SchemaMigrationsLogCompanion(
                id: id,
                fromVersion: fromVersion,
                toVersion: toVersion,
                appliedAt: appliedAt,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int fromVersion,
                required int toVersion,
                required DateTime appliedAt,
                Value<String?> notes = const Value.absent(),
              }) => SchemaMigrationsLogCompanion.insert(
                id: id,
                fromVersion: fromVersion,
                toVersion: toVersion,
                appliedAt: appliedAt,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchemaMigrationsLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchemaMigrationsLogTable,
      SchemaMigrationsLogData,
      $$SchemaMigrationsLogTableFilterComposer,
      $$SchemaMigrationsLogTableOrderingComposer,
      $$SchemaMigrationsLogTableAnnotationComposer,
      $$SchemaMigrationsLogTableCreateCompanionBuilder,
      $$SchemaMigrationsLogTableUpdateCompanionBuilder,
      (
        SchemaMigrationsLogData,
        BaseReferences<
          _$AppDatabase,
          $SchemaMigrationsLogTable,
          SchemaMigrationsLogData
        >,
      ),
      SchemaMigrationsLogData,
      PrefetchHooks Function()
    >;
typedef $$LibraryMetaTableCreateCompanionBuilder =
    LibraryMetaCompanion Function({
      Value<String> id,
      required String source,
      required int schemaVersion,
      Value<String?> libraryVersion,
      Value<DateTime?> generatedAt,
      Value<DateTime?> downloadedAt,
      Value<int> exerciseCount,
      Value<DateTime?> manifestLastUpdatedAt,
      Value<String?> manifestFilePath,
      Value<int?> minAppSchemaVersion,
      required String syncStatus,
      Value<String?> lastSyncErrorCode,
      Value<String?> lastSyncErrorMessage,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LibraryMetaTableUpdateCompanionBuilder =
    LibraryMetaCompanion Function({
      Value<String> id,
      Value<String> source,
      Value<int> schemaVersion,
      Value<String?> libraryVersion,
      Value<DateTime?> generatedAt,
      Value<DateTime?> downloadedAt,
      Value<int> exerciseCount,
      Value<DateTime?> manifestLastUpdatedAt,
      Value<String?> manifestFilePath,
      Value<int?> minAppSchemaVersion,
      Value<String> syncStatus,
      Value<String?> lastSyncErrorCode,
      Value<String?> lastSyncErrorMessage,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LibraryMetaTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryMetaTable> {
  $$LibraryMetaTableFilterComposer({
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

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get libraryVersion => $composableBuilder(
    column: $table.libraryVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exerciseCount => $composableBuilder(
    column: $table.exerciseCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get manifestLastUpdatedAt => $composableBuilder(
    column: $table.manifestLastUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get manifestFilePath => $composableBuilder(
    column: $table.manifestFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minAppSchemaVersion => $composableBuilder(
    column: $table.minAppSchemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncErrorCode => $composableBuilder(
    column: $table.lastSyncErrorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastSyncErrorMessage => $composableBuilder(
    column: $table.lastSyncErrorMessage,
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
}

class $$LibraryMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryMetaTable> {
  $$LibraryMetaTableOrderingComposer({
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get libraryVersion => $composableBuilder(
    column: $table.libraryVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exerciseCount => $composableBuilder(
    column: $table.exerciseCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get manifestLastUpdatedAt => $composableBuilder(
    column: $table.manifestLastUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifestFilePath => $composableBuilder(
    column: $table.manifestFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minAppSchemaVersion => $composableBuilder(
    column: $table.minAppSchemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncErrorCode => $composableBuilder(
    column: $table.lastSyncErrorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastSyncErrorMessage => $composableBuilder(
    column: $table.lastSyncErrorMessage,
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
}

class $$LibraryMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryMetaTable> {
  $$LibraryMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get libraryVersion => $composableBuilder(
    column: $table.libraryVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exerciseCount => $composableBuilder(
    column: $table.exerciseCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get manifestLastUpdatedAt => $composableBuilder(
    column: $table.manifestLastUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get manifestFilePath => $composableBuilder(
    column: $table.manifestFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minAppSchemaVersion => $composableBuilder(
    column: $table.minAppSchemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncErrorCode => $composableBuilder(
    column: $table.lastSyncErrorCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastSyncErrorMessage => $composableBuilder(
    column: $table.lastSyncErrorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LibraryMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryMetaTable,
          LibraryMetaData,
          $$LibraryMetaTableFilterComposer,
          $$LibraryMetaTableOrderingComposer,
          $$LibraryMetaTableAnnotationComposer,
          $$LibraryMetaTableCreateCompanionBuilder,
          $$LibraryMetaTableUpdateCompanionBuilder,
          (
            LibraryMetaData,
            BaseReferences<_$AppDatabase, $LibraryMetaTable, LibraryMetaData>,
          ),
          LibraryMetaData,
          PrefetchHooks Function()
        > {
  $$LibraryMetaTableTableManager(_$AppDatabase db, $LibraryMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String?> libraryVersion = const Value.absent(),
                Value<DateTime?> generatedAt = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<int> exerciseCount = const Value.absent(),
                Value<DateTime?> manifestLastUpdatedAt = const Value.absent(),
                Value<String?> manifestFilePath = const Value.absent(),
                Value<int?> minAppSchemaVersion = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<String?> lastSyncErrorCode = const Value.absent(),
                Value<String?> lastSyncErrorMessage = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryMetaCompanion(
                id: id,
                source: source,
                schemaVersion: schemaVersion,
                libraryVersion: libraryVersion,
                generatedAt: generatedAt,
                downloadedAt: downloadedAt,
                exerciseCount: exerciseCount,
                manifestLastUpdatedAt: manifestLastUpdatedAt,
                manifestFilePath: manifestFilePath,
                minAppSchemaVersion: minAppSchemaVersion,
                syncStatus: syncStatus,
                lastSyncErrorCode: lastSyncErrorCode,
                lastSyncErrorMessage: lastSyncErrorMessage,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String source,
                required int schemaVersion,
                Value<String?> libraryVersion = const Value.absent(),
                Value<DateTime?> generatedAt = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<int> exerciseCount = const Value.absent(),
                Value<DateTime?> manifestLastUpdatedAt = const Value.absent(),
                Value<String?> manifestFilePath = const Value.absent(),
                Value<int?> minAppSchemaVersion = const Value.absent(),
                required String syncStatus,
                Value<String?> lastSyncErrorCode = const Value.absent(),
                Value<String?> lastSyncErrorMessage = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LibraryMetaCompanion.insert(
                id: id,
                source: source,
                schemaVersion: schemaVersion,
                libraryVersion: libraryVersion,
                generatedAt: generatedAt,
                downloadedAt: downloadedAt,
                exerciseCount: exerciseCount,
                manifestLastUpdatedAt: manifestLastUpdatedAt,
                manifestFilePath: manifestFilePath,
                minAppSchemaVersion: minAppSchemaVersion,
                syncStatus: syncStatus,
                lastSyncErrorCode: lastSyncErrorCode,
                lastSyncErrorMessage: lastSyncErrorMessage,
                createdAt: createdAt,
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

typedef $$LibraryMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryMetaTable,
      LibraryMetaData,
      $$LibraryMetaTableFilterComposer,
      $$LibraryMetaTableOrderingComposer,
      $$LibraryMetaTableAnnotationComposer,
      $$LibraryMetaTableCreateCompanionBuilder,
      $$LibraryMetaTableUpdateCompanionBuilder,
      (
        LibraryMetaData,
        BaseReferences<_$AppDatabase, $LibraryMetaTable, LibraryMetaData>,
      ),
      LibraryMetaData,
      PrefetchHooks Function()
    >;
typedef $$ExerciseVideosTableCreateCompanionBuilder =
    ExerciseVideosCompanion Function({
      required String id,
      required int exerciseId,
      required String url,
      Value<String?> angle,
      Value<String?> gender,
      Value<String?> ogImageUrl,
      Value<int> sortOrder,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ExerciseVideosTableUpdateCompanionBuilder =
    ExerciseVideosCompanion Function({
      Value<String> id,
      Value<int> exerciseId,
      Value<String> url,
      Value<String?> angle,
      Value<String?> gender,
      Value<String?> ogImageUrl,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ExerciseVideosTableReferences
    extends BaseReferences<_$AppDatabase, $ExerciseVideosTable, ExerciseVideo> {
  $$ExerciseVideosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_videos__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseVideosTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseVideosTable> {
  $$ExerciseVideosTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get angle => $composableBuilder(
    column: $table.angle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ogImageUrl => $composableBuilder(
    column: $table.ogImageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseVideosTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseVideosTable> {
  $$ExerciseVideosTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get angle => $composableBuilder(
    column: $table.angle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ogImageUrl => $composableBuilder(
    column: $table.ogImageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseVideosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseVideosTable> {
  $$ExerciseVideosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get angle =>
      $composableBuilder(column: $table.angle, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get ogImageUrl => $composableBuilder(
    column: $table.ogImageUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseVideosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseVideosTable,
          ExerciseVideo,
          $$ExerciseVideosTableFilterComposer,
          $$ExerciseVideosTableOrderingComposer,
          $$ExerciseVideosTableAnnotationComposer,
          $$ExerciseVideosTableCreateCompanionBuilder,
          $$ExerciseVideosTableUpdateCompanionBuilder,
          (ExerciseVideo, $$ExerciseVideosTableReferences),
          ExerciseVideo,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseVideosTableTableManager(
    _$AppDatabase db,
    $ExerciseVideosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseVideosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseVideosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseVideosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String?> angle = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> ogImageUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseVideosCompanion(
                id: id,
                exerciseId: exerciseId,
                url: url,
                angle: angle,
                gender: gender,
                ogImageUrl: ogImageUrl,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int exerciseId,
                required String url,
                Value<String?> angle = const Value.absent(),
                Value<String?> gender = const Value.absent(),
                Value<String?> ogImageUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseVideosCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                url: url,
                angle: angle,
                gender: gender,
                ogImageUrl: ogImageUrl,
                sortOrder: sortOrder,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseVideosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$ExerciseVideosTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ExerciseVideosTableReferences
                                        ._exerciseIdTable(db)
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

typedef $$ExerciseVideosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseVideosTable,
      ExerciseVideo,
      $$ExerciseVideosTableFilterComposer,
      $$ExerciseVideosTableOrderingComposer,
      $$ExerciseVideosTableAnnotationComposer,
      $$ExerciseVideosTableCreateCompanionBuilder,
      $$ExerciseVideosTableUpdateCompanionBuilder,
      (ExerciseVideo, $$ExerciseVideosTableReferences),
      ExerciseVideo,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$ExerciseAudioCacheTableCreateCompanionBuilder =
    ExerciseAudioCacheCompanion Function({
      required String id,
      required int exerciseId,
      required int stepIndex,
      required String textHash,
      required String localRelativePath,
      Value<int?> fileSizeBytes,
      Value<String?> voiceId,
      required DateTime generatedAt,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });
typedef $$ExerciseAudioCacheTableUpdateCompanionBuilder =
    ExerciseAudioCacheCompanion Function({
      Value<String> id,
      Value<int> exerciseId,
      Value<int> stepIndex,
      Value<String> textHash,
      Value<String> localRelativePath,
      Value<int?> fileSizeBytes,
      Value<String?> voiceId,
      Value<DateTime> generatedAt,
      Value<DateTime?> lastAccessedAt,
      Value<int> rowid,
    });

final class $$ExerciseAudioCacheTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseAudioCacheTable,
          ExerciseAudioCacheData
        > {
  $$ExerciseAudioCacheTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('exercise_audio_cache__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<int>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseAudioCacheTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseAudioCacheTable> {
  $$ExerciseAudioCacheTableFilterComposer({
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

  ColumnFilters<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textHash => $composableBuilder(
    column: $table.textHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localRelativePath => $composableBuilder(
    column: $table.localRelativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voiceId => $composableBuilder(
    column: $table.voiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseAudioCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseAudioCacheTable> {
  $$ExerciseAudioCacheTableOrderingComposer({
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

  ColumnOrderings<int> get stepIndex => $composableBuilder(
    column: $table.stepIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textHash => $composableBuilder(
    column: $table.textHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localRelativePath => $composableBuilder(
    column: $table.localRelativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voiceId => $composableBuilder(
    column: $table.voiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseAudioCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseAudioCacheTable> {
  $$ExerciseAudioCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get stepIndex =>
      $composableBuilder(column: $table.stepIndex, builder: (column) => column);

  GeneratedColumn<String> get textHash =>
      $composableBuilder(column: $table.textHash, builder: (column) => column);

  GeneratedColumn<String> get localRelativePath => $composableBuilder(
    column: $table.localRelativePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voiceId =>
      $composableBuilder(column: $table.voiceId, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseAudioCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseAudioCacheTable,
          ExerciseAudioCacheData,
          $$ExerciseAudioCacheTableFilterComposer,
          $$ExerciseAudioCacheTableOrderingComposer,
          $$ExerciseAudioCacheTableAnnotationComposer,
          $$ExerciseAudioCacheTableCreateCompanionBuilder,
          $$ExerciseAudioCacheTableUpdateCompanionBuilder,
          (ExerciseAudioCacheData, $$ExerciseAudioCacheTableReferences),
          ExerciseAudioCacheData,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseAudioCacheTableTableManager(
    _$AppDatabase db,
    $ExerciseAudioCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseAudioCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseAudioCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseAudioCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> exerciseId = const Value.absent(),
                Value<int> stepIndex = const Value.absent(),
                Value<String> textHash = const Value.absent(),
                Value<String> localRelativePath = const Value.absent(),
                Value<int?> fileSizeBytes = const Value.absent(),
                Value<String?> voiceId = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseAudioCacheCompanion(
                id: id,
                exerciseId: exerciseId,
                stepIndex: stepIndex,
                textHash: textHash,
                localRelativePath: localRelativePath,
                fileSizeBytes: fileSizeBytes,
                voiceId: voiceId,
                generatedAt: generatedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int exerciseId,
                required int stepIndex,
                required String textHash,
                required String localRelativePath,
                Value<int?> fileSizeBytes = const Value.absent(),
                Value<String?> voiceId = const Value.absent(),
                required DateTime generatedAt,
                Value<DateTime?> lastAccessedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseAudioCacheCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                stepIndex: stepIndex,
                textHash: textHash,
                localRelativePath: localRelativePath,
                fileSizeBytes: fileSizeBytes,
                voiceId: voiceId,
                generatedAt: generatedAt,
                lastAccessedAt: lastAccessedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExerciseAudioCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
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
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$ExerciseAudioCacheTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$ExerciseAudioCacheTableReferences
                                        ._exerciseIdTable(db)
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

typedef $$ExerciseAudioCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseAudioCacheTable,
      ExerciseAudioCacheData,
      $$ExerciseAudioCacheTableFilterComposer,
      $$ExerciseAudioCacheTableOrderingComposer,
      $$ExerciseAudioCacheTableAnnotationComposer,
      $$ExerciseAudioCacheTableCreateCompanionBuilder,
      $$ExerciseAudioCacheTableUpdateCompanionBuilder,
      (ExerciseAudioCacheData, $$ExerciseAudioCacheTableReferences),
      ExerciseAudioCacheData,
      PrefetchHooks Function({bool exerciseId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchemaMetaTableTableManager get schemaMeta =>
      $$SchemaMetaTableTableManager(_db, _db.schemaMeta);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$LocalFileRecordsTableTableManager get localFileRecords =>
      $$LocalFileRecordsTableTableManager(_db, _db.localFileRecords);
  $$SchemaMigrationsLogTableTableManager get schemaMigrationsLog =>
      $$SchemaMigrationsLogTableTableManager(_db, _db.schemaMigrationsLog);
  $$LibraryMetaTableTableManager get libraryMeta =>
      $$LibraryMetaTableTableManager(_db, _db.libraryMeta);
  $$ExerciseVideosTableTableManager get exerciseVideos =>
      $$ExerciseVideosTableTableManager(_db, _db.exerciseVideos);
  $$ExerciseAudioCacheTableTableManager get exerciseAudioCache =>
      $$ExerciseAudioCacheTableTableManager(_db, _db.exerciseAudioCache);
}
