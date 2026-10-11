// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kakebo_database.dart';

// ignore_for_file: type=lint
class $MonthlyPlansTable extends MonthlyPlans
    with TableInfo<$MonthlyPlansTable, MonthlyPlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savingsGroszMeta = const VerificationMeta(
    'savingsGrosz',
  );
  @override
  late final GeneratedColumn<int> savingsGrosz = GeneratedColumn<int>(
    'savingsGrosz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolutionsMeta = const VerificationMeta(
    'resolutions',
  );
  @override
  late final GeneratedColumn<String> resolutions = GeneratedColumn<String>(
    'resolutions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [month, savingsGrosz, resolutions];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlyPlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('savingsGrosz')) {
      context.handle(
        _savingsGroszMeta,
        savingsGrosz.isAcceptableOrUnknown(
          data['savingsGrosz']!,
          _savingsGroszMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_savingsGroszMeta);
    }
    if (data.containsKey('resolutions')) {
      context.handle(
        _resolutionsMeta,
        resolutions.isAcceptableOrUnknown(
          data['resolutions']!,
          _resolutionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resolutionsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {month};
  @override
  MonthlyPlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyPlanRow(
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      savingsGrosz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}savingsGrosz'],
      )!,
      resolutions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolutions'],
      )!,
    );
  }

  @override
  $MonthlyPlansTable createAlias(String alias) {
    return $MonthlyPlansTable(attachedDatabase, alias);
  }
}

