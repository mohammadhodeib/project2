import 'dart:async';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'nearbyfields.dart';
import 'package:flutter/src/material/text_button.dart';
//import 'package:playfields3/Manager.dart';
import 'package:geolocator/geolocator.dart';
//import 'FieldFinder.dart';
import 'package:http/http.dart' as http;
import 'package:geolocatortest/NearbyGames.dart';
import 'dart:convert';
import 'singup.dart';
import 'package:shared_preferences/shared_preferences.dart';





class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _lattitude = 0.0;
  double _longitude= 0.0 ;
  List<dynamic> mydataList = ["Item 1",
    "Item 2",
    {"key": "value"},
    42,];
  late String userId;
  late bool isLoggedIn = false;
  List<Map<String, dynamic>> mydataList1 = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    loadPreferences();
  }
  Future<List<String>> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('user_id') ?? '0';
    isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    String isLogedIn1 = isLoggedIn.toString();
    setState(() {});
    return [userId, isLogedIn1];
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _lattitude= double.parse("${position.latitude}") ;
        _longitude= double.parse("${position.longitude}");
      });
    } catch (e) {
      setState(() {
        _lattitude = 33.890520505027176;
        _longitude = 35.50274476351151;
      });
    }
  }

  Future<List<dynamic>> fetchData(double latitude, double longitude ) async {
    final String apiUrl = 'https://educationmobileapp.000webhostapp.com/myfile.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),

        },
      );

      print('Raw JSON Response: ${response.body}'); // Print the raw JSON response

      if (response.statusCode == 200) {
        // Successful response, parse the data
        final jsonData = json.decode(response.body);

        print('Parsed JSON Data: $jsonData'); // Print the parsed JSON data

        // You can directly return the jsonData in its native form (List<dynamic>)
        return jsonData;
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
        return ['Error by loading data']; // Return an error message or handle it as needed
      }
    } catch (e) {
      print('Exception: $e');
      return ['Exception occurred']; // Return an exception message or handle it as needed
    }
  }

  Future<List<Map<String, dynamic>>> fetchData2(double latitude, double longitude) async {
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

  @override
  Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(
    title: Text('Playfields'),
    backgroundColor: Colors.yellow[200],

    ),
    body: Center(
    child: Stack(
    alignment: Alignment.center,
    children: [
    // Image widget to display the background image
    Image.network(
    'https://img.freepik.com/premium-vector/abstract-paint-with-brush-background-template_565745-198.jpg?w=900',
    width: double.infinity,
    height: double.infinity,
    fit: BoxFit.cover,
    ),


    Positioned(
    top: 75, // Adjust the values to position the TextField as needed
    left: 20,
    right: 20,
    child: Text(
    'feeling bored?',
    textAlign: TextAlign.center,
    overflow: TextOverflow.ellipsis,
    style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 32)
    ),
    ),
    const SizedBox(height:40),
    Positioned(
    top: 150,
    child:
    ClipRRect(
    borderRadius: BorderRadius.circular(5),
    child: Stack(
    children: <Widget>[
    Positioned.fill(
    child: Container(
    decoration: const BoxDecoration(
    gradient: LinearGradient(
    colors: <Color>[
    Colors.pinkAccent,
    Colors.lightBlueAccent,
    Colors.greenAccent,
    ]
    )
    ),
    ),
    ),
    TextButton(
    style: TextButton.styleFrom(
    padding: const EdgeInsets.all(15),
    primary: Colors.white,
    textStyle: const TextStyle(fontSize:20),
    ),
    onPressed: () async{
      /*if (isLoggedIn == true ) {
        mydataList1 =
        await fetchData2(_lattitude,_longitude ).timeout(Duration(seconds: 30));

        Navigator.push(context, MaterialPageRoute(builder: (context) => GamesPage(dataList: mydataList1)));

      }
      else {*/
      try {
      mydataList =
      await fetchData(_lattitude,_longitude ).timeout(Duration(seconds: 30)); // Set the timeout duration in seconds
      print("Async operation completed successfully");
      Navigator.push(context, MaterialPageRoute(builder: (context)=> NearbyGames(dataList: mydataList)));
    } on TimeoutException catch (e) {
      print("Async operation timed out: $e");
      Navigator.push(context, MaterialPageRoute(builder: (context)=> NearbyGames(dataList: mydataList)));
    } catch (e) {
      print("An error occurred: $e");
      Navigator.push(context, MaterialPageRoute(builder: (context)=> NearbyGames(dataList: mydataList)));
    }},
    child:  const Text('find your field',
            style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 26)
         ),
    ),
    ],
    ),

    ),
    ),

    //////////sign in
      Positioned(
        top: 250,
        child: Visibility(
          visible: !isLoggedIn,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.yellow,
                          Colors.grey,
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage()));
                  },
                  child: const Text('sign in',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 26)),
                ),
              ],
            ),
          ),
        ),
      ),

      Positioned(
        top: 320,
        right: 151,
        child: Container(
          child: Visibility(
            visible: !isLoggedIn,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SignupPage()));
              },
              child: Text(
                'or sign Up',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      ),
    //// end sign in
    Positioned(
    top: 400, // Adjust the values to position the TextField as needed
    left: 20,
    right: 20,
    child: Container(
    padding: EdgeInsets.all(2),
    decoration: BoxDecoration(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    ),
    child: Column (
    children: <Widget>[
    Text('newst news we picked',style: TextStyle(fontSize: 30),) ,
    SizedBox(height: 15,),
    MyClickableBox(),
    const SizedBox(height:20),
    MyClickableBox1(),]
    )


    ),
    ),
      Positioned(
        top: 250,
        child: Visibility(
          visible: isLoggedIn,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.yellow,
                          Colors.grey,
                          Colors.black,
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    primary: Colors.white,
                    textStyle: const TextStyle(fontSize: 20),
                  ),
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
                  child: const Text('logout',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 26)),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
    ),
    ),
    );
  }
}


class MyClickableBox extends StatelessWidget {
  final String linkText = 'leonel messi signed for barcelona .. ';
  final String url = 'https://accuweather.com';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        width: 500.0,
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: <Color>[
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
                Colors.redAccent,
              ]
          ),
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),


        ),
        child: Text(
          linkText,
          style: TextStyle(
            color: Colors.blue[50],
            decoration: TextDecoration.none,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  //Function to launch a URL
  void _launchURL(String url) async {
    await launch(url);

  }
}

class MyClickableBox1 extends StatelessWidget {
  final String linkText = 'better chealsea with new trainer ..  ';
  final String url = 'https://yahoo.com';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _launchURL(url);
      },
      child: Container(
        width: 500.0,
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: <Color>[
                Color(0xFF0D47A1),
                Color(0xFF1976D2),
                Colors.amberAccent,
              ]
          ),
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),

        ),
        child: Text(
          linkText,
          style: TextStyle(
            color: Colors.blue[50],
            decoration: TextDecoration.none,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

//Function to launch a URL
  void _launchURL(String url) async {
    await launch(url);
  }
}

