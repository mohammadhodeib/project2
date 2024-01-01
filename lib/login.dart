import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocatortest/Games1.dart';
import 'singup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:geolocatortest/MyHomePage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool loginFailed = false;
  late String userId;
  double _latitude = 0.0;
  double _longitude = 0.0;
  List<Map<String, dynamic>> mydataList = []; // Adjusted type
  late List<String> preferences1 = [];

  @override
  void initState() {
    super.initState();
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
          'user_id': preferences2[0],
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

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      loginFailed = false;
    });

    String username = usernameController.text;
    String password = passwordController.text;
    String hashedPassword = sha256.convert(utf8.encode(password)).toString();

    String apiUrl = 'https://educationmobileapp.000webhostapp.com/signin.php';
    if (preferences1[1] == 'true') {
      print('already logged in logout first');
      setState(() {
        isLoading = false;
      });
      mydataList = await fetchData(_latitude, _longitude).timeout(Duration(seconds: 30));
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyWrapperClass(mylist: mydataList)));
      return ;
    } else {
      try {
        var response = await http.post(Uri.parse(apiUrl), body: {
          'username': username,
          'password': hashedPassword,
        });

        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          if (data['status'] == 'success') {
            String userId = data['user_id'];
            print(data['user_id']);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('user_id', userId);
            prefs.setBool('is_logged_in', true);
            mydataList = await fetchData(_latitude, _longitude).timeout(Duration(seconds: 30));

            setState(() {
              isLoggedIn = true;
            });

            Navigator.push(context, MaterialPageRoute(builder: (context) => MyWrapperClass(mylist: mydataList)));
          } else {
            print('Login failed: ${data['message']}');
            setState(() {
              loginFailed = true;
            });
          }
        } else {
          print('Error: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('Exception: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.orangeAccent,
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: isLoading ? null : signIn,
              child: isLoading ? CircularProgressIndicator() : Text('Sign In'),
            ),
            if (loginFailed)
              Column(
                children: [
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: signIn,
                    child: Text('Login Failed, Retry'),
                  ),
                ],
              ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage()));
              },
              child: Text('Back to Homepage'),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