class MonthlyPlanRow extends DataClass implements Insertable<MonthlyPlanRow> {
  final String month;
  final int savingsGrosz;
  final String resolutions;
  const MonthlyPlanRow({
    required this.month,
    required this.savingsGrosz,
    required this.resolutions,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['month'] = Variable<String>(month);
    map['savingsGrosz'] = Variable<int>(savingsGrosz);
    map['resolutions'] = Variable<String>(resolutions);
    return map;
  }

  MonthlyPlansCompanion toCompanion(bool nullToAbsent) {
    return MonthlyPlansCompanion(
      month: Value(month),
      savingsGrosz: Value(savingsGrosz),
      resolutions: Value(resolutions),
    );
  }

  factory MonthlyPlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyPlanRow(
      month: serializer.fromJson<String>(json['month']),
      savingsGrosz: serializer.fromJson<int>(json['savingsGrosz']),
      resolutions: serializer.fromJson<String>(json['resolutions']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'month': serializer.toJson<String>(month),
      'savingsGrosz': serializer.toJson<int>(savingsGrosz),
      'resolutions': serializer.toJson<String>(resolutions),
    };
  }

  MonthlyPlanRow copyWith({
    String? month,
    int? savingsGrosz,
    String? resolutions,
  }) => MonthlyPlanRow(
    month: month ?? this.month,
    savingsGrosz: savingsGrosz ?? this.savingsGrosz,
    resolutions: resolutions ?? this.resolutions,
  );
  MonthlyPlanRow copyWithCompanion(MonthlyPlansCompanion data) {
    return MonthlyPlanRow(
      month: data.month.present ? data.month.value : this.month,
      savingsGrosz: data.savingsGrosz.present
          ? data.savingsGrosz.value
          : this.savingsGrosz,
      resolutions: data.resolutions.present
          ? data.resolutions.value
          : this.resolutions,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyPlanRow(')
          ..write('month: $month, ')
          ..write('savingsGrosz: $savingsGrosz, ')
          ..write('resolutions: $resolutions')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(month, savingsGrosz, resolutions);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyPlanRow &&
          other.month == this.month &&
          other.savingsGrosz == this.savingsGrosz &&
          other.resolutions == this.resolutions);
}

class MonthlyPlansCompanion extends UpdateCompanion<MonthlyPlanRow> {
  final Value<String> month;
  final Value<int> savingsGrosz;
  final Value<String> resolutions;
  final Value<int> rowid;
  const MonthlyPlansCompanion({
    this.month = const Value.absent(),
    this.savingsGrosz = const Value.absent(),
    this.resolutions = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlyPlansCompanion.insert({
    required String month,
    required int savingsGrosz,
    required String resolutions,
    this.rowid = const Value.absent(),
  }) : month = Value(month),
       savingsGrosz = Value(savingsGrosz),
       resolutions = Value(resolutions);
  static Insertable<MonthlyPlanRow> custom({
    Expression<String>? month,
    Expression<int>? savingsGrosz,
    Expression<String>? resolutions,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (month != null) 'month': month,
      if (savingsGrosz != null) 'savingsGrosz': savingsGrosz,
      if (resolutions != null) 'resolutions': resolutions,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlyPlansCompanion copyWith({
    Value<String>? month,
    Value<int>? savingsGrosz,
    Value<String>? resolutions,
    Value<int>? rowid,
  }) {
    return MonthlyPlansCompanion(
      month: month ?? this.month,
      savingsGrosz: savingsGrosz ?? this.savingsGrosz,
      resolutions: resolutions ?? this.resolutions,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (savingsGrosz.present) {
      map['savingsGrosz'] = Variable<int>(savingsGrosz.value);
    }
    if (resolutions.present) {
      map['resolutions'] = Variable<String>(resolutions.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyPlansCompanion(')
          ..write('month: $month, ')
          ..write('savingsGrosz: $savingsGrosz, ')
          ..write('resolutions: $resolutions, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlannedItemsTable extends PlannedItems
    with TableInfo<$PlannedItemsTable, PlannedItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlannedItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES monthly_plans (month) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountGroszMeta = const VerificationMeta(
    'amountGrosz',
  );
  @override
  late final GeneratedColumn<int> amountGrosz = GeneratedColumn<int>(
    'amountGrosz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateEpochDayMeta = const VerificationMeta(
    'dateEpochDay',
  );
  @override
  late final GeneratedColumn<int> dateEpochDay = GeneratedColumn<int>(
    'dateEpochDay',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MONTHLY'),
  );
  static const VerificationMeta _recurrenceAnchorMonthMeta =
      const VerificationMeta('recurrenceAnchorMonth');
  @override
  late final GeneratedColumn<String> recurrenceAnchorMonth =
      GeneratedColumn<String>(
        'recurrenceAnchorMonth',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    month,
    type,
    title,
    amountGrosz,
    dateEpochDay,
    recurrence,
    recurrenceAnchorMonth,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'planned_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlannedItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amountGrosz')) {
      context.handle(
        _amountGroszMeta,
        amountGrosz.isAcceptableOrUnknown(
          data['amountGrosz']!,
          _amountGroszMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountGroszMeta);
    }
    if (data.containsKey('dateEpochDay')) {
      context.handle(
        _dateEpochDayMeta,
        dateEpochDay.isAcceptableOrUnknown(
          data['dateEpochDay']!,
          _dateEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateEpochDayMeta);
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('recurrenceAnchorMonth')) {
      context.handle(
        _recurrenceAnchorMonthMeta,
        recurrenceAnchorMonth.isAcceptableOrUnknown(
          data['recurrenceAnchorMonth']!,
          _recurrenceAnchorMonthMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlannedItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlannedItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      amountGrosz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amountGrosz'],
      )!,
      dateEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dateEpochDay'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      recurrenceAnchorMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrenceAnchorMonth'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
    );
  }

  @override
  $PlannedItemsTable createAlias(String alias) {
    return $PlannedItemsTable(attachedDatabase, alias);
  }
}

class PlannedItemRow extends DataClass implements Insertable<PlannedItemRow> {
  final int id;
  final String month;
  final String type;
  final String title;
  final int amountGrosz;
  final int dateEpochDay;
  final String recurrence;
  final String recurrenceAnchorMonth;
  final String icon;
  const PlannedItemRow({
    required this.id,
    required this.month,
    required this.type,
    required this.title,
    required this.amountGrosz,
    required this.dateEpochDay,
    required this.recurrence,
    required this.recurrenceAnchorMonth,
    required this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['month'] = Variable<String>(month);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['amountGrosz'] = Variable<int>(amountGrosz);
    map['dateEpochDay'] = Variable<int>(dateEpochDay);
    map['recurrence'] = Variable<String>(recurrence);
    map['recurrenceAnchorMonth'] = Variable<String>(recurrenceAnchorMonth);
    map['icon'] = Variable<String>(icon);
    return map;
  }

  PlannedItemsCompanion toCompanion(bool nullToAbsent) {
    return PlannedItemsCompanion(
      id: Value(id),
      month: Value(month),
      type: Value(type),
      title: Value(title),
      amountGrosz: Value(amountGrosz),
      dateEpochDay: Value(dateEpochDay),
      recurrence: Value(recurrence),
      recurrenceAnchorMonth: Value(recurrenceAnchorMonth),
      icon: Value(icon),
    );
  }

  factory PlannedItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlannedItemRow(
      id: serializer.fromJson<int>(json['id']),
      month: serializer.fromJson<String>(json['month']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      amountGrosz: serializer.fromJson<int>(json['amountGrosz']),
      dateEpochDay: serializer.fromJson<int>(json['dateEpochDay']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      recurrenceAnchorMonth: serializer.fromJson<String>(
        json['recurrenceAnchorMonth'],
      ),
      icon: serializer.fromJson<String>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'month': serializer.toJson<String>(month),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'amountGrosz': serializer.toJson<int>(amountGrosz),
      'dateEpochDay': serializer.toJson<int>(dateEpochDay),
      'recurrence': serializer.toJson<String>(recurrence),
      'recurrenceAnchorMonth': serializer.toJson<String>(recurrenceAnchorMonth),
      'icon': serializer.toJson<String>(icon),
    };
  }

  PlannedItemRow copyWith({
    int? id,
    String? month,
    String? type,
    String? title,
    int? amountGrosz,
    int? dateEpochDay,
    String? recurrence,
    String? recurrenceAnchorMonth,
    String? icon,
  }) => PlannedItemRow(
    id: id ?? this.id,
    month: month ?? this.month,
    type: type ?? this.type,
    title: title ?? this.title,
    amountGrosz: amountGrosz ?? this.amountGrosz,
    dateEpochDay: dateEpochDay ?? this.dateEpochDay,
    recurrence: recurrence ?? this.recurrence,
    recurrenceAnchorMonth: recurrenceAnchorMonth ?? this.recurrenceAnchorMonth,
    icon: icon ?? this.icon,
  );
  PlannedItemRow copyWithCompanion(PlannedItemsCompanion data) {
    return PlannedItemRow(
      id: data.id.present ? data.id.value : this.id,
      month: data.month.present ? data.month.value : this.month,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      amountGrosz: data.amountGrosz.present
          ? data.amountGrosz.value
          : this.amountGrosz,
      dateEpochDay: data.dateEpochDay.present
          ? data.dateEpochDay.value
          : this.dateEpochDay,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      recurrenceAnchorMonth: data.recurrenceAnchorMonth.present
          ? data.recurrenceAnchorMonth.value
          : this.recurrenceAnchorMonth,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlannedItemRow(')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('amountGrosz: $amountGrosz, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceAnchorMonth: $recurrenceAnchorMonth, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    month,
    type,
    title,
    amountGrosz,
    dateEpochDay,
    recurrence,
    recurrenceAnchorMonth,
    icon,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlannedItemRow &&
          other.id == this.id &&
          other.month == this.month &&
          other.type == this.type &&
          other.title == this.title &&
          other.amountGrosz == this.amountGrosz &&
          other.dateEpochDay == this.dateEpochDay &&
          other.recurrence == this.recurrence &&
          other.recurrenceAnchorMonth == this.recurrenceAnchorMonth &&
          other.icon == this.icon);
}

class PlannedItemsCompanion extends UpdateCompanion<PlannedItemRow> {
  final Value<int> id;
  final Value<String> month;
  final Value<String> type;
  final Value<String> title;
  final Value<int> amountGrosz;
  final Value<int> dateEpochDay;
  final Value<String> recurrence;
  final Value<String> recurrenceAnchorMonth;
  final Value<String> icon;
  const PlannedItemsCompanion({
    this.id = const Value.absent(),
    this.month = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.amountGrosz = const Value.absent(),
    this.dateEpochDay = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.recurrenceAnchorMonth = const Value.absent(),
    this.icon = const Value.absent(),
  });
  PlannedItemsCompanion.insert({
    this.id = const Value.absent(),
    required String month,
    required String type,
    required String title,
    required int amountGrosz,
    required int dateEpochDay,
    this.recurrence = const Value.absent(),
    this.recurrenceAnchorMonth = const Value.absent(),
    this.icon = const Value.absent(),
  }) : month = Value(month),
       type = Value(type),
       title = Value(title),
       amountGrosz = Value(amountGrosz),
       dateEpochDay = Value(dateEpochDay);
  static Insertable<PlannedItemRow> custom({
    Expression<int>? id,
    Expression<String>? month,
    Expression<String>? type,
    Expression<String>? title,
    Expression<int>? amountGrosz,
    Expression<int>? dateEpochDay,
    Expression<String>? recurrence,
    Expression<String>? recurrenceAnchorMonth,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (month != null) 'month': month,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (amountGrosz != null) 'amountGrosz': amountGrosz,
      if (dateEpochDay != null) 'dateEpochDay': dateEpochDay,
      if (recurrence != null) 'recurrence': recurrence,
      if (recurrenceAnchorMonth != null)
        'recurrenceAnchorMonth': recurrenceAnchorMonth,
      if (icon != null) 'icon': icon,
    });
  }

  PlannedItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? month,
    Value<String>? type,
    Value<String>? title,
    Value<int>? amountGrosz,
    Value<int>? dateEpochDay,
    Value<String>? recurrence,
    Value<String>? recurrenceAnchorMonth,
    Value<String>? icon,
  }) {
    return PlannedItemsCompanion(
      id: id ?? this.id,
      month: month ?? this.month,
      type: type ?? this.type,
      title: title ?? this.title,
      amountGrosz: amountGrosz ?? this.amountGrosz,
      dateEpochDay: dateEpochDay ?? this.dateEpochDay,
      recurrence: recurrence ?? this.recurrence,
      recurrenceAnchorMonth:
          recurrenceAnchorMonth ?? this.recurrenceAnchorMonth,
      icon: icon ?? this.icon,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountGrosz.present) {
      map['amountGrosz'] = Variable<int>(amountGrosz.value);
    }
    if (dateEpochDay.present) {
      map['dateEpochDay'] = Variable<int>(dateEpochDay.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (recurrenceAnchorMonth.present) {
      map['recurrenceAnchorMonth'] = Variable<String>(
        recurrenceAnchorMonth.value,
      );
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlannedItemsCompanion(')
          ..write('id: $id, ')
          ..write('month: $month, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('amountGrosz: $amountGrosz, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('recurrence: $recurrence, ')
          ..write('recurrenceAnchorMonth: $recurrenceAnchorMonth, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $CustomCategoriesTable extends CustomCategories
    with TableInfo<$CustomCategoriesTable, CustomCategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomCategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'nameKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('WALLET'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, nameKey, icon];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomCategoryRow> instance, {
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
    if (data.containsKey('nameKey')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['nameKey']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomCategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomCategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nameKey'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
    );
  }

  @override
  $CustomCategoriesTable createAlias(String alias) {
    return $CustomCategoriesTable(attachedDatabase, alias);
  }
}

class CustomCategoryRow extends DataClass
    implements Insertable<CustomCategoryRow> {
  final int id;
  final String name;
  final String nameKey;
  final String icon;
  const CustomCategoryRow({
    required this.id,
    required this.name,
    required this.nameKey,
    required this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['nameKey'] = Variable<String>(nameKey);
    map['icon'] = Variable<String>(icon);
    return map;
  }

  CustomCategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      nameKey: Value(nameKey),
      icon: Value(icon),
    );
  }

  factory CustomCategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomCategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      icon: serializer.fromJson<String>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
      'icon': serializer.toJson<String>(icon),
    };
  }

  CustomCategoryRow copyWith({
    int? id,
    String? name,
    String? nameKey,
    String? icon,
  }) => CustomCategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
    icon: icon ?? this.icon,
  );
  CustomCategoryRow copyWithCompanion(CustomCategoriesCompanion data) {
    return CustomCategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameKey, icon);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomCategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameKey == this.nameKey &&
          other.icon == this.icon);
}

class CustomCategoriesCompanion extends UpdateCompanion<CustomCategoryRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameKey;
  final Value<String> icon;
  const CustomCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.icon = const Value.absent(),
  });
  CustomCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameKey,
    this.icon = const Value.absent(),
  }) : name = Value(name),
       nameKey = Value(nameKey);
  static Insertable<CustomCategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameKey,
    Expression<String>? icon,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameKey != null) 'nameKey': nameKey,
      if (icon != null) 'icon': icon,
    });
  }

  CustomCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? nameKey,
    Value<String>? icon,
  }) {
    return CustomCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
      icon: icon ?? this.icon,
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
    if (nameKey.present) {
      map['nameKey'] = Variable<String>(nameKey.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }
}

class $CustomSubcategoriesTable extends CustomSubcategories
    with TableInfo<$CustomSubcategoriesTable, CustomSubcategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomSubcategoriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'categoryId',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_categories (id)',
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
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'nameKey',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, categoryId, name, nameKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_subcategories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomSubcategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('categoryId')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['categoryId']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nameKey')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['nameKey']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {categoryId, nameKey},
  ];
  @override
  CustomSubcategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomSubcategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoryId'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nameKey'],
      )!,
    );
  }

  @override
  $CustomSubcategoriesTable createAlias(String alias) {
    return $CustomSubcategoriesTable(attachedDatabase, alias);
  }
}

class CustomSubcategoryRow extends DataClass
    implements Insertable<CustomSubcategoryRow> {
  final int id;
  final int categoryId;
  final String name;
  final String nameKey;
  const CustomSubcategoryRow({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['categoryId'] = Variable<int>(categoryId);
    map['name'] = Variable<String>(name);
    map['nameKey'] = Variable<String>(nameKey);
    return map;
  }

  CustomSubcategoriesCompanion toCompanion(bool nullToAbsent) {
    return CustomSubcategoriesCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      nameKey: Value(nameKey),
    );
  }

  factory CustomSubcategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomSubcategoryRow(
      id: serializer.fromJson<int>(json['id']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'categoryId': serializer.toJson<int>(categoryId),
      'name': serializer.toJson<String>(name),
      'nameKey': serializer.toJson<String>(nameKey),
    };
  }

  CustomSubcategoryRow copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? nameKey,
  }) => CustomSubcategoryRow(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    name: name ?? this.name,
    nameKey: nameKey ?? this.nameKey,
  );
  CustomSubcategoryRow copyWithCompanion(CustomSubcategoriesCompanion data) {
    return CustomSubcategoryRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomSubcategoryRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, categoryId, name, nameKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomSubcategoryRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.nameKey == this.nameKey);
}

