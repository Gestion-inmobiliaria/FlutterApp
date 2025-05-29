import 'package:latlong2/latlong.dart';

class MapZones {
  static final List<LatLng> zonaNortePoints = [
    LatLng(-17.725219243373026, -63.16481006425453),
    LatLng(-17.74917133972358, -63.174596136965135),
    LatLng(-17.755548399918535, -63.15536889626856),
    LatLng(-17.73633666983866, -63.14283818638278),
  ];

  static final List<LatLng> zonaCentroPoints = [
    LatLng(-17.776062873377217, -63.18872072983995),
    LatLng(-17.79478731071668, -63.187324713287985),
    LatLng(-17.79085668823516, -63.17033020621482),
    LatLng(-17.77398160103255, -63.17288091658793),
  ];

  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      LatLng a = polygon[j];
      LatLng b = polygon[j + 1];
      if (((a.latitude > point.latitude) != (b.latitude > point.latitude)) &&
          (point.longitude <
              (b.longitude - a.longitude) *
                      (point.latitude - a.latitude) /
                      (b.latitude - a.latitude) +
                  a.longitude)) {
        intersectCount++;
      }
    }
    return (intersectCount % 2) == 1;
  }
}
