import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  static const String _osrmBaseUrl =
      'https://router.project-osrm.org/route/v1/walking';

  static Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final url =
          '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'ShiaBookApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates =
              data['routes'][0]['geometry']['coordinates'] as List;

          return coordinates.map<LatLng>((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      }

      // في حالة فشل الحصول على الطريق، إرجاع خط مستقيم
      return _getStraightLineRoute(start, end);
    } catch (e) {
      print('خطأ في الحصول على الطريق: $e');
      return _getStraightLineRoute(start, end);
    }
  }

  static Future<Map<String, double>> getRouteInfo(
      LatLng start, LatLng end) async {
    try {
      final url =
          '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'ShiaBookApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final distance =
              (route['distance'] as num).toDouble() / 1000; // تحويل إلى كيلومتر
          final duration =
              (route['duration'] as num).toDouble() / 3600; // تحويل إلى ساعة

          return {
            'distance': distance,
            'duration': duration,
          };
        }
      }

      // في حالة فشل الحصول على معلومات الطريق، حساب المسافة المستقيمة
      return _getStraightLineInfo(start, end);
    } catch (e) {
      print('خطأ في الحصول على معلومات الطريق: $e');

      return _getStraightLineInfo(start, end);
    }
  }

  static List<LatLng> _getStraightLineRoute(LatLng start, LatLng end) {
    // إنشاء طريق مستقيم مع نقاط وسطية
    final List<LatLng> route = [];
    const int segments = 10;

    for (int i = 0; i <= segments; i++) {
      final ratio = i / segments;
      final lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final lng = start.longitude + (end.longitude - start.longitude) * ratio;
      route.add(LatLng(lat, lng));
    }

    return route;
  }

  static Map<String, double> _getStraightLineInfo(LatLng start, LatLng end) {
    // حساب المسافة المستقيمة باستخدام صيغة Haversine
    const double earthRadius = 6371; // نصف قطر الأرض بالكيلومتر

    final double lat1Rad = start.latitude * (3.14159265359 / 180);
    final double lat2Rad = end.latitude * (3.14159265359 / 180);
    final double deltaLatRad =
        (end.latitude - start.latitude) * (3.14159265359 / 180);
    final double deltaLngRad =
        (end.longitude - start.longitude) * (3.14159265359 / 180);

    final double a = (sin(deltaLatRad / 2) * sin(deltaLatRad / 2)) +
        (cos(lat1Rad) *
            cos(lat2Rad) *
            sin(deltaLngRad / 2) *
            sin(deltaLngRad / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadius * c;

    // تقدير وقت المشي (متوسط سرعة 4 كم/ساعة)
    final double duration = distance / 4;

    return {
      'distance': distance,
      'duration': duration,
    };
  }
}
