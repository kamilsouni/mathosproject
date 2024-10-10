import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mathosproject/screens/home_screen.dart';
import 'package:mathosproject/screens/join_or_create_competition_screen.dart';
import 'package:mathosproject/screens/competition_screen.dart';
import 'package:mathosproject/models/app_user.dart';
import 'package:mathosproject/sound_manager.dart';
import 'package:mathosproject/utils/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await SoundManager.initialize();

  // Initialisation des notifications locales
  await NotificationService.initialize();
  await NotificationService.scheduleDailyNotification();

  runApp(Mathos());
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
