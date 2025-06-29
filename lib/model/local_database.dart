import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'space_model.dart';
import 'space_units_model.dart' as su;

class LocalDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'app.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE spaces(
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE units(
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE random_spaces(
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE random_units(
            id INTEGER PRIMARY KEY,
            data TEXT
          )
        ''');
      },
      version: 2,
    );
    return _db!;
  }

  static Future<void> saveSpaces(List<Space> spaces) async {
    final db = await database;
    await db.delete('spaces');
    for (var space in spaces) {
      await db.insert(
        'spaces',
        {
          'id': space.id,
          'data': jsonEncode(space.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Space>> getSpaces() async {
    final db = await database;
    final maps = await db.query('spaces');
    return maps.map((e) => Space.fromJson(jsonDecode(e['data'] as String))).toList();
  }

  static Future<void> saveRandomSpaces(List<Space> randomSpaces) async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS random_spaces(id INTEGER PRIMARY KEY, data TEXT)');
    await db.delete('random_spaces');
    for (var space in randomSpaces) {
      await db.insert(
        'random_spaces',
        {
          'id': space.id,
          'data': jsonEncode(space.toJson()),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<Space>> getRandomSpaces() async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS random_spaces(id INTEGER PRIMARY KEY, data TEXT)');
    final maps = await db.query('random_spaces');
    return maps.map((e) => Space.fromJson(jsonDecode(e['data'] as String))).toList();
  }

  static Future<void> saveUnits(List<su.SpaceUnit> units) async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS units(id INTEGER PRIMARY KEY, data TEXT)');
    await db.delete('units');
    for (var unit in units) {
      await db.insert(
        'units',
        {
          'id': unit.id,
          'data': jsonEncode({
            'id': unit.id,
            'name': unit.name,
            'description': unit.description,
            'imageUrl': unit.imageUrl,
            'spaceId': unit.spaceId,
            'unitCategoryId': unit.unitCategoryId,
            'unitCategoryName': unit.unitCategoryName,
            'bookingOptions': unit.bookingOptions.map((e) => {
              'id': e.id,
              'duration': e.duration,
              'price': e.price,
              'currency': e.currency,
              'spaceUnitId': e.spaceUnitId,
            }).toList(),
          }),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<su.SpaceUnit>> getUnits() async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS units(id INTEGER PRIMARY KEY, data TEXT)');
    final maps = await db.query('units');
    return maps.map((e) => su.SpaceUnit.fromJson(jsonDecode(e['data'] as String))).toList();
  }

  static Future<void> saveRandomUnits(List<su.SpaceUnit> randomUnits) async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS random_units(id INTEGER PRIMARY KEY, data TEXT)');
    await db.delete('random_units');
    for (var unit in randomUnits) {
      await db.insert(
        'random_units',
        {
          'id': unit.id,
          'data': jsonEncode({
            'id': unit.id,
            'name': unit.name,
            'description': unit.description,
            'imageUrl': unit.imageUrl,
            'spaceId': unit.spaceId,
            'unitCategoryId': unit.unitCategoryId,
            'unitCategoryName': unit.unitCategoryName,
            'bookingOptions': unit.bookingOptions.map((e) => {
              'id': e.id,
              'duration': e.duration,
              'price': e.price,
              'currency': e.currency,
              'spaceUnitId': e.spaceUnitId,
            }).toList(),
          }),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  static Future<List<su.SpaceUnit>> getRandomUnits() async {
    final db = await database;
    await db.execute('CREATE TABLE IF NOT EXISTS random_units(id INTEGER PRIMARY KEY, data TEXT)');
    final maps = await db.query('random_units');
    return maps.map((e) => su.SpaceUnit.fromJson(jsonDecode(e['data'] as String))).toList();
  }
} 