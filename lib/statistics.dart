import 'dart:math';

import 'package:intl/intl.dart';
import 'package:platespot/spotting.dart';

class Statistics {
  Spotting firstSpot;
  Spotting latestSpot;

  Statistics({
    required this.firstSpot,
    required this.latestSpot,
  });

  String getFirstSpotText() {
    if (!firstSpot.isRegistered()) {
      return '-';
    }
    return formattedDateTime(firstSpot.spottingTime);
  }

  String getLatestSpotText() {
    if (!latestSpot.isRegistered()) {
      return '-';
    }
    return formattedDateTime(latestSpot.spottingTime);
  }

  String getIntervalText() {
    if (!firstSpot.isRegistered()) return '-';
    if (!latestSpot.isRegistered()) return '-';
    if (firstSpot.spotNumber == latestSpot.spotNumber) return '-';
    final interval = latestSpot.spottingTime.difference(firstSpot.spottingTime);
    final intervalInDays = interval.inDays;
    final intervalInHours = (interval - Duration(days: intervalInDays)).inHours;
    return '$intervalInDays dagar och $intervalInHours timmar';
  }

  String getTextForAverageTimeBetweenSpottings() {
    if (!firstSpot.isRegistered()) return '-';
    if (!latestSpot.isRegistered()) return '-';
    if (firstSpot.spotNumber == latestSpot.spotNumber) return '-';
    final hoursBetweenSpottings =
        calcAverageTimeBetweenSpotsInHours(firstSpot, latestSpot);
    final daysBetweenSpottingsText = hoursBetweenSpottings / 24;
    String avgStr = daysBetweenSpottingsText.toString();
    int decPos = avgStr.indexOf('.');
    if (decPos >= 0) {
      int l = avgStr.length;
      avgStr = avgStr.substring(0, min(decPos + 3, l));
    }
    return '$avgStr dagar';
  }

  String getTextForRemainingDays() {
    if (!firstSpot.isRegistered()) return '-';
    if (!latestSpot.isRegistered()) return '-';
    if (firstSpot.spotNumber == latestSpot.spotNumber) return '-';
    final remainingHours = calcRemainingTimeInHours(firstSpot, latestSpot);
    final remainingDays = remainingHours / 24.round();
    return '$remainingDays dagar';
  }

  String getTextForFinishedDate() {
    if (!firstSpot.isRegistered()) return '-';
    if (!latestSpot.isRegistered()) return '-';
    if (firstSpot.spotNumber == latestSpot.spotNumber) return '-';
    final remainingHours = calcRemainingTimeInHours(firstSpot, latestSpot);
    final finishDate = finishTime(remainingHours);
    return formattedDate(finishDate);
  }

  int calcRemainingTimeInHours(Spotting firstSpot, Spotting lastSpot) {
    final avgTimeBetweenSpots =
        calcAverageTimeBetweenSpotsInHours(firstSpot, lastSpot);
    lastSpot.spottingTime.difference(firstSpot.spottingTime);
    final noInterval = lastSpot.spotNumber - firstSpot.spotNumber;
    if (noInterval > 0) {
      final remainingTimeInHours =
          (999 - lastSpot.spotNumber) * avgTimeBetweenSpots;
      return remainingTimeInHours.round();
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

  String formattedDateTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(dateTime);
  }

  String formattedDate(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(dateTime);
  }

  DateTime finishTime(int remainingHours) {
    return DateTime.now().add(Duration(hours: remainingHours));
  }
}
