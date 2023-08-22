import 'package:crashmap_app/api.dart';
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

  @override
  Widget build(BuildContext context) {
    var response = context.watch<MainAppState>().response;
    var loadingStatus = context.watch<MainAppState>().loading;
    return FutureBuilder<ApiResponse>(
      future: response,
      builder: (futureContext, snapshot) {
        return LayoutBuilder(
          builder: (layoutContext, constraints) {
            if (constraints.maxWidth > 600) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('CrashMap'), 
                  bottom: loadingStatus ? PreferredSize(
                    preferredSize: Size(constraints.maxWidth, 0), 
                    child:  const LinearProgressIndicator(),
                  ) : null,),
                body: Row(children: [const SizedBox(width: 240, child: FilterDrawer()), Container(width: 0.5, color: Colors.black), Expanded(child: CrashMap(mapController: mapController, screenSize: Size(constraints.maxWidth, constraints.maxHeight),))])
              );
            } else {
              // Mobile layout
              return Scaffold(
                appBar: AppBar(title: const Text('CrashMap'), bottom: loadingStatus ? PreferredSize(preferredSize: Size(constraints.maxWidth, 0), child: const LinearProgressIndicator(),) : null,),
                drawer: const FilterDrawer(),
                body: CrashMap(mapController: mapController, screenSize: Size(constraints.maxWidth, constraints.maxHeight))
              );
            }
          },
        );
      }
    );
  }
}

class CrashMap extends StatelessWidget {
  const CrashMap({
    super.key,
    required this.mapController,
    required this.screenSize,
  });

  final MapController mapController;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    var response = context.watch<MainAppState>().response;
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
          screenSize: screenSize,
          center: const LatLng(-22.107471, 149.50843),
          zoom: 6,
          maxZoom: 18,
          maxBounds: LatLngBounds(
              const LatLng(-6.697788086491729, 135.62482150691713),
              const LatLng(-31.324481038082332, 162.0974699871303)),
          interactiveFlags:
              InteractiveFlag.all - InteractiveFlag.rotate,
          onMapReady: () {
            var state = Provider.of<MainAppState>(context, listen: false);
            state.request.updateBounds(mapController.bounds);
            mapController.mapEventStream.listen((evt) {
              if ([
                MapEventScrollWheelZoom,
                MapEventMoveEnd,
                MapEventFlingAnimationEnd,
              ].contains(evt.runtimeType)) {
                // Update on movement
                state.request.updateBounds(mapController.bounds);
                state.heatmapEn = mapController.zoom < 15;
                state.getData();
              }
            });
          }),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'xyz.crashmap.app',
          maxNativeZoom: 18,
        ),
        FutureBuilder(
          future: response,
          builder: (context, snapshot) {
            return MarkerLayer(
              markers: snapshot.hasData ? snapshot.data!.markers() : [],
            );
          }
        )
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

    return NavigationDrawer(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: Text('CrashMap'),
          ),
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
          ExpansionTile(
            title: const Text('Severity'), 
            children: [
              CheckboxListTile(
                  value: state.request.isSeveritySelected(CrashSeverity.fatal),
                  title: const Text('Fatal'),
                  // secondary: const Icon(Icons.),
                  onChanged: (bool? value) {
                    state.selectSeverity(CrashSeverity.fatal, value);
                  }
                ),
                CheckboxListTile(
                  value: state.request.isSeveritySelected(CrashSeverity.hospitalisation),
                  title: const Text('Hospitalisation'),
                  // secondary: const Icon(Icons.),
                  onChanged: (bool? value) {
                    state.selectSeverity(CrashSeverity.hospitalisation, value);
                  }
                ),
                CheckboxListTile(
                  value: state.request.isSeveritySelected(CrashSeverity.medicalTreatment),
                  title: const Text('Medical treatment'),
                  // secondary: const Icon(Icons.),
                  onChanged: (bool? value) {
                    state.selectSeverity(CrashSeverity.medicalTreatment, value);
                  }
                ),
                CheckboxListTile(
                  value: state.request.isSeveritySelected(CrashSeverity.minorInjury),
                  title: const Text('Minor injury'),
                  // secondary: const Icon(Icons.),
                  onChanged: (bool? value) {
                    state.selectSeverity(CrashSeverity.minorInjury, value);
                  }
                ),
                CheckboxListTile(
                  value: state.request.isSeveritySelected(CrashSeverity.propertyDmg),
                  title: const Text('Property damage only'),
                  // secondary: const Icon(Icons.),
                  onChanged: (bool? value) {
                    state.selectSeverity(CrashSeverity.propertyDmg, value);
                  }
                ),
            ],
          ),
        ],
    );
  }
}
