import 'dart:convert';
import 'package:skin_app/login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:skin_app/config.dart';
import 'package:skin_app/MyHomePage.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  TextEditingController emailaddresscontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool _isNotValidate = false;

  void registerUser() async {
    if (emailaddresscontroller.text.isNotEmpty &&
        passwordcontroller.text.isNotEmpty) {
      var regBody = {
        "email": emailaddresscontroller.text,
        "password": passwordcontroller.text
      };

      var response = await http.post(Uri.parse(registration),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(regBody));

      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse['status']);

      if (jsonResponse['status']) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Login()));
      } else {
        print('');
      }
      //Navigator(MaterialPageRoute(builder: context, loginUser()));
    } else {
      setState(() {
        _isNotValidate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register User',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 1, 35, 63),
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
                color: Color.fromARGB(255, 1, 35, 63),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                readOnly: false,
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
                obscureText: true,
                controller: passwordcontroller,
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
              ElevatedButton(
                onPressed: () {
                  registerUser();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 1, 35, 63),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Register'),
              ),
              const SizedBox(height: 10.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Login()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Log In Instead'),
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
