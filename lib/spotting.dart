import 'package:platespot/platespotdb.dart';

class Spotting {
  DateTime spottingTime;
  int spotNumber;

  Spotting({required this.spotNumber, required this.spottingTime});

  Future<void> storeInDb() async {
    final database = PlateSpotDB();
    await database.open();
    await database.store(this);
  }

  static Future<List<Spotting>> getAllSpottingsFromDB() async {
    final database = PlateSpotDB();
    await database.open();
    final spottingList = await database.getAllSpottings();
    return spottingList;
  }

  Spotting copy() {
    final newSpot =
        Spotting(spotNumber: spotNumber, spottingTime: spottingTime);
    return newSpot;
  }

  //to be used when converting the row into object
  factory Spotting.fromMap(Map<String, dynamic> data) => new Spotting(
        spotNumber: data["spotNr"],
        spottingTime: DateTime.parse(data["timestamp"]),
      );
}
