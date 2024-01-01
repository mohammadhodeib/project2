import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:geolocatortest/login.dart';
import 'package:http/http.dart' as http;

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signUp() async {
    setState(() {
      isLoading = true;
    });

    // Get username and password from text controllers
    String username = usernameController.text;
    String password = passwordController.text;

    // TODO: Replace the following with your actual sign-up logic
    String apiUrl = 'https://educationmobileapp.000webhostapp.com/singup.php';
    try {
      var response = await http.post(Uri.parse(apiUrl), body: {
        'username': username,
        'password': sha256.convert(utf8.encode(password)).toString(),
      // Send the plain password to the server
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          print('${response.body}');
          // Redirect the user to the sign-in page after successful sign-up
          Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
// Close the sign-up page
        } else {
          // Handle failed sign-up (show error message, etc.)
          print('Sign Up failed: ${data['message']}');
        }
      } else {
        // Handle network errors, server issues, etc.
        print('Error: ${response.reasonPhrase}');
      }
    } catch (e) {
      // Handle exceptions, e.g., network issues
      print('Exception: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.orangeAccent,
      appBar: AppBar(title: Text('Sign Up')),
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
              onPressed: isLoading ? null : signUp,
              child: isLoading
                  ? CircularProgressIndicator() // Show a loading indicator
                  : Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
