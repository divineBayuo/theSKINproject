/* import 'package:flutter/material.dart';
import 'package:skin_app/dbHelper/mongodb.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './SplashScreen.dart';
//import 'package:flutter_application_1/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabase.connect();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(MyApp(token: prefs.getString('token'),));
}

class MyApp extends StatelessWidget {
  final String? token;
  const MyApp({
    required this.token,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splash Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:skin_app/dbHelper/mongodb.dart';
import './SplashScreen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables

  runApp(MaterialApp(
    home: ConnectingScreen(),
  ));
}

class ConnectingScreen extends StatefulWidget {
  //const ConnectingScreen({super.key});

  @override
  _ConnectingScreenState createState() => _ConnectingScreenState();
}

class _ConnectingScreenState extends State<ConnectingScreen> {
  bool _connectionFailed = false;
  String _statusMessage = "Attempting to connect to the database...";
  int _attempts = 0;
  final int _maxAttempts = 3;

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
  }

  Future<void> _connectToDatabase() async {
    bool connected = false;

    while (!connected && _attempts < _maxAttempts) {
      try {
        setState(() {
          _statusMessage =
              "Attempting to connect to the database...\nAttempt: ${_attempts + 1}";
        });
        await MongoDatabase.connect();
        connected = true;
      } catch (e) {
        print('Error connecting to database: $e');
        _attempts++;

        if (_attempts >= _maxAttempts) {
          setState(() {
            _connectionFailed = true;
            _statusMessage =
                "Failed to connect to the database.\nPlease check your internet connection and try again.";
          });
        } else {
          setState(() {
            _statusMessage =
                "Connection attempt ${_attempts} failed. Retrying...";
          });
          await Future.delayed(Duration(seconds: 5)); // Wait before retrying
        }
      }
    }

    if (connected) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _connectionFailed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_statusMessage),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _attempts = 0;
                        _connectionFailed = false;
                        _statusMessage =
                            "Atempting to connect to the database...";
                      });
                      _connectToDatabase();
                    },
                    child: Text('Retry'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(_statusMessage),
                ],
              ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      title: 'SplashScreen',
      home: const SplashScreen(),
    );
  }
}
