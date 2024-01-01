import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Games1.dart';
import 'login.dart';

class NearbyGames extends StatefulWidget {
  final List<dynamic> dataList;

  NearbyGames({required this.dataList});

  @override
  _NearbyGamesState createState() => _NearbyGamesState();
}

class _NearbyGamesState extends State<NearbyGames> {
  List<dynamic> dataList = [];
  late String userId;
  double _latitude = 0.0;
  double _longitude = 0.0;
  List<Map<String, dynamic>> mydataList = []; // Adjusted type
  late List<String> preferences1 = [];
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
   dataList = List.from(widget.dataList);
    _getCurrentLocation();
    loadPreferences();
  }
  Future<List<Map<String, dynamic>>> fetchData(double latitude, double longitude) async {
    final String apiUrl = 'https://educationmobileapp.000webhostapp.com/games.php';
    List<String> preferences2 = await loadPreferences();
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'UserID': preferences2[0],
        },
      );

      print('Raw JSON Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Parsed JSON Data: $jsonData');

        return List<Map<String, dynamic>>.from(jsonData); // Adjusted type
      } else {
        print('Error: ${response.statusCode}');
        return [{'error': 'Error by loading data'}];
      }
    } catch (e) {
      print('Exception: $e');
      return [{'exception': 'Exception occurred'}];
    }
  }

  Future<List<String>> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '0';
    isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    String isLogedIn1 = isLoggedIn.toString();
    setState(() {});
    preferences1 = [userId, isLogedIn1];
    return [userId, isLogedIn1];
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = double.parse("${position.latitude}");
        _longitude = double.parse("${position.longitude}");
      });
    } catch (e) {
      setState(() {
        _latitude = 33.890520505027176;
        _longitude = 35.50274476351151;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nearby Games')),
      body: Center(
        child: ListView.builder(
          itemCount: dataList.length,
          itemBuilder: (context, index) {
            return _buildGameContainer(context, dataList[index]);
          },
        ),
      ),
    );
  }

  Widget _buildGameContainer(BuildContext context, Map<String, dynamic> game) {
    String playfieldName = game['playfield_name'];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.amber,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the photo of the playfield
            FutureBuilder<String>(
              future: fetchLogoLink(game['playfield_id']),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the fetched logo
                  return Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(snapshot.data!),
                      ),
                    ),
                  );
                } else {
                  // Otherwise, display a placeholder or loading indicator
                  return Container(
                    width: 80.0,
                    height: 80.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey,
                    ),
                  );
                }
              },
            ),
            SizedBox(width: 16.0),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColoredTextField('Game ID: ${game['game_id']}', Colors.yellow),
                  _buildColoredTextField('Playfield Name: ${game['playfield_name']}', Colors.red),
                  _buildColoredTextField('Date: ${game['game_date']}', Colors.orange),
                  _buildColoredTextField('Time: ${game['game_time_start']} - ${game['game_time_ends']}', Colors.blue),
                  _buildColoredTextField('Max Players: ${game['max_players']}', Colors.lightBlueAccent),
                  _buildColoredTextField('Available Seats: ${game['available_seats']}', Colors.pink),
                  _buildColoredTextField('Full: ${game['full'] == 1 ? 'Yes' : 'No'}', Colors.grey),
                  _buildColoredTextField('Photo Session: ${game['photo_session'] == 0 ? 'No photos allowed' : 'Photos allowed'}', Colors.yellow),
                ],
              ),
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildElevatedButton('Book Game', () async {
                  if (isLoggedIn==false) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                    print('Book Game pressed for game ID: ${game['game_id']}');

                    // Fetch logo_link asynchronously
                    String logoLink = await fetchLogoLink(game['playfield_id']);
                  }
                  else {
                    mydataList = await fetchData(_latitude, _longitude).timeout(Duration(seconds: 30));
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MyWrapperClass(mylist: mydataList)));                  }
                  // TODO: Use the fetched logoLink as needed
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredTextField(String text, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! /1.2,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          decoration: TextDecoration.none,
          fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! / 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<String> fetchLogoLink(String playfieldId) async {
    final String apiUrl = 'https://educationmobileapp.000webhostapp.com/playfieldlogogetter.php';

    try {
      final response = await http.get(Uri.parse('$apiUrl?playfieldId=$playfieldId'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return 'https://cdn.vectorstock.com/i/thumb-large/35/85/soccer-field-icon-logo-design-vector-38003585.jpg'; // Placeholder link
      }
    } catch (e) {
      return 'https://cdn.vectorstock.com/i/thumb-large/35/85/soccer-field-icon-logo-design-vector-38003585.jpg'; // Placeholder link
    }
  }
}
