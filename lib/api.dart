import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:latlong2/latlong.dart';

enum CrashConditions {
  clear(1, 'Clear'),
  raining(2, 'Raining'),
  fog(3, 'Fog'),
  smokeDust(4, 'Smoke/dust');

  const CrashConditions(this.number, this.description);

  final int number;
  final String description;
}

enum CrashNature {
  angle(1, "Angle"),
  collisionMisc(2, "Collision - miscellaneous"),
  fall(3, "Fall form vehicle"),
  headon(4, "Head-on"),
  animal(5, "Hit animal"),
  object(6, "Hit object"),
  parked(7, "Hit parked vehicle"),
  ped(8, "Hit pedestrian"),
  noncollision(9, "Non-collision - miscellaneous"),
  other(10, "Other"),
  overturned(11, "Overturned"),
  rearend(12, "Rear-end"),
  sideswipe(13, "Sideswipe"),
  extLoad(14, "Struck by external load"),
  intLoad(15, "Struck by internal load");

  const CrashNature(this.number, this.description);

  final int number;
  final String description;
}

enum CrashType {
  ped(1, "Hit pedestrian"),
  multiVeh(2, "Multi-vehicle"),
  other(3, "Other"),
  singleVeh(4, "Single vehicle");

  const CrashType(this.number, this.description);

  final int number;
  final String description;
}

enum CrashSeverity {
  fatal(1, "Fatal"),
  hospitalisation(2, "Hospitalisation"),
  medicalTreatment(3, "Medical treatment"),
  minorInjury(4, "Minor injury"),
  propertyDmg(5, "Property damage only");

  const CrashSeverity(this.number, this.description);

  final int number;
  final String description;
}

class Crash {
  late int id;
  // late List<int> location;
  late LatLng location;
  late int severityIndex;
  late bool detailed;
  CrashNature? nature;

  Crash(Map<String, dynamic> description) {
    id = description['id'];
    location = LatLng(description['location'][1], description['location'][0]) ;
    severityIndex = description['severityindex'];
    detailed = description.containsKey('type');

    if (detailed) {
      // Assume it contains the other keys, add them.
    }
  }
}

class ApiResponse {
  List<Crash> crashes = [];

  ApiResponse(String responseBody) {
    List<dynamic> crashesRaw = jsonDecode(responseBody);
    for (var crash in crashesRaw) {
      crashes.add(Crash(crash));
    }
  }
}

class ApiRequest {
  // So far used:
  List<List<double?>> corners = [[-8.247191862079545, 136.4674620687551], [-29.54422005573508, 155.74905412309064]];
  List<String> vehicleTypes = [
    'car',
    'motorcycle',
    'truck',
    'bus',
    'bicycle',
    'pedestrian',
    'other'
  ];
  List<int> yearRange = [2001, 2020];
  List<CrashSeverity> severities = [
    CrashSeverity.fatal, 
    CrashSeverity.hospitalisation, 
    CrashSeverity.medicalTreatment,
    CrashSeverity.minorInjury, 
    CrashSeverity.propertyDmg
  ];
  // So far unused:
  List<CrashNature> nature = [];
  List<CrashType> type = [];
  List<CrashConditions> conditions = [];

  bool isVehicleSelected(String veh) {
    return vehicleTypes.contains(veh);
  }

  bool isSeveritySelected(CrashSeverity severity) {
    return severities.contains(severity);
  }

  void selectVehicle(String veh, bool newState) {
    if (newState && !isVehicleSelected(veh)) {
      vehicleTypes.add(veh);
    } else if (!newState && isVehicleSelected(veh)) {
      vehicleTypes.remove(veh);
    }
  }

  void selectSeverity(CrashSeverity severity, bool newState) {
    if (newState && !isSeveritySelected(severity)) {
      severities.add(severity);
    } else if (!newState && isSeveritySelected(severity)) {
      severities.remove(severity);
    }
  }

  void updateYearRange(int min, int max) {
    yearRange = [min, max];
  }

  void updateBounds(LatLngBounds? bounds) {
    corners = [
      [bounds?.southWest.longitude, bounds?.southWest.latitude,],
      [bounds?.northEast.longitude, bounds?.northEast.latitude,],
    ];
  }

  Map<String, dynamic> toJson() => {
        'corner1': corners[0],
        'corner2': corners[1],
        'vehicle_types': vehicleTypes,
        'yearmax': yearRange[1],
        'yearmin': yearRange[0],
        'severity': severities.map((x) => x.number).toList()
      };
}

class CrashMapApi {
  late String _baseUrl;

  CrashMapApi(String baseUrl) {
    _baseUrl = baseUrl;
  }

  Future<ApiResponse> fetch(ApiRequest request) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/list_crashes'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(request.toJson()),
    );
    return ApiResponse(response.body);
  }
}
