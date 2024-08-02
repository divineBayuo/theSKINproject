import 'package:flutter/material.dart';
import 'package:skin_app/MyHomePage.dart';
//import './MyHomePage.dart';
//import 'package:flutter_application_1/login.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    //_navigateToNextScreen();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
        parent: _controller, curve: Curves.fastEaseInToSlowEaseOut);

    _controller.forward().then((_) {
      _navigateToNextScreen();
    });
  }

/*   void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => const Login(),
      ),
    );
  } */

    void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => const MyHomePage(),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    Color logobackgroundColor = const Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
        backgroundColor: logobackgroundColor,
        body: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Center(
              child: Opacity(opacity: _animation.value, child: child),
            );
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.width / 1.2,
            width: MediaQuery.of(context).size.width / 1.2,
            child: Image.asset('assets/skinlogo.png'),
          ),
        ));
  }
}
