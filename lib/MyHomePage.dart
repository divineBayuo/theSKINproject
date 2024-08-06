import 'package:flutter/material.dart';
import 'package:skin_app/PatientData.dart';
import 'package:skin_app/ReviewPatient.dart';
//import 'package:flutter_application_1/login.dart';
import 'dart:async';
import './AddPatient.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Timer _timer;
  late String _currentDateTime;
  
  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    setState(() {
      DateTime now = DateTime.now();
      String formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
      _currentDateTime =
          "${now.day}-${now.month}-${now.year}\n$formattedTime";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0),
      child: Flashcard(
        front: 'Welcome!\n\n$_currentDateTime',
        back: 'This is the Software for Knowledge In NTDs (SKIN) App. This software serves skin neglected tropical diseases information management value chain to improve care at peripheral health facilities. It is designed to bridge the reporting gap between patients, physicians, disease control personnel, and researchers in the treatment of Skin NTDs.' '\n\n\nTo proceed, select an option on the bottom navigation bar.',
      ),
    );
  }
}

String _getCurrentDateTime() {
  DateTime now = DateTime.now();
  String formattedDate =
      "${now.day}/${now.month}/${now.year}\n${now.hour}:${now.minute}";
  return formattedDate;
}

class MyHomePage extends StatefulWidget {
  //const MyHomePage({super.key, Key? key});
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;
  // ignore: unused_field
  final String _token = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    //_loadToken();
  }

/*   Future<void> _loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _token = prefs.getString('token') ?? '';
    });
  } */

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    //var _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      //key: _scaffoldKey,
      /* appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.brown,
      ), */
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [
          Home(),
          AddPatient(),
          /* _token.isNotEmpty ? */ ReviewPatient(/* token: _token */) /* : Container() */,
          PatientData(//AddPatientId: 'example_patient_id',),
          //MongoDBConnectionChecker(),
      )],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Add Patient',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Review',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_array),
            label: 'Data',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.brown[100],
      ),
    );
  }
}

class Flashcard extends StatefulWidget {
  //const Flashcard({super.key});
  final String front;
  final String back;

  const Flashcard({super.key, required this.front, required this.back});

  @override
  State<Flashcard> createState() => _FlashcardState();
}

class _FlashcardState extends State<Flashcard> {
  bool showFront = true;

  void flipCard() {
    setState(() {
      showFront = !showFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: flipCard,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.0),
        child: Card(
          elevation: 4.0,
          child: Container(
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: showFront
                    ? [Colors.blue, Colors.green]
                    : [Colors.amber, Colors.brown],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            height: MediaQuery.of(context).size.height / 1.5,
            width: MediaQuery.of(context).size.width / 3,
            alignment: Alignment.topLeft,
            child: Text(
              showFront ? widget.front : widget.back,
              style: showFront
                  ? const TextStyle(
                      fontSize: 40.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    )
                  : const TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
