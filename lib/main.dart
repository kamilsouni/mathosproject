import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/join_or_create_competition_screen.dart';
import 'package:mathosproject/sound_manager.dart';
import 'package:mathosproject/utils/notification_service.dart';
import 'package:mathosproject/screens/home_screen.dart';
import 'firebase_options.dart';
import 'screens/competition_screen.dart';

// Fonction d'initialisation optimisée
Future<void> initializeApp() async {
  try {
    // Initialiser les services critiques en parallèle
    await Future.wait([
      Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      Hive.initFlutter(),
      SoundManager.initialize(),
      NotificationService.initialize(),
    ]);
    debugPrint("Services critiques initialisés avec succès");
  } catch (e) {
    debugPrint("Erreur lors de l'initialisation des services: $e");
  }
}

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Configurer la couleur de la barre de navigation Android
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Color(0xFF564560), // Couleur violette
        systemNavigationBarIconBrightness: Brightness.light, // Icônes claires
        statusBarColor: Color(0xFF564560), // Couleur de la barre d'état
        statusBarIconBrightness: Brightness.light, // Icônes de la barre d'état claires
      ),
    );

    runApp(
      MaterialApp(
        home: FutureBuilder(
          future: initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Mathos();
            }
            // Écran de chargement stylisé
            return Material(
              child: Container(
                color: Color(0xFF564560),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logov2.png',
                        width: 200,
                      ),
                      SizedBox(height: 20),
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }, (error, stack) {
    debugPrint("Erreur non gérée: $error");
    debugPrint("Stack trace: $stack");
  });
}

class Mathos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mathos',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey,
          ),
          bodyLarge: TextStyle(
            fontSize: 16.0,
            fontFamily: 'Roboto',
            color: Colors.black87,
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueGrey,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey).copyWith(
          primary: Color(0xff000000),
          secondary: Color(0xFF1abc9c),
          error: Color(0xFFf1c40f),
        ),
      ),
      home: HomeScreen(),
      routes: {
        '/join_or_create_competition': (context) {
          final AppUser profile = ModalRoute.of(context)!.settings.arguments as AppUser;
          return JoinOrCreateCompetitionScreen(profile: profile);
        },
        '/competition': (context) {
          final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return CompetitionScreen(
            profile: args['profile'] as AppUser,
            competitionId: args['competitionId'] as String,
          );
        },
      },
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  ErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Une erreur s\'est produite lors de l\'initialisation: $error'),
        ),
      ),
    );
  }
}