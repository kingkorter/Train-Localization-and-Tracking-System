import 'dart:async';
import 'package:finalyear_application_1/pages/map.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart'; // Import the geolocator package
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Train Localization and Tracking System',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String latitude = '';
  String longitude = '';
  String emergencyInfo = '';
  late Timer _timer;

  // Variables to store user input for latitude and longitude
  TextEditingController latitudeController = TextEditingController();
  TextEditingController longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Call the method to fetch data when the widget is initialized
    fetchData();

    // Set up a timer to refresh data every 60 seconds
    _timer = Timer.periodic(Duration(seconds: 5), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    // Cancel the timer to avoid memory leaks when the widget is disposed
    _timer.cancel();
    super.dispose();
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

        latitude = data['feeds'][0]['field1'].toString();
        longitude = data['feeds'][0]['field2'].toString();
        emergencyInfo = data['feeds'][0]['field4'].toString();

        setState(() {});
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  double calculateDistance() {
    // Get user input for latitude and longitude
    double inputLatitude = double.tryParse(latitudeController.text) ?? 0.0;
    double inputLongitude = double.tryParse(longitudeController.text) ?? 0.0;

    // Create LatLng objects for API data and user input
    LatLng apiLatLng = LatLng(double.parse(latitude), double.parse(longitude));
    LatLng userLatLng = LatLng(inputLatitude, inputLongitude);

    // Calculate the distance using the geolocator package
    double distance = Geolocator.distanceBetween(
      apiLatLng.latitude,
      apiLatLng.longitude,
      userLatLng.latitude,
      userLatLng.longitude,
    );

    return distance;
  }

  void navigateToMapPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => myMap(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Train Localization and Tracking System'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Latitude: $latitude',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Longitude: $longitude',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Emergency Information: $emergencyInfo',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // Text fields for user input
            TextField(
              controller: latitudeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Latitude'),
            ),
            TextField(
              controller: longitudeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter Longitude'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Calculate and display the distance
                double distance = calculateDistance();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Distance Calculation'),
                      content: Text('Distance: $distance meters'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Calculate Distance'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: navigateToMapPage,
              child: Text('Open Map Page'),
            ),
          ],
        ),
      ),
    );
  }
}
