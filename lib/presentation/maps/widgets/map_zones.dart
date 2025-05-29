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

  static final List<LatLng> zonaUV1Points = [
    LatLng(-17.77068135911697, -63.18234028578617),
    LatLng(-17.774617798991528, -63.181829964285754),
    LatLng(-17.774326162391223, -63.177287964735996),
    LatLng(-17.775152262206905, -63.17514451589296),
    LatLng(-17.776804505198935, -63.173103073385974),
    LatLng(-17.774325569440876, -63.1664176297629),
    LatLng(-17.772381713785773, -63.16738743290804),
    LatLng(-17.77136122647832, -63.168408187078164),
    LatLng(-17.770632408893544, -63.170653720286865),
    LatLng(-17.770389506497118, -63.17213370318055),
    LatLng(-17.770632761534575, -63.18218718731848),
    LatLng(-17.77068135911697, -63.18234028578617), // Cierra el polígono
  ];

  static final List<LatLng> zonaVilla1roPoints = [
    LatLng(-17.79043675943438, -63.14396124607573),
    LatLng(-17.800263710785746, -63.14194049680904),
    LatLng(-17.80589871976224, -63.14071351192108),
    LatLng(-17.807066956833307, -63.14071350854716),
    LatLng(-17.809219500280502, -63.14109591800874),
    LatLng(-17.81138510458248, -63.14234054948928),
    LatLng(-17.8134235921451, -63.110164855348245),
    LatLng(-17.777263447750915, -63.10780866560903),
    LatLng(-17.78995675684004, -63.14233959626163),
    LatLng(-17.79043675943438, -63.14396124607573), // Cierra el polígono
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
