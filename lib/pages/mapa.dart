import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:projeto_emel_cm/model/Gira.dart';
import 'package:projeto_emel_cm/model/parque.dart';
import 'package:projeto_emel_cm/pages/gira_detail_page.dart';
import 'package:projeto_emel_cm/pages/parque_detail_page.dart';
import 'package:provider/provider.dart';
import '../repository/parques_repository.dart';
import '../repository/gira_repository.dart';

class Mapa extends StatefulWidget {
  const Mapa({super.key});

  @override
  State<Mapa> createState() => _MapaState();
}

class _MapaState extends State<Mapa> {
  List<Parque> parques = [];
  List<Gira> docks = [];
  bool showParques = true;

  Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer<GoogleMapController>();

  LatLng? _currentP;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
    fetchData();
  }

  Future<void> fetchData() async {
    if (showParques) {
      final parquesRepository = context.read<ParquesRepository>();
      parques = await parquesRepository.getParques();
    } else {
      final giraRepository = context.read<GiraRepository>();
      docks = await giraRepository.getGiras();
    }
    _updateMarkers();
  }

  void _updateMarkers() {
    Set<Marker> newMarkers = {};

    if (showParques) {
      for (var parque in parques) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(parque.nome),
            position: LatLng(double.parse(parque.latitude), double.parse(parque.longitude)),
            infoWindow: InfoWindow(
              title: parque.nome,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ParqueDetailPage(parque: parque, parqueId: parque.id),
                ),
              );
            },
          ),
        );
      }
    } else {
      for (var gira in docks) {
        newMarkers.add(
          Marker(
            markerId: MarkerId(gira.nome),
            position: LatLng(gira.latitude, gira.longitude),
            infoWindow: InfoWindow(
              title: gira.nome,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiraDetailPage(giraId: gira.id),
                ),
              );
            },
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers = newMarkers;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentP == null
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _mapController.complete(controller);
          _cameraToPosition(_currentP!);
        },
        initialCameraPosition: CameraPosition(
          target: _currentP ?? const LatLng(37.4223, -122.0848),
          zoom: 13,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 16.0),
        child: FloatingActionButton(
          onPressed: () => _showSelectionMenu(context),
          backgroundColor: Colors.blue[900],
          child: Icon(Icons.filter_list, color: Colors.greenAccent[700]),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }

  void _showSelectionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.local_parking),
                title: Text('Mostrar Parques'),
                onTap: () {
                  setState(() {
                    showParques = true;
                    fetchData();
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.directions_bike),
                title: Text('Mostrar Stands de Bicicletas'),
                onTap: () {
                  setState(() {
                    showParques = false;
                    fetchData();
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(_newCameraPosition),
    );
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        print('Nova localização: ${currentLocation.latitude}, ${currentLocation.longitude}');
        if (mounted) {
          setState(() {
            _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            _updateMarkers();
          });
          _cameraToPosition(_currentP!);
        }
      } else {
        print('Localização atual não disponível');
      }
    });
  }

  @override
  void dispose() {
    _mapController.future.then((controller) => controller.dispose());
    super.dispose();
  }
}