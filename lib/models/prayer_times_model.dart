class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String sunset; // الغروب
  final String maghrib; // المغرب (الغروب + 17 دقيقة في المذهب الجعفري)
  final String midnight;
  final String date;
  final String location;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.sunset,
    required this.maghrib,
    required this.midnight,
    required this.date,
    required this.location,
  });
}
