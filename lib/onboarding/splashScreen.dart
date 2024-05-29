import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wholesense/auth/sign_in.dart';
import 'package:wholesense/onboarding/on_boarding.dart';
import 'package:wholesense/utils/helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Timer _timer;
  @override
  void initState() {
    // TODO: implement initState
    _timer = Timer(const Duration(milliseconds: 6000), () {
      //navigate to next screen
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return const OnboardingScreen();
      }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: SizedBox(
          //controlling pixels and making them adaptive
          width: Helper.getScreenWidth(context),
          height: Helper.getScreenHeight(context),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'WHOLESENSE',
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 40,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )),
              ),
            ],
          )),
    );
  }
}
