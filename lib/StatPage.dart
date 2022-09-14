import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    final lastSpot = getLastSpot(spotList);
    final interval = lastSpot.spottingTime.difference(firstSpot.spottingTime);
    final intervalInDays = interval.inDays;
    final intervalInHours = (interval - Duration(days: intervalInDays)).inHours;

    final timeBetweenSpots =
        calcAverageTimeBetweenSpotsInHours(firstSpot, lastSpot) / 24;
    String avgStr = timeBetweenSpots.toString();
    int decPos = avgStr.indexOf('.');
    if (decPos >= 0) {
      int l = avgStr.length;
      avgStr = avgStr.substring(0, min(decPos + 3, l));
    }

    final remainingTime = calcRemainingTimeInDays(firstSpot, lastSpot).round();

    return Column(
      children: [
        StatText(firstSpot, 'Första registrerade spot'),
        StatText(lastSpot, 'Senaste registrerade spot'),
        NumberText(
          title: 'Tid mellan första och senaste spot',
          text: '$intervalInDays dagar och $intervalInHours timmar',
        ),
        NumberText(
            title: 'Genomsnittlig tid mellan spots', text: '$avgStr dagar'),
        NumberText(title: 'Återstående tid', text: '$remainingTime dagar'),
        NumberText(
            title: 'Färdigdatum',
            text: '${formattedDate(finishTime(remainingTime))}')
      ],
    );
  }

  Spotting getFirstSpot(List<Spotting> spotList) {
    var firstSpotting =
        Spotting(spotNumber: 9999, spottingTime: DateTime.now());
    for (final spot in spotList) {
      if (spot.spotNumber < firstSpotting.spotNumber) {
        firstSpotting = spot.copy();
      }
    }
    return firstSpotting;
  }

  Spotting getLastSpot(List<Spotting> spotList) {
    var lastSpotting = Spotting(spotNumber: 0, spottingTime: DateTime(0));
    for (final spot in spotList) {
      if (spot.spotNumber > lastSpotting.spotNumber) {
        lastSpotting = spot.copy();
      }
    }
    return lastSpotting;
  }

  double calcRemainingTimeInDays(Spotting firstSpot, Spotting lastSpot) {
    final avgTimeBetweenSpots =
        calcAverageTimeBetweenSpotsInHours(firstSpot, lastSpot);
    lastSpot.spottingTime.difference(firstSpot.spottingTime);
    final noInterval = lastSpot.spotNumber - firstSpot.spotNumber;
    if (noInterval > 0) {
      final remainingTimeInHours =
          (999 - lastSpot.spotNumber) * avgTimeBetweenSpots;
      return (remainingTimeInHours / 24).roundToDouble();
    }
    return 0;
  }

  double calcAverageTimeBetweenSpotsInHours(
      Spotting firstSpot, Spotting lastSpot) {
    final timeInterval =
        lastSpot.spottingTime.difference(firstSpot.spottingTime);
    final noInterval = lastSpot.spotNumber - firstSpot.spotNumber;
    if (noInterval <= 0) return 0;
    final averageTimeBetweenSpots = timeInterval.inHours / noInterval;
    return averageTimeBetweenSpots;
  }
}

DateTime finishTime(int remainingDays) {
  return DateTime.now().add(Duration(days: remainingDays));
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

String formattedDateTime(DateTime dateTime) {
  final formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(dateTime);
}

String formattedDate(DateTime dateTime) {
  final formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(dateTime);
}

class StatText extends StatelessWidget {
  final Spotting spotting;
  final String title;
  StatText(this.spotting, this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Text(title),
          Text(
            spotting.spotNumber.toString(),
            style: TextStyle(fontSize: 24),
          ),
          Text(
            formattedDateTime(spotting.spottingTime),
            style: TextStyle(fontSize: 18),
          )
        ],
      ),
    );
  }
}
