// lib/screens/hospital_map_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  LatLng? _current;
  bool _loading = true;
  List<_Hospital> _hospitals = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initLocationAndFetch();
  }

  Future<void> _initLocationAndFetch() async {
    setState(() => _loading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
          setState(() => _loading = false);
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
      _current = LatLng(pos.latitude, pos.longitude);

      await _fetchNearbyHospitals(pos.latitude, pos.longitude, 5000); // 5km

      if (_hospitals.isNotEmpty && _current != null) {
        _mapController.move(_current!, 13.0);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error initializing location: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchNearbyHospitals(double lat, double lon, int radiusMeters) async {
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="hospital"](around:$radiusMeters,$lat,$lon);
  way["amenity"="hospital"](around:$radiusMeters,$lat,$lon);
  relation["amenity"="hospital"](around:$radiusMeters,$lat,$lon);
);
out center;
''';

    final uri = Uri.parse('https://overpass-api.de/api/interpreter');
    final res = await http.post(uri, body: {'data': query});

    if (res.statusCode == 200) {
      final jsonBody = jsonDecode(res.body);
      final elements = (jsonBody['elements'] as List<dynamic>);
      final List<_Hospital> list = [];
      for (final el in elements) {
        double? latEl;
        double? lonEl;
        if (el['type'] == 'node') {
          latEl = (el['lat'] as num).toDouble();
          lonEl = (el['lon'] as num).toDouble();
        } else if (el['center'] != null) {
          latEl = (el['center']['lat'] as num).toDouble();
          lonEl = (el['center']['lon'] as num).toDouble();
        }
        if (latEl == null || lonEl == null) continue;
        final tags = el['tags'] ?? {};
        final name = tags['name'] ?? 'Hospital';
        final addressParts = <String>[];
        if (tags['addr:street'] != null) addressParts.add(tags['addr:street']);
        if (tags['addr:housenumber'] != null) addressParts.add(tags['addr:housenumber']);
        if (tags['addr:city'] != null) addressParts.add(tags['addr:city']);
        final address = addressParts.join(', ');
        list.add(_Hospital(name: name, address: address, lat: latEl, lon: lonEl));
      }

      // sort by distance to current
      if (_current != null) {
        final dist = Distance();
        list.sort((a, b) {
          final da = dist.as(LengthUnit.Meter, _current!, LatLng(a.lat, a.lon));
          final db = dist.as(LengthUnit.Meter, _current!, LatLng(b.lat, b.lon));
          return da.compareTo(db);
        });
      }
      setState(() => _hospitals = list);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Overpass API error: ${res.statusCode}')));
    }
  }

  Future<void> _openNavigation(double lat, double lon, String name) async {
    final googleUrl = Uri.parse('google.navigation:q=$lat,$lon');
    final appleUrl = Uri.parse('https://maps.apple.com/?daddr=$lat,$lon');
    final geoUrl = Uri.parse('geo:$lat,$lon?q=${Uri.encodeComponent(name)}');

    // Try google navigation, then geo, then Apple maps
    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleUrl)) {
      await launchUrl(appleUrl, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No map application available')));
    }
  }

  Marker _hospitalMarker(_Hospital h) {
    return Marker(
      width: 56,
      height: 56,
      point: LatLng(h.lat, h.lon),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(h.address.isNotEmpty ? h.address : 'Address not available'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _openNavigation(h.lat, h.lon, h.name);
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigate'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _mapController.move(LatLng(h.lat, h.lon), 15.0);
                        },
                        child: const Text('Zoom to'),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        },
        child: Image.asset(
          'assets/icon/app_icon.png',
          width: 44,
          height: 44,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];
    if (_current != null) {
      markers.add(
        Marker(
          width: 48,
          height: 48,
          point: _current!,
          child: const Icon(Icons.my_location, color: Colors.blue, size: 30),
        ),
      );
    }
    markers.addAll(_hospitals.map(_hospitalMarker));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Organ Transplant Hospitals'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _current ?? LatLng(20.5937, 78.9629),
                initialZoom: 13.0,
                maxZoom: 18.0,
                minZoom: 3.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.shared_lives',
                ),
                MarkerLayer(markers: markers),
              ],
            ),
    );
  }
}

class _Hospital {
  final String name;
  final String address;
  final double lat;
  final double lon;

  _Hospital({
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
  });
}
