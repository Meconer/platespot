import 'package:flutter/material.dart';
import 'package:platespot/constants.dart';
import 'package:platespot/statistics.dart';
import 'spotting.dart';

class StatPage extends StatelessWidget {
  const StatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistik'),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: Colors.lightBlue[200],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<Spotting>>(
                future: Spotting.getAllSpottingsFromDB(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return getStatWidget(snapshot.data!);
                  }
                  return Center(child: CircularProgressIndicator());
                }),
          ),
        ),
      ),
    );
  }

  Widget getStatWidget(List<Spotting> spotList) {
    final firstSpot = getFirstSpot(spotList);
    final latestSpot = getLastSpot(spotList);
    final secondToLastSpot = getSpot(latestSpot.spotNumber - 1, spotList);
    final statistics = Statistics(
        firstSpot: firstSpot,
        latestSpot: latestSpot,
        secondLastSpot: secondToLastSpot);

    return Column(
      children: [
        NumberText(
          title: 'Första registrerade spot',
          text: statistics.getFirstSpotText(),
        ),
        NumberText(
          title: 'Senaste registrerade spot',
          text: statistics.getLatestSpotText(),
        ),
        NumberText(
          title: 'Tid mellan första och senaste spot',
          text: statistics.getIntervalText(),
        ),
        NumberText(
          title: 'Genomsnittlig tid mellan spots',
          text: statistics.getTextForAverageTimeBetweenSpottings(),
        ),
        NumberText(
          title: 'Tid mellan två senaste spots',
          text: statistics.getTextForTimeBetweenLastTwoSpottings(),
        ),
        NumberText(
          title: 'Återstående tid',
          text: statistics.getTextForRemainingDays(),
        ),
        NumberText(
          title: 'Färdigdatum',
          text: statistics.getTextForFinishedDate(),
        )
      ],
    );
  }

  Spotting getFirstSpot(List<Spotting> spotList) {
    Spotting firstSpotting = emptySpotting;
    var lowestSpotNr = 9999;
    for (final spot in spotList) {
      if (spot.spotNumber < lowestSpotNr) {
        lowestSpotNr = spot.spotNumber;
        firstSpotting = spot.copy();
      }
    }
    return firstSpotting;
  }

  Spotting getLastSpot(List<Spotting> spotList) {
    var lastSpotting = emptySpotting;
    for (final spot in spotList) {
      if (spot.spotNumber > lastSpotting.spotNumber) {
        lastSpotting = spot.copy();
      }
    }
    return lastSpotting;
  }

  Spotting getSpot(int spotNumber, List<Spotting> spotList) {
    for (final spot in spotList) {
      if (spot.spotNumber == spotNumber) {
        return spot.copy();
      }
    }
    return emptySpotting;
  }
}

class NumberText extends StatelessWidget {
  const NumberText({
    Key? key,
    required this.title,
    required this.text,
  }) : super(key: key);

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(children: [
        Text(title),
        Text(
          text,
          style: TextStyle(fontSize: 24),
        ),
      ]),
    );
  }
}
