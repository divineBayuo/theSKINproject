import 'package:flutter/material.dart';
import 'package:skin_app/MyHomePage.dart';
import 'package:skin_app/registration.dart';
import 'package:http/http.dart' as http;
import 'package:skin_app/config.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailaddresscontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  bool _isNotValidate = false;
  late SharedPreferences prefs;
  bool _isLoading = false;
  //String? _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //prefs = ;
    initSharedPref();
  }

  Future<void> initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
     // _token = prefs.getString('token');
    });
  }

  // Use _token variable safely
  Future<void> loginUser() async {
    setState(() {
      _isNotValidate = false;
    });

    if (emailaddresscontroller.text.isEmpty ||
        passwordcontroller.text.isEmpty) {
      setState(() {
        _isNotValidate = true;
      });
      return;
    }

    var regBody = {
      "email": emailaddresscontroller.text,
      "password": passwordcontroller.text
    };

    try {
      setState(() {
        _isLoading = true;
      });

      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print(jsonResponse['status']);

        if (jsonResponse['status']) {
          var myToken = jsonResponse['token'];
          await prefs.setString('token', myToken);
          setState(() {
          //  _token = myToken;
          });

          Future.delayed(const Duration(milliseconds: 200), () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const MyHomePage()));
          });
        } else {
          _showErrorDialog('Invalid credentials. Please try again.');
        }
      } else {
        _showErrorDialog('Server error. Please try again later.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
          'An error occured. Please check your network and try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  /* if (emailaddresscontroller.text.isNotEmpty &&
        passwordcontroller.text.isNotEmpty) {
      var regBody = {
        "email": emailaddresscontroller.text,
        "password": passwordcontroller.text
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ReviewPatient(token: myToken)));
      } else {
        print('Something went wrong.');
      }
      //Navigator(MaterialPageRoute(builder: context, loginUser()));
    }
  } */

  void onLoginPressed() async {
    await initSharedPref();
    loginUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Log In',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()));
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          //alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.person_2_sharp,
                size: 150.00,
                color: Colors.green,
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: emailaddresscontroller,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                        color: _isNotValidate ? Colors.red : Colors.grey,
                        width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                readOnly: false,
                controller: passwordcontroller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    borderSide: BorderSide(
                      color: _isNotValidate ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Log In'),
                    ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Registration()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 1, 35, 63),
                  foregroundColor: Colors.white,
                ),
                child: const Text('New? Register here'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  "For Authorized Personnel Only",
                  style: TextStyle(
                      fontSize: 16.0,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