class CustomSubcategoriesCompanion
    extends UpdateCompanion<CustomSubcategoryRow> {
  final Value<int> id;
  final Value<int> categoryId;
  final Value<String> name;
  final Value<String> nameKey;
  const CustomSubcategoriesCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.nameKey = const Value.absent(),
  });
  CustomSubcategoriesCompanion.insert({
    this.id = const Value.absent(),
    required int categoryId,
    required String name,
    required String nameKey,
  }) : categoryId = Value(categoryId),
       name = Value(name),
       nameKey = Value(nameKey);
  static Insertable<CustomSubcategoryRow> custom({
    Expression<int>? id,
    Expression<int>? categoryId,
    Expression<String>? name,
    Expression<String>? nameKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'categoryId': categoryId,
      if (name != null) 'name': name,
      if (nameKey != null) 'nameKey': nameKey,
    });
  }

  CustomSubcategoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? categoryId,
    Value<String>? name,
    Value<String>? nameKey,
  }) {
    return CustomSubcategoriesCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      nameKey: nameKey ?? this.nameKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (categoryId.present) {
      map['categoryId'] = Variable<int>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameKey.present) {
      map['nameKey'] = Variable<String>(nameKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomSubcategoriesCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('nameKey: $nameKey')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountGroszMeta = const VerificationMeta(
    'amountGrosz',
  );
  @override
  late final GeneratedColumn<int> amountGrosz = GeneratedColumn<int>(
    'amountGrosz',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateEpochDayMeta = const VerificationMeta(
    'dateEpochDay',
  );
  @override
  late final GeneratedColumn<int> dateEpochDay = GeneratedColumn<int>(
    'dateEpochDay',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subcategoryMeta = const VerificationMeta(
    'subcategory',
  );
  @override
  late final GeneratedColumn<String> subcategory = GeneratedColumn<String>(
    'subcategory',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedItemIdMeta = const VerificationMeta(
    'plannedItemId',
  );
  @override
  late final GeneratedColumn<int> plannedItemId = GeneratedColumn<int>(
    'plannedItemId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES planned_items (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _receiptNameMeta = const VerificationMeta(
    'receiptName',
  );
  @override
  late final GeneratedColumn<String> receiptName = GeneratedColumn<String>(
    'receiptName',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customSubcategoryIdMeta =
      const VerificationMeta('customSubcategoryId');
  @override
  late final GeneratedColumn<int> customSubcategoryId = GeneratedColumn<int>(
    'customSubcategoryId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_subcategories (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountGrosz,
    type,
    dateEpochDay,
    note,
    subcategory,
    plannedItemId,
    receiptName,
    customSubcategoryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amountGrosz')) {
      context.handle(
        _amountGroszMeta,
        amountGrosz.isAcceptableOrUnknown(
          data['amountGrosz']!,
          _amountGroszMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountGroszMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('dateEpochDay')) {
      context.handle(
        _dateEpochDayMeta,
        dateEpochDay.isAcceptableOrUnknown(
          data['dateEpochDay']!,
          _dateEpochDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateEpochDayMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('subcategory')) {
      context.handle(
        _subcategoryMeta,
        subcategory.isAcceptableOrUnknown(
          data['subcategory']!,
          _subcategoryMeta,
        ),
      );
    }
    if (data.containsKey('plannedItemId')) {
      context.handle(
        _plannedItemIdMeta,
        plannedItemId.isAcceptableOrUnknown(
          data['plannedItemId']!,
          _plannedItemIdMeta,
        ),
      );
    }
    if (data.containsKey('receiptName')) {
      context.handle(
        _receiptNameMeta,
        receiptName.isAcceptableOrUnknown(
          data['receiptName']!,
          _receiptNameMeta,
        ),
      );
    }
    if (data.containsKey('customSubcategoryId')) {
      context.handle(
        _customSubcategoryIdMeta,
        customSubcategoryId.isAcceptableOrUnknown(
          data['customSubcategoryId']!,
          _customSubcategoryIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountGrosz: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amountGrosz'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      dateEpochDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dateEpochDay'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      subcategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subcategory'],
      ),
      plannedItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plannedItemId'],
      ),
      receiptName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receiptName'],
      ),
      customSubcategoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customSubcategoryId'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class EntryRow extends DataClass implements Insertable<EntryRow> {
  final int id;
  final int amountGrosz;
  final String type;
  final int dateEpochDay;
  final String note;
  final String? subcategory;
  final int? plannedItemId;
  final String? receiptName;
  final int? customSubcategoryId;
  const EntryRow({
    required this.id,
    required this.amountGrosz,
    required this.type,
    required this.dateEpochDay,
    required this.note,
    this.subcategory,
    this.plannedItemId,
    this.receiptName,
    this.customSubcategoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amountGrosz'] = Variable<int>(amountGrosz);
    map['type'] = Variable<String>(type);
    map['dateEpochDay'] = Variable<int>(dateEpochDay);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || subcategory != null) {
      map['subcategory'] = Variable<String>(subcategory);
    }
    if (!nullToAbsent || plannedItemId != null) {
      map['plannedItemId'] = Variable<int>(plannedItemId);
    }
    if (!nullToAbsent || receiptName != null) {
      map['receiptName'] = Variable<String>(receiptName);
    }
    if (!nullToAbsent || customSubcategoryId != null) {
      map['customSubcategoryId'] = Variable<int>(customSubcategoryId);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      amountGrosz: Value(amountGrosz),
      type: Value(type),
      dateEpochDay: Value(dateEpochDay),
      note: Value(note),
      subcategory: subcategory == null && nullToAbsent
          ? const Value.absent()
          : Value(subcategory),
      plannedItemId: plannedItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(plannedItemId),
      receiptName: receiptName == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptName),
      customSubcategoryId: customSubcategoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(customSubcategoryId),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      id: serializer.fromJson<int>(json['id']),
      amountGrosz: serializer.fromJson<int>(json['amountGrosz']),
      type: serializer.fromJson<String>(json['type']),
      dateEpochDay: serializer.fromJson<int>(json['dateEpochDay']),
      note: serializer.fromJson<String>(json['note']),
      subcategory: serializer.fromJson<String?>(json['subcategory']),
      plannedItemId: serializer.fromJson<int?>(json['plannedItemId']),
      receiptName: serializer.fromJson<String?>(json['receiptName']),
      customSubcategoryId: serializer.fromJson<int?>(
        json['customSubcategoryId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountGrosz': serializer.toJson<int>(amountGrosz),
      'type': serializer.toJson<String>(type),
      'dateEpochDay': serializer.toJson<int>(dateEpochDay),
      'note': serializer.toJson<String>(note),
      'subcategory': serializer.toJson<String?>(subcategory),
      'plannedItemId': serializer.toJson<int?>(plannedItemId),
      'receiptName': serializer.toJson<String?>(receiptName),
      'customSubcategoryId': serializer.toJson<int?>(customSubcategoryId),
    };
  }

  EntryRow copyWith({
    int? id,
    int? amountGrosz,
    String? type,
    int? dateEpochDay,
    String? note,
    Value<String?> subcategory = const Value.absent(),
    Value<int?> plannedItemId = const Value.absent(),
    Value<String?> receiptName = const Value.absent(),
    Value<int?> customSubcategoryId = const Value.absent(),
  }) => EntryRow(
    id: id ?? this.id,
    amountGrosz: amountGrosz ?? this.amountGrosz,
    type: type ?? this.type,
    dateEpochDay: dateEpochDay ?? this.dateEpochDay,
    note: note ?? this.note,
    subcategory: subcategory.present ? subcategory.value : this.subcategory,
    plannedItemId: plannedItemId.present
        ? plannedItemId.value
        : this.plannedItemId,
    receiptName: receiptName.present ? receiptName.value : this.receiptName,
    customSubcategoryId: customSubcategoryId.present
        ? customSubcategoryId.value
        : this.customSubcategoryId,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      id: data.id.present ? data.id.value : this.id,
      amountGrosz: data.amountGrosz.present
          ? data.amountGrosz.value
          : this.amountGrosz,
      type: data.type.present ? data.type.value : this.type,
      dateEpochDay: data.dateEpochDay.present
          ? data.dateEpochDay.value
          : this.dateEpochDay,
      note: data.note.present ? data.note.value : this.note,
      subcategory: data.subcategory.present
          ? data.subcategory.value
          : this.subcategory,
      plannedItemId: data.plannedItemId.present
          ? data.plannedItemId.value
          : this.plannedItemId,
      receiptName: data.receiptName.present
          ? data.receiptName.value
          : this.receiptName,
      customSubcategoryId: data.customSubcategoryId.present
          ? data.customSubcategoryId.value
          : this.customSubcategoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('id: $id, ')
          ..write('amountGrosz: $amountGrosz, ')
          ..write('type: $type, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('note: $note, ')
          ..write('subcategory: $subcategory, ')
          ..write('plannedItemId: $plannedItemId, ')
          ..write('receiptName: $receiptName, ')
          ..write('customSubcategoryId: $customSubcategoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountGrosz,
    type,
    dateEpochDay,
    note,
    subcategory,
    plannedItemId,
    receiptName,
    customSubcategoryId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.id == this.id &&
          other.amountGrosz == this.amountGrosz &&
          other.type == this.type &&
          other.dateEpochDay == this.dateEpochDay &&
          other.note == this.note &&
          other.subcategory == this.subcategory &&
          other.plannedItemId == this.plannedItemId &&
          other.receiptName == this.receiptName &&
          other.customSubcategoryId == this.customSubcategoryId);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<int> id;
  final Value<int> amountGrosz;
  final Value<String> type;
  final Value<int> dateEpochDay;
  final Value<String> note;
  final Value<String?> subcategory;
  final Value<int?> plannedItemId;
  final Value<String?> receiptName;
  final Value<int?> customSubcategoryId;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.amountGrosz = const Value.absent(),
    this.type = const Value.absent(),
    this.dateEpochDay = const Value.absent(),
    this.note = const Value.absent(),
    this.subcategory = const Value.absent(),
    this.plannedItemId = const Value.absent(),
    this.receiptName = const Value.absent(),
    this.customSubcategoryId = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required int amountGrosz,
    required String type,
    required int dateEpochDay,
    required String note,
    this.subcategory = const Value.absent(),
    this.plannedItemId = const Value.absent(),
    this.receiptName = const Value.absent(),
    this.customSubcategoryId = const Value.absent(),
  }) : amountGrosz = Value(amountGrosz),
       type = Value(type),
       dateEpochDay = Value(dateEpochDay),
       note = Value(note);
  static Insertable<EntryRow> custom({
    Expression<int>? id,
    Expression<int>? amountGrosz,
    Expression<String>? type,
    Expression<int>? dateEpochDay,
    Expression<String>? note,
    Expression<String>? subcategory,
    Expression<int>? plannedItemId,
    Expression<String>? receiptName,
    Expression<int>? customSubcategoryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountGrosz != null) 'amountGrosz': amountGrosz,
      if (type != null) 'type': type,
      if (dateEpochDay != null) 'dateEpochDay': dateEpochDay,
      if (note != null) 'note': note,
      if (subcategory != null) 'subcategory': subcategory,
      if (plannedItemId != null) 'plannedItemId': plannedItemId,
      if (receiptName != null) 'receiptName': receiptName,
      if (customSubcategoryId != null)
        'customSubcategoryId': customSubcategoryId,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? amountGrosz,
    Value<String>? type,
    Value<int>? dateEpochDay,
    Value<String>? note,
    Value<String?>? subcategory,
    Value<int?>? plannedItemId,
    Value<String?>? receiptName,
    Value<int?>? customSubcategoryId,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      amountGrosz: amountGrosz ?? this.amountGrosz,
      type: type ?? this.type,
      dateEpochDay: dateEpochDay ?? this.dateEpochDay,
      note: note ?? this.note,
      subcategory: subcategory ?? this.subcategory,
      plannedItemId: plannedItemId ?? this.plannedItemId,
      receiptName: receiptName ?? this.receiptName,
      customSubcategoryId: customSubcategoryId ?? this.customSubcategoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountGrosz.present) {
      map['amountGrosz'] = Variable<int>(amountGrosz.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (dateEpochDay.present) {
      map['dateEpochDay'] = Variable<int>(dateEpochDay.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (subcategory.present) {
      map['subcategory'] = Variable<String>(subcategory.value);
    }
    if (plannedItemId.present) {
      map['plannedItemId'] = Variable<int>(plannedItemId.value);
    }
    if (receiptName.present) {
      map['receiptName'] = Variable<String>(receiptName.value);
    }
    if (customSubcategoryId.present) {
      map['customSubcategoryId'] = Variable<int>(customSubcategoryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('amountGrosz: $amountGrosz, ')
          ..write('type: $type, ')
          ..write('dateEpochDay: $dateEpochDay, ')
          ..write('note: $note, ')
          ..write('subcategory: $subcategory, ')
          ..write('plannedItemId: $plannedItemId, ')
          ..write('receiptName: $receiptName, ')
          ..write('customSubcategoryId: $customSubcategoryId')
          ..write(')'))
        .toString();
  }
}

class $MonthlyReflectionsTable extends MonthlyReflections
    with TableInfo<$MonthlyReflectionsTable, MonthlyReflectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlyReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _successesMeta = const VerificationMeta(
    'successes',
  );
  @override
  late final GeneratedColumn<String> successes = GeneratedColumn<String>(
    'successes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _improvementsMeta = const VerificationMeta(
    'improvements',
  );
  @override
  late final GeneratedColumn<String> improvements = GeneratedColumn<String>(
    'improvements',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextMonthMeta = const VerificationMeta(
    'nextMonth',
  );
  @override
  late final GeneratedColumn<String> nextMonth = GeneratedColumn<String>(
    'nextMonth',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    month,
    successes,
    improvements,
    nextMonth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlyReflectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('successes')) {
      context.handle(
        _successesMeta,
        successes.isAcceptableOrUnknown(data['successes']!, _successesMeta),
      );
    } else if (isInserting) {
      context.missing(_successesMeta);
    }
    if (data.containsKey('improvements')) {
      context.handle(
        _improvementsMeta,
        improvements.isAcceptableOrUnknown(
          data['improvements']!,
          _improvementsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_improvementsMeta);
    }
    if (data.containsKey('nextMonth')) {
      context.handle(
        _nextMonthMeta,
        nextMonth.isAcceptableOrUnknown(data['nextMonth']!, _nextMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_nextMonthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {month};
  @override
  MonthlyReflectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlyReflectionRow(
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      successes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}successes'],
      )!,
      improvements: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}improvements'],
      )!,
      nextMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nextMonth'],
      )!,
    );
  }

  @override
  $MonthlyReflectionsTable createAlias(String alias) {
    return $MonthlyReflectionsTable(attachedDatabase, alias);
  }
}

class MonthlyReflectionRow extends DataClass
    implements Insertable<MonthlyReflectionRow> {
  final String month;
  final String successes;
  final String improvements;
  final String nextMonth;
  const MonthlyReflectionRow({
    required this.month,
    required this.successes,
    required this.improvements,
    required this.nextMonth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['month'] = Variable<String>(month);
    map['successes'] = Variable<String>(successes);
    map['improvements'] = Variable<String>(improvements);
    map['nextMonth'] = Variable<String>(nextMonth);
    return map;
  }

  MonthlyReflectionsCompanion toCompanion(bool nullToAbsent) {
    return MonthlyReflectionsCompanion(
      month: Value(month),
      successes: Value(successes),
      improvements: Value(improvements),
      nextMonth: Value(nextMonth),
    );
  }

  factory MonthlyReflectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlyReflectionRow(
      month: serializer.fromJson<String>(json['month']),
      successes: serializer.fromJson<String>(json['successes']),
      improvements: serializer.fromJson<String>(json['improvements']),
      nextMonth: serializer.fromJson<String>(json['nextMonth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'month': serializer.toJson<String>(month),
      'successes': serializer.toJson<String>(successes),
      'improvements': serializer.toJson<String>(improvements),
      'nextMonth': serializer.toJson<String>(nextMonth),
    };
  }

  MonthlyReflectionRow copyWith({
    String? month,
    String? successes,
    String? improvements,
    String? nextMonth,
  }) => MonthlyReflectionRow(
    month: month ?? this.month,
    successes: successes ?? this.successes,
    improvements: improvements ?? this.improvements,
    nextMonth: nextMonth ?? this.nextMonth,
  );
  MonthlyReflectionRow copyWithCompanion(MonthlyReflectionsCompanion data) {
    return MonthlyReflectionRow(
      month: data.month.present ? data.month.value : this.month,
      successes: data.successes.present ? data.successes.value : this.successes,
      improvements: data.improvements.present
          ? data.improvements.value
          : this.improvements,
      nextMonth: data.nextMonth.present ? data.nextMonth.value : this.nextMonth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyReflectionRow(')
          ..write('month: $month, ')
          ..write('successes: $successes, ')
          ..write('improvements: $improvements, ')
          ..write('nextMonth: $nextMonth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(month, successes, improvements, nextMonth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlyReflectionRow &&
          other.month == this.month &&
          other.successes == this.successes &&
          other.improvements == this.improvements &&
          other.nextMonth == this.nextMonth);
}

class MonthlyReflectionsCompanion
    extends UpdateCompanion<MonthlyReflectionRow> {
  final Value<String> month;
  final Value<String> successes;
  final Value<String> improvements;
  final Value<String> nextMonth;
  final Value<int> rowid;
  const MonthlyReflectionsCompanion({
    this.month = const Value.absent(),
    this.successes = const Value.absent(),
    this.improvements = const Value.absent(),
    this.nextMonth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthlyReflectionsCompanion.insert({
    required String month,
    required String successes,
    required String improvements,
    required String nextMonth,
    this.rowid = const Value.absent(),
  }) : month = Value(month),
       successes = Value(successes),
       improvements = Value(improvements),
       nextMonth = Value(nextMonth);
  static Insertable<MonthlyReflectionRow> custom({
    Expression<String>? month,
    Expression<String>? successes,
    Expression<String>? improvements,
    Expression<String>? nextMonth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (month != null) 'month': month,
      if (successes != null) 'successes': successes,
      if (improvements != null) 'improvements': improvements,
      if (nextMonth != null) 'nextMonth': nextMonth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthlyReflectionsCompanion copyWith({
    Value<String>? month,
    Value<String>? successes,
    Value<String>? improvements,
    Value<String>? nextMonth,
    Value<int>? rowid,
  }) {
    return MonthlyReflectionsCompanion(
      month: month ?? this.month,
      successes: successes ?? this.successes,
      improvements: improvements ?? this.improvements,
      nextMonth: nextMonth ?? this.nextMonth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (successes.present) {
      map['successes'] = Variable<String>(successes.value);
    }
    if (improvements.present) {
      map['improvements'] = Variable<String>(improvements.value);
    }
    if (nextMonth.present) {
      map['nextMonth'] = Variable<String>(nextMonth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlyReflectionsCompanion(')
          ..write('month: $month, ')
          ..write('successes: $successes, ')
          ..write('improvements: $improvements, ')
          ..write('nextMonth: $nextMonth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$KakeboDatabase extends GeneratedDatabase {
  _$KakeboDatabase(QueryExecutor e) : super(e);
  $KakeboDatabaseManager get managers => $KakeboDatabaseManager(this);
  late final $MonthlyPlansTable monthlyPlans = $MonthlyPlansTable(this);
  late final $PlannedItemsTable plannedItems = $PlannedItemsTable(this);
  late final $CustomCategoriesTable customCategories = $CustomCategoriesTable(
    this,
  );
  late final $CustomSubcategoriesTable customSubcategories =
      $CustomSubcategoriesTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $MonthlyReflectionsTable monthlyReflections =
      $MonthlyReflectionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    monthlyPlans,
    plannedItems,
    customCategories,
    customSubcategories,
    entries,
    monthlyReflections,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'monthly_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('planned_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'planned_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('entries', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$MonthlyPlansTableCreateCompanionBuilder =
    MonthlyPlansCompanion Function({
      required String month,
      required int savingsGrosz,
      required String resolutions,
      Value<int> rowid,
    });
typedef $$MonthlyPlansTableUpdateCompanionBuilder =
    MonthlyPlansCompanion Function({
      Value<String> month,
      Value<int> savingsGrosz,
      Value<String> resolutions,
      Value<int> rowid,
    });

final class $$MonthlyPlansTableReferences
    extends
        BaseReferences<_$KakeboDatabase, $MonthlyPlansTable, MonthlyPlanRow> {
  $$MonthlyPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlannedItemsTable, List<PlannedItemRow>>
  _plannedItemsRefsTable(_$KakeboDatabase db) => MultiTypedResultKey.fromTable(
    db.plannedItems,
    aliasName: 'monthly_plans__month__planned_items__month',
  );

  $$PlannedItemsTableProcessedTableManager get plannedItemsRefs {
    final manager = $$PlannedItemsTableTableManager(
      $_db,
      $_db.plannedItems,
    ).filter((f) => f.month.month.sqlEquals($_itemColumn<String>('month')!));

    final cache = $_typedResult.readTableOrNull(_plannedItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MonthlyPlansTableFilterComposer
    extends Composer<_$KakeboDatabase, $MonthlyPlansTable> {
  $$MonthlyPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savingsGrosz => $composableBuilder(
    column: $table.savingsGrosz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolutions => $composableBuilder(
    column: $table.resolutions,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> plannedItemsRefs(
    Expression<bool> Function($$PlannedItemsTableFilterComposer f) f,
  ) {
    final $$PlannedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.month,
      referencedTable: $db.plannedItems,
      getReferencedColumn: (t) => t.month,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedItemsTableFilterComposer(
            $db: $db,
            $table: $db.plannedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MonthlyPlansTableOrderingComposer
    extends Composer<_$KakeboDatabase, $MonthlyPlansTable> {
  $$MonthlyPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savingsGrosz => $composableBuilder(
    column: $table.savingsGrosz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolutions => $composableBuilder(
    column: $table.resolutions,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthlyPlansTableAnnotationComposer
    extends Composer<_$KakeboDatabase, $MonthlyPlansTable> {
  $$MonthlyPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get savingsGrosz => $composableBuilder(
    column: $table.savingsGrosz,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resolutions => $composableBuilder(
    column: $table.resolutions,
    builder: (column) => column,
  );

  Expression<T> plannedItemsRefs<T extends Object>(
    Expression<T> Function($$PlannedItemsTableAnnotationComposer a) f,
  ) {
    final $$PlannedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.month,
      referencedTable: $db.plannedItems,
      getReferencedColumn: (t) => t.month,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.plannedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MonthlyPlansTableTableManager
    extends
        RootTableManager<
          _$KakeboDatabase,
          $MonthlyPlansTable,
          MonthlyPlanRow,
          $$MonthlyPlansTableFilterComposer,
          $$MonthlyPlansTableOrderingComposer,
          $$MonthlyPlansTableAnnotationComposer,
          $$MonthlyPlansTableCreateCompanionBuilder,
          $$MonthlyPlansTableUpdateCompanionBuilder,
          (MonthlyPlanRow, $$MonthlyPlansTableReferences),
          MonthlyPlanRow,
          PrefetchHooks Function({bool plannedItemsRefs})
        > {
  $$MonthlyPlansTableTableManager(_$KakeboDatabase db, $MonthlyPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlyPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> month = const Value.absent(),
                Value<int> savingsGrosz = const Value.absent(),
                Value<String> resolutions = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlyPlansCompanion(
                month: month,
                savingsGrosz: savingsGrosz,
                resolutions: resolutions,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String month,
                required int savingsGrosz,
                required String resolutions,
                Value<int> rowid = const Value.absent(),
              }) => MonthlyPlansCompanion.insert(
                month: month,
                savingsGrosz: savingsGrosz,
                resolutions: resolutions,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MonthlyPlansTable, MonthlyPlanRow>(table),
                  $$MonthlyPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({plannedItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (plannedItemsRefs) db.plannedItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (plannedItemsRefs)
                    await $_getPrefetchedData<
                      MonthlyPlanRow,
                      $MonthlyPlansTable,
                      PlannedItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$MonthlyPlansTableReferences
                          ._plannedItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MonthlyPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).plannedItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.month == item.month),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MonthlyPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$KakeboDatabase,
      $MonthlyPlansTable,
      MonthlyPlanRow,
      $$MonthlyPlansTableFilterComposer,
      $$MonthlyPlansTableOrderingComposer,
      $$MonthlyPlansTableAnnotationComposer,
      $$MonthlyPlansTableCreateCompanionBuilder,
      $$MonthlyPlansTableUpdateCompanionBuilder,
      (MonthlyPlanRow, $$MonthlyPlansTableReferences),
      MonthlyPlanRow,
      PrefetchHooks Function({bool plannedItemsRefs})
    >;
typedef $$PlannedItemsTableCreateCompanionBuilder =
    PlannedItemsCompanion Function({
      Value<int> id,
      required String month,
      required String type,
      required String title,
      required int amountGrosz,
      required int dateEpochDay,
      Value<String> recurrence,
      Value<String> recurrenceAnchorMonth,
      Value<String> icon,
    });
typedef $$PlannedItemsTableUpdateCompanionBuilder =
    PlannedItemsCompanion Function({
      Value<int> id,
      Value<String> month,
      Value<String> type,
      Value<String> title,
      Value<int> amountGrosz,
      Value<int> dateEpochDay,
      Value<String> recurrence,
      Value<String> recurrenceAnchorMonth,
      Value<String> icon,
    });

final class $$PlannedItemsTableReferences
    extends
        BaseReferences<_$KakeboDatabase, $PlannedItemsTable, PlannedItemRow> {
  $$PlannedItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MonthlyPlansTable _monthTable(_$KakeboDatabase db) =>
      db.monthlyPlans.createAlias('planned_items__month__monthly_plans__month');

  $$MonthlyPlansTableProcessedTableManager get month {
    final $_column = $_itemColumn<String>('month')!;

    final manager = $$MonthlyPlansTableTableManager(
      $_db,
      $_db.monthlyPlans,
    ).filter((f) => f.month.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_monthTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<EntryRow>> _entriesRefsTable(
    _$KakeboDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'planned_items__id__entries__plannedItemId',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager(
      $_db,
      $_db.entries,
    ).filter((f) => f.plannedItemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlannedItemsTableFilterComposer
    extends Composer<_$KakeboDatabase, $PlannedItemsTable> {
  $$PlannedItemsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountGrosz => $composableBuilder(
    column: $table.amountGrosz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrenceAnchorMonth => $composableBuilder(
    column: $table.recurrenceAnchorMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  $$MonthlyPlansTableFilterComposer get month {
    final $$MonthlyPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.month,
      referencedTable: $db.monthlyPlans,
      getReferencedColumn: (t) => t.month,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlyPlansTableFilterComposer(
            $db: $db,
            $table: $db.monthlyPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.plannedItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlannedItemsTableOrderingComposer
    extends Composer<_$KakeboDatabase, $PlannedItemsTable> {
  $$PlannedItemsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountGrosz => $composableBuilder(
    column: $table.amountGrosz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrenceAnchorMonth => $composableBuilder(
    column: $table.recurrenceAnchorMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  $$MonthlyPlansTableOrderingComposer get month {
    final $$MonthlyPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.month,
      referencedTable: $db.monthlyPlans,
      getReferencedColumn: (t) => t.month,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlyPlansTableOrderingComposer(
            $db: $db,
            $table: $db.monthlyPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlannedItemsTableAnnotationComposer
    extends Composer<_$KakeboDatabase, $PlannedItemsTable> {
  $$PlannedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountGrosz => $composableBuilder(
    column: $table.amountGrosz,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurrenceAnchorMonth => $composableBuilder(
    column: $table.recurrenceAnchorMonth,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  $$MonthlyPlansTableAnnotationComposer get month {
    final $$MonthlyPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.month,
      referencedTable: $db.monthlyPlans,
      getReferencedColumn: (t) => t.month,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MonthlyPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.monthlyPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.plannedItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlannedItemsTableTableManager
    extends
        RootTableManager<
          _$KakeboDatabase,
          $PlannedItemsTable,
          PlannedItemRow,
          $$PlannedItemsTableFilterComposer,
          $$PlannedItemsTableOrderingComposer,
          $$PlannedItemsTableAnnotationComposer,
          $$PlannedItemsTableCreateCompanionBuilder,
          $$PlannedItemsTableUpdateCompanionBuilder,
          (PlannedItemRow, $$PlannedItemsTableReferences),
          PlannedItemRow,
          PrefetchHooks Function({bool month, bool entriesRefs})
        > {
  $$PlannedItemsTableTableManager(_$KakeboDatabase db, $PlannedItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlannedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlannedItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlannedItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> amountGrosz = const Value.absent(),
                Value<int> dateEpochDay = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String> recurrenceAnchorMonth = const Value.absent(),
                Value<String> icon = const Value.absent(),
              }) => PlannedItemsCompanion(
                id: id,
                month: month,
                type: type,
                title: title,
                amountGrosz: amountGrosz,
                dateEpochDay: dateEpochDay,
                recurrence: recurrence,
                recurrenceAnchorMonth: recurrenceAnchorMonth,
                icon: icon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String month,
                required String type,
                required String title,
                required int amountGrosz,
                required int dateEpochDay,
                Value<String> recurrence = const Value.absent(),
                Value<String> recurrenceAnchorMonth = const Value.absent(),
                Value<String> icon = const Value.absent(),
              }) => PlannedItemsCompanion.insert(
                id: id,
                month: month,
                type: type,
                title: title,
                amountGrosz: amountGrosz,
                dateEpochDay: dateEpochDay,
                recurrence: recurrence,
                recurrenceAnchorMonth: recurrenceAnchorMonth,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlannedItemsTable, PlannedItemRow>(table),
                  $$PlannedItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({month = false, entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entriesRefs) db.entries],
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
                    if (month) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.month,
                        referencedTable: $$PlannedItemsTableReferences
                            ._monthTable(db),
                        referencedColumn: $$PlannedItemsTableReferences
                            ._monthTable(db)
                            .month,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<
                      PlannedItemRow,
                      $PlannedItemsTable,
                      EntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$PlannedItemsTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PlannedItemsTableReferences(
                            db,
                            table,
                            p0,
                          ).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.plannedItemId == item.id,
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

typedef $$PlannedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$KakeboDatabase,
      $PlannedItemsTable,
      PlannedItemRow,
      $$PlannedItemsTableFilterComposer,
      $$PlannedItemsTableOrderingComposer,
      $$PlannedItemsTableAnnotationComposer,
      $$PlannedItemsTableCreateCompanionBuilder,
      $$PlannedItemsTableUpdateCompanionBuilder,
      (PlannedItemRow, $$PlannedItemsTableReferences),
      PlannedItemRow,
      PrefetchHooks Function({bool month, bool entriesRefs})
    >;
typedef $$CustomCategoriesTableCreateCompanionBuilder =
    CustomCategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String nameKey,
      Value<String> icon,
    });
typedef $$CustomCategoriesTableUpdateCompanionBuilder =
    CustomCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> nameKey,
      Value<String> icon,
    });

final class $$CustomCategoriesTableReferences
    extends
        BaseReferences<
          _$KakeboDatabase,
          $CustomCategoriesTable,
          CustomCategoryRow
        > {
  $$CustomCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $CustomSubcategoriesTable,
    List<CustomSubcategoryRow>
  >
  _customSubcategoriesRefsTable(_$KakeboDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customSubcategories,
        aliasName: 'custom_categories__id__custom_subcategories__categoryId',
      );

  $$CustomSubcategoriesTableProcessedTableManager get customSubcategoriesRefs {
    final manager = $$CustomSubcategoriesTableTableManager(
      $_db,
      $_db.customSubcategories,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customSubcategoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomCategoriesTableFilterComposer
    extends Composer<_$KakeboDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableFilterComposer({
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

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customSubcategoriesRefs(
    Expression<bool> Function($$CustomSubcategoriesTableFilterComposer f) f,
  ) {
    final $$CustomSubcategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customSubcategories,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomSubcategoriesTableFilterComposer(
            $db: $db,
            $table: $db.customSubcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomCategoriesTableOrderingComposer
    extends Composer<_$KakeboDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomCategoriesTableAnnotationComposer
    extends Composer<_$KakeboDatabase, $CustomCategoriesTable> {
  $$CustomCategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  Expression<T> customSubcategoriesRefs<T extends Object>(
    Expression<T> Function($$CustomSubcategoriesTableAnnotationComposer a) f,
  ) {
    final $$CustomSubcategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customSubcategories,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomSubcategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.customSubcategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CustomCategoriesTableTableManager
    extends
        RootTableManager<
          _$KakeboDatabase,
          $CustomCategoriesTable,
          CustomCategoryRow,
          $$CustomCategoriesTableFilterComposer,
          $$CustomCategoriesTableOrderingComposer,
          $$CustomCategoriesTableAnnotationComposer,
          $$CustomCategoriesTableCreateCompanionBuilder,
          $$CustomCategoriesTableUpdateCompanionBuilder,
          (CustomCategoryRow, $$CustomCategoriesTableReferences),
          CustomCategoryRow,
          PrefetchHooks Function({bool customSubcategoriesRefs})
        > {
  $$CustomCategoriesTableTableManager(
    _$KakeboDatabase db,
    $CustomCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> icon = const Value.absent(),
              }) => CustomCategoriesCompanion(
                id: id,
                name: name,
                nameKey: nameKey,
                icon: icon,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String nameKey,
                Value<String> icon = const Value.absent(),
              }) => CustomCategoriesCompanion.insert(
                id: id,
                name: name,
                nameKey: nameKey,
                icon: icon,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomCategoriesTable, CustomCategoryRow>(table),
                  $$CustomCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customSubcategoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customSubcategoriesRefs) db.customSubcategories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customSubcategoriesRefs)
                    await $_getPrefetchedData<
                      CustomCategoryRow,
                      $CustomCategoriesTable,
                      CustomSubcategoryRow
                    >(
                      currentTable: table,
                      referencedTable: $$CustomCategoriesTableReferences
                          ._customSubcategoriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomCategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).customSubcategoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$KakeboDatabase,
      $CustomCategoriesTable,
      CustomCategoryRow,
      $$CustomCategoriesTableFilterComposer,
      $$CustomCategoriesTableOrderingComposer,
      $$CustomCategoriesTableAnnotationComposer,
      $$CustomCategoriesTableCreateCompanionBuilder,
      $$CustomCategoriesTableUpdateCompanionBuilder,
      (CustomCategoryRow, $$CustomCategoriesTableReferences),
      CustomCategoryRow,
      PrefetchHooks Function({bool customSubcategoriesRefs})
    >;
typedef $$CustomSubcategoriesTableCreateCompanionBuilder =
    CustomSubcategoriesCompanion Function({
      Value<int> id,
      required int categoryId,
      required String name,
      required String nameKey,
    });
typedef $$CustomSubcategoriesTableUpdateCompanionBuilder =
    CustomSubcategoriesCompanion Function({
      Value<int> id,
      Value<int> categoryId,
      Value<String> name,
      Value<String> nameKey,
    });

final class $$CustomSubcategoriesTableReferences
    extends
        BaseReferences<
          _$KakeboDatabase,
          $CustomSubcategoriesTable,
          CustomSubcategoryRow
        > {
  $$CustomSubcategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CustomCategoriesTable _categoryIdTable(_$KakeboDatabase db) => db
      .customCategories
      .createAlias('custom_subcategories__categoryId__custom_categories__id');

  $$CustomCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('categoryId')!;

    final manager = $$CustomCategoriesTableTableManager(
      $_db,
      $_db.customCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EntriesTable, List<EntryRow>> _entriesRefsTable(
    _$KakeboDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.entries,
    aliasName: 'custom_subcategories__id__entries__customSubcategoryId',
  );

  $$EntriesTableProcessedTableManager get entriesRefs {
    final manager = $$EntriesTableTableManager($_db, $_db.entries).filter(
      (f) => f.customSubcategoryId.id.sqlEquals($_itemColumn<int>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_entriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomSubcategoriesTableFilterComposer
    extends Composer<_$KakeboDatabase, $CustomSubcategoriesTable> {
  $$CustomSubcategoriesTableFilterComposer({
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

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomCategoriesTableFilterComposer get categoryId {
    final $$CustomCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.customCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.customCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> entriesRefs(
    Expression<bool> Function($$EntriesTableFilterComposer f) f,
  ) {
    final $$EntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.customSubcategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableFilterComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomSubcategoriesTableOrderingComposer
    extends Composer<_$KakeboDatabase, $CustomSubcategoriesTable> {
  $$CustomSubcategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomCategoriesTableOrderingComposer get categoryId {
    final $$CustomCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.customCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.customCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomSubcategoriesTableAnnotationComposer
    extends Composer<_$KakeboDatabase, $CustomSubcategoriesTable> {
  $$CustomSubcategoriesTableAnnotationComposer({
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

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  $$CustomCategoriesTableAnnotationComposer get categoryId {
    final $$CustomCategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.customCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomCategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.customCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> entriesRefs<T extends Object>(
    Expression<T> Function($$EntriesTableAnnotationComposer a) f,
  ) {
    final $$EntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.entries,
      getReferencedColumn: (t) => t.customSubcategoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.entries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomSubcategoriesTableTableManager
    extends
        RootTableManager<
          _$KakeboDatabase,
          $CustomSubcategoriesTable,
          CustomSubcategoryRow,
          $$CustomSubcategoriesTableFilterComposer,
          $$CustomSubcategoriesTableOrderingComposer,
          $$CustomSubcategoriesTableAnnotationComposer,
          $$CustomSubcategoriesTableCreateCompanionBuilder,
          $$CustomSubcategoriesTableUpdateCompanionBuilder,
          (CustomSubcategoryRow, $$CustomSubcategoriesTableReferences),
          CustomSubcategoryRow,
          PrefetchHooks Function({bool categoryId, bool entriesRefs})
        > {
  $$CustomSubcategoriesTableTableManager(
    _$KakeboDatabase db,
    $CustomSubcategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomSubcategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomSubcategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomSubcategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
              }) => CustomSubcategoriesCompanion(
                id: id,
                categoryId: categoryId,
                name: name,
                nameKey: nameKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int categoryId,
                required String name,
                required String nameKey,
              }) => CustomSubcategoriesCompanion.insert(
                id: id,
                categoryId: categoryId,
                name: name,
                nameKey: nameKey,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomSubcategoriesTable, CustomSubcategoryRow>(
                    table,
                  ),
                  $$CustomSubcategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, entriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (entriesRefs) db.entries],
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
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$CustomSubcategoriesTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$CustomSubcategoriesTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (entriesRefs)
                    await $_getPrefetchedData<
                      CustomSubcategoryRow,
                      $CustomSubcategoriesTable,
                      EntryRow
                    >(
                      currentTable: table,
                      referencedTable: $$CustomSubcategoriesTableReferences
                          ._entriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomSubcategoriesTableReferences(
                            db,
                            table,
                            p0,
                          ).entriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.customSubcategoryId == item.id,
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

typedef $$CustomSubcategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$KakeboDatabase,
      $CustomSubcategoriesTable,
      CustomSubcategoryRow,
      $$CustomSubcategoriesTableFilterComposer,
      $$CustomSubcategoriesTableOrderingComposer,
      $$CustomSubcategoriesTableAnnotationComposer,
      $$CustomSubcategoriesTableCreateCompanionBuilder,
      $$CustomSubcategoriesTableUpdateCompanionBuilder,
      (CustomSubcategoryRow, $$CustomSubcategoriesTableReferences),
      CustomSubcategoryRow,
      PrefetchHooks Function({bool categoryId, bool entriesRefs})
    >;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  Value<int> id,
  required int amountGrosz,
  required String type,
  required int dateEpochDay,
  required String note,
  Value<String?> subcategory,
  Value<int?> plannedItemId,
  Value<String?> receiptName,
  Value<int?> customSubcategoryId,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<int> id,
  Value<int> amountGrosz,
  Value<String> type,
  Value<int> dateEpochDay,
  Value<String> note,
  Value<String?> subcategory,
  Value<int?> plannedItemId,
  Value<String?> receiptName,
  Value<int?> customSubcategoryId,
});

final class $$EntriesTableReferences
    extends BaseReferences<_$KakeboDatabase, $EntriesTable, EntryRow> {
  $$EntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlannedItemsTable _plannedItemIdTable(_$KakeboDatabase db) =>
      db.plannedItems.createAlias('entries__plannedItemId__planned_items__id');

  $$PlannedItemsTableProcessedTableManager? get plannedItemId {
    final $_column = $_itemColumn<int>('plannedItemId');
    if ($_column == null) return null;
    final manager = $$PlannedItemsTableTableManager(
      $_db,
      $_db.plannedItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_plannedItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomSubcategoriesTable _customSubcategoryIdTable(
    _$KakeboDatabase db,
  ) => db.customSubcategories.createAlias(
    'entries__customSubcategoryId__custom_subcategories__id',
  );

  $$CustomSubcategoriesTableProcessedTableManager? get customSubcategoryId {
    final $_column = $_itemColumn<int>('customSubcategoryId');
    if ($_column == null) return null;
    final manager = $$CustomSubcategoriesTableTableManager(
      $_db,
      $_db.customSubcategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customSubcategoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EntriesTableFilterComposer
    extends Composer<_$KakeboDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
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

  ColumnFilters<int> get amountGrosz => $composableBuilder(
    column: $table.amountGrosz,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptName => $composableBuilder(
    column: $table.receiptName,
    builder: (column) => ColumnFilters(column),
  );

  $$PlannedItemsTableFilterComposer get plannedItemId {
    final $$PlannedItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plannedItemId,
      referencedTable: $db.plannedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedItemsTableFilterComposer(
            $db: $db,
            $table: $db.plannedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomSubcategoriesTableFilterComposer get customSubcategoryId {
    final $$CustomSubcategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customSubcategoryId,
      referencedTable: $db.customSubcategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomSubcategoriesTableFilterComposer(
            $db: $db,
            $table: $db.customSubcategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EntriesTableOrderingComposer
    extends Composer<_$KakeboDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
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

  ColumnOrderings<int> get amountGrosz => $composableBuilder(
    column: $table.amountGrosz,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptName => $composableBuilder(
    column: $table.receiptName,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlannedItemsTableOrderingComposer get plannedItemId {
    final $$PlannedItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plannedItemId,
      referencedTable: $db.plannedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedItemsTableOrderingComposer(
            $db: $db,
            $table: $db.plannedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomSubcategoriesTableOrderingComposer get customSubcategoryId {
    final $$CustomSubcategoriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.customSubcategoryId,
          referencedTable: $db.customSubcategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomSubcategoriesTableOrderingComposer(
                $db: $db,
                $table: $db.customSubcategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$KakeboDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountGrosz => $composableBuilder(
    column: $table.amountGrosz,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get dateEpochDay => $composableBuilder(
    column: $table.dateEpochDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get subcategory => $composableBuilder(
    column: $table.subcategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptName => $composableBuilder(
    column: $table.receiptName,
    builder: (column) => column,
  );

  $$PlannedItemsTableAnnotationComposer get plannedItemId {
    final $$PlannedItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.plannedItemId,
      referencedTable: $db.plannedItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlannedItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.plannedItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomSubcategoriesTableAnnotationComposer get customSubcategoryId {
    final $$CustomSubcategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.customSubcategoryId,
          referencedTable: $db.customSubcategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomSubcategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.customSubcategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$KakeboDatabase,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, $$EntriesTableReferences),
          EntryRow,
          PrefetchHooks Function({bool plannedItemId, bool customSubcategoryId})
        > {
  $$EntriesTableTableManager(_$KakeboDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountGrosz = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int> dateEpochDay = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> subcategory = const Value.absent(),
                Value<int?> plannedItemId = const Value.absent(),
                Value<String?> receiptName = const Value.absent(),
                Value<int?> customSubcategoryId = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                amountGrosz: amountGrosz,
                type: type,
                dateEpochDay: dateEpochDay,
                note: note,
                subcategory: subcategory,
                plannedItemId: plannedItemId,
                receiptName: receiptName,
                customSubcategoryId: customSubcategoryId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountGrosz,
                required String type,
                required int dateEpochDay,
                required String note,
                Value<String?> subcategory = const Value.absent(),
                Value<int?> plannedItemId = const Value.absent(),
                Value<String?> receiptName = const Value.absent(),
                Value<int?> customSubcategoryId = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                amountGrosz: amountGrosz,
                type: type,
                dateEpochDay: dateEpochDay,
                note: note,
                subcategory: subcategory,
                plannedItemId: plannedItemId,
                receiptName: receiptName,
                customSubcategoryId: customSubcategoryId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, EntryRow>(table),
                  $$EntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({plannedItemId = false, customSubcategoryId = false}) {
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
                        if (plannedItemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.plannedItemId,
                            referencedTable: $$EntriesTableReferences
                                ._plannedItemIdTable(db),
                            referencedColumn: $$EntriesTableReferences
                                ._plannedItemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (customSubcategoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.customSubcategoryId,
                            referencedTable: $$EntriesTableReferences
                                ._customSubcategoryIdTable(db),
                            referencedColumn: $$EntriesTableReferences
                                ._customSubcategoryIdTable(db)
                                .id,
                          ) as T;
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

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$KakeboDatabase,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, $$EntriesTableReferences),
      EntryRow,
      PrefetchHooks Function({bool plannedItemId, bool customSubcategoryId})
    >;
typedef $$MonthlyReflectionsTableCreateCompanionBuilder =
    MonthlyReflectionsCompanion Function({
      required String month,
      required String successes,
      required String improvements,
      required String nextMonth,
      Value<int> rowid,
    });
typedef $$MonthlyReflectionsTableUpdateCompanionBuilder =
    MonthlyReflectionsCompanion Function({
      Value<String> month,
      Value<String> successes,
      Value<String> improvements,
      Value<String> nextMonth,
      Value<int> rowid,
    });

class $$MonthlyReflectionsTableFilterComposer
    extends Composer<_$KakeboDatabase, $MonthlyReflectionsTable> {
  $$MonthlyReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get successes => $composableBuilder(
    column: $table.successes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get improvements => $composableBuilder(
    column: $table.improvements,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextMonth => $composableBuilder(
    column: $table.nextMonth,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthlyReflectionsTableOrderingComposer
    extends Composer<_$KakeboDatabase, $MonthlyReflectionsTable> {
  $$MonthlyReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get successes => $composableBuilder(
    column: $table.successes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get improvements => $composableBuilder(
    column: $table.improvements,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextMonth => $composableBuilder(
    column: $table.nextMonth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthlyReflectionsTableAnnotationComposer
    extends Composer<_$KakeboDatabase, $MonthlyReflectionsTable> {
  $$MonthlyReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get successes =>
      $composableBuilder(column: $table.successes, builder: (column) => column);

  GeneratedColumn<String> get improvements => $composableBuilder(
    column: $table.improvements,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nextMonth =>
      $composableBuilder(column: $table.nextMonth, builder: (column) => column);
}

class $$MonthlyReflectionsTableTableManager
    extends
        RootTableManager<
          _$KakeboDatabase,
          $MonthlyReflectionsTable,
          MonthlyReflectionRow,
          $$MonthlyReflectionsTableFilterComposer,
          $$MonthlyReflectionsTableOrderingComposer,
          $$MonthlyReflectionsTableAnnotationComposer,
          $$MonthlyReflectionsTableCreateCompanionBuilder,
          $$MonthlyReflectionsTableUpdateCompanionBuilder,
          (
            MonthlyReflectionRow,
            BaseReferences<
              _$KakeboDatabase,
              $MonthlyReflectionsTable,
              MonthlyReflectionRow
            >,
          ),
          MonthlyReflectionRow,
          PrefetchHooks Function()
        > {
  $$MonthlyReflectionsTableTableManager(
    _$KakeboDatabase db,
    $MonthlyReflectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlyReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlyReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlyReflectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> month = const Value.absent(),
                Value<String> successes = const Value.absent(),
                Value<String> improvements = const Value.absent(),
                Value<String> nextMonth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonthlyReflectionsCompanion(
                month: month,
                successes: successes,
                improvements: improvements,
                nextMonth: nextMonth,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String month,
                required String successes,
                required String improvements,
                required String nextMonth,
                Value<int> rowid = const Value.absent(),
              }) => MonthlyReflectionsCompanion.insert(
                month: month,
                successes: successes,
                improvements: improvements,
                nextMonth: nextMonth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MonthlyReflectionsTable, MonthlyReflectionRow>(
                    table,
                  ),
                  BaseReferences<
                    _$KakeboDatabase,
                    $MonthlyReflectionsTable,
                    MonthlyReflectionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthlyReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$KakeboDatabase,
      $MonthlyReflectionsTable,
      MonthlyReflectionRow,
      $$MonthlyReflectionsTableFilterComposer,
      $$MonthlyReflectionsTableOrderingComposer,
      $$MonthlyReflectionsTableAnnotationComposer,
      $$MonthlyReflectionsTableCreateCompanionBuilder,
      $$MonthlyReflectionsTableUpdateCompanionBuilder,
      (
        MonthlyReflectionRow,
        BaseReferences<
          _$KakeboDatabase,
          $MonthlyReflectionsTable,
          MonthlyReflectionRow
        >,
      ),
      MonthlyReflectionRow,
      PrefetchHooks Function()
    >;

class $KakeboDatabaseManager {
  final _$KakeboDatabase _db;
  $KakeboDatabaseManager(this._db);
  $$MonthlyPlansTableTableManager get monthlyPlans =>
      $$MonthlyPlansTableTableManager(_db, _db.monthlyPlans);
  $$PlannedItemsTableTableManager get plannedItems =>
      $$PlannedItemsTableTableManager(_db, _db.plannedItems);
  $$CustomCategoriesTableTableManager get customCategories =>
      $$CustomCategoriesTableTableManager(_db, _db.customCategories);
  $$CustomSubcategoriesTableTableManager get customSubcategories =>
      $$CustomSubcategoriesTableTableManager(_db, _db.customSubcategories);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$MonthlyReflectionsTableTableManager get monthlyReflections =>
      $$MonthlyReflectionsTableTableManager(_db, _db.monthlyReflections);
}
