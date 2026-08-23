import 'package:path/path.dart';
import 'package:platespot/spotting.dart';
import 'package:sqflite/sqflite.dart';

class PlateSpotDB {
  static const dbName = 'spottings';

  Database? database;

  Future<void> open() async {
    final dbPath = await getDatabasesPath();
    final dbFullName = join(dbPath, dbName);
    database = await openDatabase(dbFullName, onCreate: (db, version) {
      return db.execute(
        '''
        CREATE TABLE $dbName
        (spotNr INTEGER PRIMARY KEY, timestamp TEXT);
        ''',
      );
    }, version: 1);
  }

  Future<void> store(Spotting spotting) async {
    String spotTimeStr = spotting.spottingTime.toIso8601String();
    final values = {
      'spotNr': spotting.spotNumber,
      'timestamp': spotTimeStr,
    };

    if (database != null) {
      final id = await database!.insert(dbName, values);
      print('Inserted $id');
    }
  }

  Future<List<Spotting>> getAllSpottings() async {
    if (database != null) {
      final result = await database!.query(dbName);
      List<Spotting> resultList = [];
      for (final row in result) {
        final spotting = Spotting.fromMap(row);
        resultList.add(spotting);
      }
      return resultList;
    }
    return [];
  }
}
