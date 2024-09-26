import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mathosproject/models/app_user.dart' as AppUserModel;
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/settings_screen.dart';
import 'package:mathosproject/screens/sign_in_up_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/widgets/PacManButton.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/user_preferences.dart';
import 'package:mathosproject/dialog_manager.dart';
import 'package:flutter/services.dart'; // Pour rootBundle
import 'dart:convert'; // Pour json.decode()
import 'package:country_flags/country_flags.dart'; // Pour afficher les drapeaux





class ProfileDetailScreen extends StatefulWidget {
  final AppUserModel.AppUser profile;

  ProfileDetailScreen({required this.profile});

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late AppUserModel.AppUser _profile;
  int _selectedIndex = 2;
  List<Map<String, String>> _flags = []; // Liste pour stocker les drapeaux à partir du fichier JSON
  List<Map<String, String>> _filteredFlags = []; // Liste filtrée pour la recherche de drapeaux

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    refreshProfile();
    _loadFlags();
  }



  void refreshProfile() async {
    if (await ConnectivityManager().isConnected()) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_profile.id)
          .get();
      setState(() {
        _profile = AppUserModel.AppUser.fromJson(snapshot.data() as Map<String, dynamic>);
      });
    } else {
      AppUserModel.AppUser? localProfile = await UserPreferences.getProfileLocally(_profile.id);
      if (localProfile != null) {
        setState(() {
          _profile = localProfile;
        });
      }
    }
  }


  int getMaxUnlockedLevel() {
    for (int level = 10; level >= 1; level--) {
      if (_profile.progression[level]!.values
          .every((element) => element['validation'] == 1)) {
        return level;
      }
    }
    return 0;
  }

  String getCurrentBadge(int points) {
    if (points >= 100000) return 'Diamant';
    if (points >= 20000) return 'Or';
    if (points >= 10000) return 'Argent';
    if (points >= 9999) return 'Bronze';
    return 'Chocolat';
  }




  void _changeFlag() async {
    if (_flags.isEmpty) {
      await _loadFlags();
    }

    List<Map<String, String>> filteredFlags = List.from(_flags);
    TextEditingController searchController = TextEditingController();

    String? selectedFlag = await DialogManager.showCustomDialogWithWidget<String>(
      context: context,
      title: 'Changer le drapeau',
      contentWidget: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            width: double.maxFinite,
            height: 400, // Hauteur fixe pour le dialogue
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un pays',
                      hintStyle: TextStyle(color: Colors.white54, fontFamily: 'PixelFont'),
                      prefixIcon: Icon(Icons.search, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredFlags = _flags
                            .where((flag) => flag['name']!.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredFlags.length,
                    itemBuilder: (context, index) {
                      final flag = filteredFlags[index];
                      return ListTile(
                        leading: CountryFlag.fromCountryCode(
                          flag['code']!,
                          height: 40,
                          width: 60,
                        ),
                        title: Text(
                          flag['name']!,
                          style: TextStyle(color: Colors.white, fontFamily: 'PixelFont'),
                        ),
                        onTap: () {
                          Navigator.of(context).pop(flag['code']);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      confirmText: '',
      cancelText: 'Annuler',
      onConfirm: () {},
    );

    if (selectedFlag != null) {
      setState(() {
        _profile.flag = selectedFlag;
      });

      if (await ConnectivityManager().isConnected()) {
        await UserPreferences.updateProfileInFirestore(_profile);
      } else {
        await UserPreferences.saveProfile(_profile);
      }
    }
  }

  Future<void> _loadFlags() async {
    String jsonString = await rootBundle.loadString('assets/flags.json');
    List<dynamic> jsonResponse = json.decode(jsonString);

    setState(() {
      _flags = jsonResponse.map((flag) => {
        'name': flag['name'].toString(),
        'code': flag['code'].toString(),
      }).toList();
    });
  }








  void _showConfirmationDialog(String action, VoidCallback onConfirm) {
    DialogManager.showCustomDialog(
      context: context,
      title: 'Confirmation',  // Titre du dialogue
      content: action == 'delete'
          ? 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.'
          : 'Êtes-vous sûr de vouloir vous déconnecter ?',  // Message dynamique
      confirmText: action == 'delete' ? 'Supprimer' : 'Déconnecter',  // Texte du bouton de confirmation
      cancelText: 'Annuler',  // Texte du bouton d'annulation
      onConfirm: onConfirm,  // Action à exécuter après confirmation
    );
  }


  void _deleteProfile() {
    _showConfirmationDialog('delete', () async {
      try {
        bool isConnected = await ConnectivityManager().isConnected();
        if (isConnected) {
          await UserPreferences.deleteProfileFromFirestore(widget.profile.id);
          // Supprimez également l'utilisateur de Firebase Auth si nécessaire
          await FirebaseAuth.instance.currentUser?.delete();
        } else {
          // Si hors ligne, sauvegardez localement l'intention de suppression
          await UserPreferences.saveProfileLocally(widget.profile);
          // Note: Vous devrez implémenter une logique pour traiter cette suppression
          // lorsque la connexion sera rétablie, peut-être dans une méthode de synchronisation
        }

        // Déconnectez l'utilisateur après la suppression
        await FirebaseAuth.instance.signOut();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInUpScreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        // Gérez les erreurs, par exemple en affichant un message à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue lors de la suppression du compte.')),
        );
      }
    });
  }

  void _signOut() {
    _showConfirmationDialog('signout', () async {
      try {
        await FirebaseAuth.instance.signOut();

        // Si vous avez des données locales à effacer lors de la déconnexion, faites-le ici
        // Par exemple : await UserPreferences.clearLocalUserData();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInUpScreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        // Gérez les erreurs, par exemple en affichant un message à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur est survenue lors de la déconnexion.')),
        );
      }
    });
  }

  void _shareBadgeOnWhatsApp(String badgeName) async {
    String message = '🏆 Compétition lancée ! 🏆\n\n'
        'Je viens de remporter le badge $badgeName sur mathos !\n\n'
        'Nom du Profil : ${_profile.name}\n'
        'Niveau Actuel : ${getMaxUnlockedLevel()}\n'
        'Total de Points : ${_profile.points}\n\n'
        'Téléchargez mathos et essayez de battre mon score !';
    Share.share(message);
  }



  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: _profile)), // Passez 'profile'
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StatsScreen(profile: _profile)), // Passez 'profile'
        );
        break;
      case 2:
      // Déjà sur l'écran du profil
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SettingsScreen(profile: _profile)), // Passez 'profile'
        );
        break;
    }
  }






  @override
  Widget build(BuildContext context) {
    int currentLevel = getMaxUnlockedLevel();
    String currentBadge = getCurrentBadge(_profile.points);

    return Scaffold(
      appBar: TopAppBar(title: 'Profil', showBackButton: true),
      body: Container(
        color: Color(0xFF564560), // Fond violet rétro
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              double screenHeight = constraints.maxHeight;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: screenHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileHeader(screenWidth),
                      _buildRetroGameStats(currentLevel, currentBadge, screenWidth, screenHeight),
                      _buildActionButtons(screenWidth),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        profile: _profile,
        onTap: _navigateToScreen,
      ),
    );
  }

  Widget _buildRetroGameStats(int currentLevel, String currentBadge, double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.3,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow, width: 4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPixelatedTitle('STATISTIQUES DU JOUEUR'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPixelatedStatBox('PTS', '${_profile.points}', screenWidth * 0.25),
              _buildPixelatedStatBox('NIV', '$currentLevel', screenWidth * 0.25),
              _buildPixelatedBadge('BADGE', currentBadge, screenWidth * 0.25),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildPixelatedTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'PixelFont',
        fontSize: 24,
        color: Colors.white,
        shadows: [
          Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }


  Widget _buildPixelatedStatBox(String label, String value, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'PixelFont',
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPixelatedBadge(String label, String badgeName, double size) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(badgeName),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 5),
                Icon(
                  _getBadgeIcon(badgeName),
                  color: _getBadgeColor(badgeName),
                ),
                Text(
                  badgeName,
                  style: TextStyle(
                    fontFamily: 'PixelFont',
                    color: _getBadgeColor(badgeName),
                    shadows: [
                      Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBadgeColor(String badgeName) {
    switch (badgeName) {
      case 'Diamant':
        return Colors.white;
      case 'Or':
        return Colors.yellow;
      case 'Argent':
        return Colors.yellow;
      case 'Bronze':
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  void _showBadgeDetails(String currentBadge) {
    DialogManager.showCustomDialogWithWidget(
      context: context,
      title: 'Vos Badges',
      contentWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBadgeRow('Diamant', _profile.points >= 100000),
          _buildBadgeRow('Or', _profile.points >= 20000),
          _buildBadgeRow('Argent', _profile.points >= 10000),
          _buildBadgeRow('Bronze', _profile.points >= 9999),
          _buildBadgeRow('Chocolat', _profile.points >= 999),
        ],
      ),
      confirmText: 'Partager',  // Bouton "Partager"
      cancelText: 'Fermer',     // Bouton "Fermer"
      onConfirm: () {
        Navigator.of(context).pop();
        _shareBadgeOnWhatsApp(currentBadge);  // Partage du badge
      },
    );
  }


  Widget _buildBadgeRow(String badgeName, bool isUnlocked) {
    return Row(
      children: [
        Icon(
          _getBadgeIcon(badgeName),
          color: isUnlocked ? _getBadgeColor(badgeName) : Colors.grey,
        ),
        SizedBox(width: 10),
        Text(
          badgeName,
          style: TextStyle(
            color: isUnlocked ? Colors.black : Colors.grey,
            fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }



  Widget _buildProfileHeader(double screenWidth) {
    return Container(
      width: screenWidth ,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _changeFlag,
            child: Container(
              width: screenWidth * 0.3,
              height: screenWidth * 0.3,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.yellow, width: 4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: CountryFlag.fromCountryCode(
                _profile.flag, // Utilise le code ISO du drapeau
                height: 100,
                width: 100,
              ),
            ),
          ),
          SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _profile.name,
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                shadows: [
                  Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
                ],
                fontFamily: 'PixelFont',
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }








  IconData _getBadgeIcon(String badgeName) {
    switch (badgeName) {
      case 'Diamant':
        return Icons.diamond;
      case 'Or':
        return Icons.star;
      case 'Argent':
        return Icons.grade;
      case 'Bronze':
        return Icons.military_tech;
      default:
        return Icons.cake;
    }
  }




  Widget _buildActionButtons(double screenWidth) {
    return Container(
      width: screenWidth * 0.9,
      child: Column(
        children: [
          PacManButton(
            text: 'Supprimer Compte',
            onPressed: _deleteProfile,
            isLoading: false,
          ),
          SizedBox(height: 8),
          PacManButton(
            text: 'Se Déconnecter',
            onPressed: _signOut,
            isLoading: false,
          ),
        ],
      ),
    );
  }

}