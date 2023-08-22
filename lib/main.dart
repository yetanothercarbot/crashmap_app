import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api.dart';
import 'ui.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainAppState(),
      child: MaterialApp(
        title: 'CrashMap',
        home: const MyHomePage(),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
      ),
    );
  }
}

class MainAppState extends ChangeNotifier {
  late Future<ApiResponse> response;
  CrashMapApi api = CrashMapApi('https://api.crashmap.xyz');
  ApiRequest request = ApiRequest();

  MainAppState() {
    getData();
  }

  void getData() {
    response = api.fetch(request);
  }

  void selectVehicle(String veh, [bool? newState]) {
    newState ??= true;
    request.selectVehicle(veh, newState);
    notifyListeners();
  }

  void updateDateRange(RangeValues values) {
    request.updateYearRange(values.start.round(), values.end.round());
    notifyListeners();
  }

  void selectSeverity(CrashSeverity sev, [bool? newState]) {
    newState ??= true;
    request.selectSeverity(sev, newState);
    notifyListeners();
  }
}
