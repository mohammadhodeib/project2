import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'MyHomePage.dart';
import 'mygames.dart';

class Game {
  String gameTypeName;
  String gameId;
  String playfieldId;
  String gameTypeId;
  int maxPlayers;
  int availableSeats;
  bool full; // Updated to boolean
  String timeStart;
  String timeEnds;
  String date;
  bool photoSession; // Updated to boolean
  String playfieldName;
  double playfieldLatitude;
  double playfieldLongitude;
  bool match; // Updated to boolean

  Game({
    required this.gameTypeName,
    required this.gameId,
    required this.playfieldId,
    required this.gameTypeId,
    required this.maxPlayers,
    required this.availableSeats,
    required this.full,
    required this.timeStart,
    required this.timeEnds,
    required this.date,
    required this.photoSession,
    required this.playfieldName,
    required this.playfieldLatitude,
    required this.playfieldLongitude,
    required this.match,
  });

  // Factory method to create a Game instance from a Map
  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      gameTypeName: json['game_type_name'].toString(),
      gameId: json['game_id']?.toString() ?? '',
      playfieldId: json['playfield_id']?.toString() ?? '',
      gameTypeId: json['game_type_id']?.toString() ?? '',
      maxPlayers: int.tryParse(json['max_players']?.toString() ?? '0') ?? 0,
      availableSeats: int.tryParse(json['available_seats']?.toString() ?? '0') ?? 0,
      full: json['full'] == 1,
      timeStart: json['time_start']?.toString() ?? '',
      timeEnds: json['time_ends']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      photoSession: json['photo_session'] == 1,
      playfieldName: json['playfield_name']?.toString() ?? '',
      playfieldLatitude: double.tryParse(json['playfield_latitude']?.toString() ?? '0.0') ?? 0.0,
      playfieldLongitude: double.tryParse(json['playfield_longitude']?.toString() ?? '0.0') ?? 0.0,
      match: json['match'] == '1',
    );
  } }


class MyWrapperClass1 extends StatefulWidget {
  final List<Map<String, dynamic>> mylist;

  MyWrapperClass1({required this.mylist});

  @override
  _MyWrapperClassState createState() => _MyWrapperClassState();
}

class _MyWrapperClassState extends State<MyWrapperClass1> {
  late List<Game> games;
  late String userId;
  late bool isLoggedIn;
  late List<String> preferences1 = [];
  List<Map<String, dynamic>> mydataList = [];

  Future<List<String>> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '0';
    isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    String isLogedIn1 = isLoggedIn.toString();
    setState(() {});
    preferences1 = [userId, isLogedIn1];
    return [userId, isLogedIn1];
  }

  @override
  void initState() {
    super.initState();
    games = widget.mylist.map((data) => Game.fromJson(data)).toList();
    loadPreferences();
  }

  Future<void> updateGameStatus(int index) async {
    final game = games[index];
    final newStatus = !game.match; // Toggle the match status
    int newStatus1 = newStatus ? 1 : 0;

    print('Before setState - gameId: ${game.gameId}, newStatus: $newStatus1, userId: $userId');

    setState(() {
      games[index].match = newStatus;
    });

    print('After setState - gameId: ${game.gameId}, newStatus: $newStatus1, userId: $userId');

    // Call your API to update the game status
    await updateGameStatusApi(game.gameId, newStatus1, userId);
  }

  Future<void> updateGameStatusApi(String gameId, int newStatus, String userId) async {
    try {
      print('updategamestatusAPI started');
      final String apiUrl = 'https://educationmobileapp.000webhostapp.com/updategame1.php';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'game_id': gameId, 'match': newStatus.toString(), 'user_id': userId},
      );

      if (response.statusCode == 200) {
        // Parse and handle the response here
        // Example: Check if the response contains a success message
        final responseData = response.body;
        print('Response: $responseData');

        // You can add further processing based on the response data
      } else {
        // Handle HTTP error
        print('Failed to update game status. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
    } catch (error) {
      // Handle other errors
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Games Around You'),
        automaticallyImplyLeading: true, // Remove the back arrow

        actions: [
          // Add a button to the AppBar
          IconButton(
            icon: Icon(Icons.logout), // You can use any icon you prefer
            onPressed: () async {
              // Clear shared preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              // Navigate to MyHomePage and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
                    (route) => false, // This line removes all previous routes
              );
            },

          ),
          Text(
              'Logout',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              )),
          SizedBox(width:20)
        ],
      ),
      body: ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameContainer(context, game, index);
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(width: 20), // Adjust the spacing between buttons
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              child: Text(
                'Homepage',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContainer(BuildContext context, Game game, int index) {
    bool isBooked = game.match; // No need for comparison, as match is already a boolean

    return Builder(
      builder: (context) {
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
                FutureBuilder<String>(
                  future: fetchLogoLink(game.playfieldId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
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
                // Add your UI elements here based on the Game class
                SizedBox(width: 6.0),
                Container(
                  width: MediaQuery.of(context).size.width / 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildColoredTextField('Game ID: ${game.gameId}', Colors.yellow),
                      _buildColoredTextField(' type: ${game.gameTypeName}', Colors.black26),
                      _buildColoredTextField('Playfield : ${game.playfieldName}', Colors.red),
                      _buildColoredTextField('Date: ${game.date}', Colors.orange),
                      _buildColoredTextField('Time: ${game.timeStart} - ${game.timeEnds}', Colors.blue),
                      _buildColoredTextField('Max Players: ${game.maxPlayers}', Colors.lightBlueAccent),
                      _buildColoredTextField('Available Seats: ${game.availableSeats}', Colors.pink),
                      _buildColoredTextField('Full: ${game.full ? 'Yes' : 'No'}', Colors.grey),
                      _buildColoredTextField('Photo Session: ${game.photoSession ? 'Photos allowed' : 'No photos allowed'}', Colors.yellow),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    updateGameStatus(index);
                  },
                  style: ButtonStyle(
                    foregroundColor: getColor(Colors.red, Colors.white),
                    backgroundColor: getColor(Colors.white, Colors.red),
                  ),
                  child: Text(isBooked ? 'Booked!' : 'Book Game'),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  MaterialStateProperty<Color> getColor(Color color, Color colorPressed) {
    final getColor = (Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) {
        return colorPressed;
      } else {
        return color;
      }
    };
    return MaterialStateProperty.resolveWith(getColor);
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
          fontSize: Theme.of(context).textTheme.bodyText1!.fontSize! / 1.2,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          decoration: TextDecoration.none,
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
        return 'https://cdn.vectorstock.com/i/thumb-large/35/85/soccer-field-icon-logo-design-vector-38003585.jpg';
      }
    } catch (e) {
      return 'https://cdn.vectorstock.com/i/thumb-large/35/85/soccer-field-icon-logo-design-vector-38003585.jpg';
    }
  }
  Future<List<Map<String, dynamic>>> fetchData(String userId) async {
    final String apiUrl = 'https://educationmobileapp.000webhostapp.com/mybookedgames.php';
    List<String> preferences2 = await loadPreferences();
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {

          'user_id': userId,
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
}
