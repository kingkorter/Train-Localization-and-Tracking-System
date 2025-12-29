import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ThingSpeak API Example',
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

  Future<void> fetchData() async {
    final apiKey = 'JF82837LX447D1WF';
    final channelId = '2322010';
    final results = '2';

    final url = Uri.parse(
        'https://api.thingspeak.com/channels/$channelId/feeds.json?results=$results&api_key=$apiKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['feeds'] != null && data['feeds'].isNotEmpty) {
          latitude = data['feeds'][0]['field1'].toString();
          // Assuming latitude is stored in 'field1', change it accordingly
          setState(() {});
        } else {
          print('No data available.');
        }
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ThingSpeak API Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Latitude:',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              latitude,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
