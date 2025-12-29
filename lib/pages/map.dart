import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class myMap extends StatefulWidget {
  const myMap({Key? key}) : super(key: key);

  @override
  State<myMap> createState() => _myMapState();
}

class _myMapState extends State<myMap> {
  late LatLng _pGooglePlex;
  static const LatLng _pApplePark = LatLng(9.578, 6.466); // Permanent marker

  Set<Marker> markers = Set();
  Set<Circle> circles = Set();

  @override
  void initState() {
    super.initState();
    // Call the method to fetch data when the widget is initialized
    fetchData();
    // Set up a periodic timer to fetch data every minute
    Timer.periodic(Duration(seconds: 5), (Timer timer) {
      fetchData();
    });

    // Add the permanent marker to the set of markers
    markers.add(
      Marker(
        markerId: MarkerId("_applePark"),
        icon: BitmapDescriptor.defaultMarker,
        position: _pApplePark,
        infoWindow: InfoWindow(title: 'Apple Park'),
      ),
    );

    // Add the circle around _pApplePark
    circles.add(
      Circle(
        circleId: CircleId("2"),
        center: _pApplePark,
        radius: 430,
        strokeWidth: 2,
        fillColor: Colors.red.withOpacity(0.2),
      ),
    );
  }

  Future<void> fetchData() async {
    final apiKey = 'JF82837LX447D1WF';
    final channelId = '2322010';

    try {
      final response = await http.get(
        Uri.parse(
          'https://api.thingspeak.com/channels/$channelId/feeds.json?results=1&api_key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final latitude = double.parse(data['feeds'][0]['field1'].toString());
        final longitude = double.parse(data['feeds'][0]['field2'].toString());

        setState(() {
          _pGooglePlex = LatLng(latitude, longitude);
          // Update the dynamic marker in the set of markers
          markers.add(
            Marker(
              markerId: MarkerId("_sourceLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _pGooglePlex,
            ),
          );
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pGooglePlex ?? LatLng(0, 0),
          zoom: 13,
        ),
        markers: markers,
        circles: circles,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.arrow_back_ios),
      ),
    );
  }
}
