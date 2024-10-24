import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/screens/home_screen.dart';
import 'package:mathosproject/screens/join_or_create_competition_screen.dart';
import 'package:mathosproject/sound_manager.dart';
import 'package:mathosproject/utils/notification_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint("WidgetsFlutterBinding initialized");

    try {
      await Firebase.initializeApp();
      debugPrint("Firebase initialized");
    } catch (e) {
      debugPrint("Firebase initialization error: $e");
    }

    try {
      await Hive.initFlutter();
      debugPrint("Hive initialized");
    } catch (e) {
      debugPrint("Hive initialization error: $e");
    }

    try {
      await SoundManager.initialize();
      debugPrint("SoundManager initialized");
    } catch (e) {
      debugPrint("SoundManager initialization error: $e");
    }

    try {
      await NotificationService.initialize();
      debugPrint("NotificationService initialized");
    } catch (e) {
      debugPrint("NotificationService initialization error: $e");
    }

    runApp(Mathos());
  }, (error, stack) {
    debugPrint("Uncaught error: $error");
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
              color: Colors.blueGrey),
          bodyLarge: TextStyle(
              fontSize: 16.0, fontFamily: 'Roboto', color: Colors.black87),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueGrey,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
            .copyWith(
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
