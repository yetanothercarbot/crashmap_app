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
        if (constraints.maxWidth > 600) {
          return Scaffold(
            appBar: AppBar(title: const Text('CrashMap')),
            // floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.location_pin)),
            body: Row(children: [SizedBox(width: 240, child: FilterDrawer()), Container(width: 0.5, color: Colors.black), Expanded(child: CrashMap(mapController: mapController, runtimeType: runtimeType))])
          );
        } else {
          // Mobile layout
          return Scaffold(
            appBar: AppBar(title: const Text('CrashMap')),
            // floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.location_pin)),
            drawer: const FilterDrawer(),
            body: CrashMap(mapController: mapController, runtimeType: runtimeType)
          );
        }
        
      },
    );
  }
}

class CrashMap extends StatelessWidget {
  const CrashMap({
    super.key,
    required this.mapController,
    required this.runtimeType,
  });

  final MapController mapController;
  final Type runtimeType;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
    final state = context.watch<MainAppState>();

    return Drawer(
      child: SafeArea(
          child: ListView(
        children: [
          ExpansionTile(
            title: const Text('Vehicles'),
            children: [
              CheckboxListTile(
                  value: state.request.isVehicleSelected('car'),
                  title: const Text('Car'),
                  secondary: const Icon(Icons.directions_car),
                  onChanged: (bool? value) {
                    state.selectVehicle('car', value);
                  }),
              CheckboxListTile(
                  value: state.request.isVehicleSelected('bicycle'),
                  title: const Text('Bicycle'),
                  secondary: const Icon(Icons.directions_bike),
                  onChanged: (bool? value) {
                    state.selectVehicle('bicycle', value);
                  }),
              CheckboxListTile(
                  value: state.request.isVehicleSelected('motorcycle'),
                  title: const Text('Motorcycle'),
                  secondary: const Icon(Icons.motorcycle),
                  onChanged: (bool? value) {
                    state.selectVehicle('motorcycle', value);
                  }),
              CheckboxListTile(
                  value: state.request.isVehicleSelected('truck'),
                  title: const Text('Truck'),
                  secondary: const Icon(Icons.local_shipping),
                  onChanged: (bool? value) {
                    state.selectVehicle('truck', value);
                  }),
              CheckboxListTile(
                  value: state.request.isVehicleSelected('bus'),
                  title: const Text('Bus'),
                  secondary: const Icon(Icons.airport_shuttle),
                  onChanged: (bool? value) {
                    state.selectVehicle('bus', value);
                  }),
              CheckboxListTile(
                  value: state.request.isVehicleSelected('pedestrian'),
                  title: const Text('Pedestrian'),
                  secondary: const Icon(Icons.directions_walk),
                  onChanged: (bool? value) {
                    state.selectVehicle('pedestrian', value);
                  }),
              CheckboxListTile(
                  value: state.request.isVehicleSelected('other'),
                  title: const Text('Other'),
                  secondary: const Icon(Icons.forklift),
                  onChanged: (bool? value) {
                    state.selectVehicle('other', value);
                  }),
            ],
          ),
          ExpansionTile(
            title: const Text('Year Range'), 
            children: [
              RangeSlider(
                min: 2001,
                max: 2020,
                divisions: 19,
                values: RangeValues(state.request.yearRange[0].toDouble(), state.request.yearRange[1].toDouble()), 
                onChanged: (RangeValues values) {state.updateDateRange(values);}
              ),
              Text('${state.request.yearRange[0]}-${state.request.yearRange[1]}')
            ]),
          ExpansionTile(title: Text('Severity'))
        ],
      )),
    );
  }
}
