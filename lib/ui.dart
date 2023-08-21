import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final mapController = MapController();
  bool showHeatmap = false, showMarkers = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
            appBar: AppBar(title: const Text('CrashMap')),
            // floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.location_pin)),
            drawer: const FilterDrawer(),
            body: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                  center: const LatLng(-22.107471, 149.50843),
                  zoom: 6,
                  maxBounds: LatLngBounds(
                      const LatLng(-8.247191862079545, 136.4674620687551),
                      const LatLng(-29.54422005573508, 155.74905412309064)),
                  interactiveFlags:
                      InteractiveFlag.all - InteractiveFlag.rotate,
                  onMapReady: () {
                    var request =
                        Provider.of<MainAppState>(context, listen: false)
                            .request;
                    request.updateBounds(mapController.bounds);
                    mapController.mapEventStream.listen((evt) {
                      if ([
                        MapEventScrollWheelZoom,
                        MapEventMoveEnd,
                        MapEventFlingAnimationEnd,
                      ].contains(evt.runtimeType)) {
                        // Update on movement
                        request.updateBounds(mapController.bounds);
                      }
                    });
                  }),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'xyz.crashmap.app',
                ),
              ],
            ));
      },
    );
  }
}

class FilterDrawer extends StatefulWidget {
  const FilterDrawer({super.key});

  @override
  State<FilterDrawer> createState() => _FilterDrawerState();
}

class _FilterDrawerState extends State<FilterDrawer> {
  @override
  Widget build(BuildContext context) {
    var request = context.watch<MainAppState>().request;
    return Drawer(
      child: SafeArea(
          child: ListView(
        children: [
          ExpansionTile(
            title: Text('Vehicles'),
            children: [
              CheckboxListTile(
                  value: request.isVehicleSelected('car'),
                  title: const Text('Car'),
                  onChanged: (bool? value) {})
            ],
          ),
          ExpansionTile(title: Text('Year Range')),
          ExpansionTile(title: Text('Severity'))
        ],
      )),
    );
  }
}
