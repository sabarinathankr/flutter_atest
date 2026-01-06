import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'landingpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700, // 🌤 Sky Blue
      body: SafeArea(

        child: SizedBox(
          width: double.infinity, // ✅ full width
          child: Column(
            children: [
              const Spacer(),

              // 🌟 App Name (Center)
              AnimatedTextKit(
                isRepeatingAnimation: false,
                animatedTexts: [
                  TypewriterAnimatedText(
                    AppLocalizations.of(context).translate('app_name'),
                    textStyle: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                    speed: const Duration(milliseconds: 80), // smooth
                    cursor: '', // ✅ THIS REMOVES THE UNDERSCORE
                  ),
                ],
                onFinished: () {
                  // ✅ callback after animation completes
                  print("Animation completed");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LandingPage()),
                  );
                },
              ),


              const Spacer(),

              // ⚡ Powered By (Bottom)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  AppLocalizations.of(context).translate('brand_name'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        )

      ),
    );
  }
}
