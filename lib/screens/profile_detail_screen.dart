import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mathosproject/models/app_user.dart' as AppUser;
import 'package:mathosproject/screens/mode_selection_screen.dart';
import 'package:mathosproject/screens/settings_screen.dart';
import 'package:mathosproject/screens/sign_in_up_screen.dart';
import 'package:mathosproject/screens/stats_screen.dart';
import 'package:mathosproject/widgets/bottom_navigation_bar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:mathosproject/widgets/top_navigation_bar.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mathosproject/utils/connectivity_manager.dart';
import 'package:mathosproject/user_preferences.dart';

class ProfileDetailScreen extends StatefulWidget {
  final AppUser.AppUser profile;

  ProfileDetailScreen({required this.profile});

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late AppUser.AppUser _profile;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    refreshProfile();
  }

  void refreshProfile() async {
    if (await ConnectivityManager().isConnected()) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(_profile.id)
          .get();
      setState(() {
        _profile = AppUser.AppUser.fromJson(snapshot.data() as Map<String, dynamic>);
      });
    } else {
      AppUser.AppUser? localProfile = await UserPreferences.getProfileLocally(_profile.id);
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

  void _changeFlag() async {
    List<String> flags = [
      'assets/france.png',
      'assets/pirate.png',
      'assets/maroc.png',
      'assets/lgbt.png'
    ];
    String? selectedFlag = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changer le drapeau'),
          content: SingleChildScrollView(
            child: ListBody(
              children: flags.map((flag) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(flag);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(flag, width: 50, height: 50),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
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

  void _deleteProfile() async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce compte?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      if (await ConnectivityManager().isConnected()) {
        await UserPreferences.deleteProfileFromFirestore(_profile.id);
      } else {
        await UserPreferences.deleteProfileLocally(_profile.id);
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInUpScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInUpScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _showBadges() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mes Badges',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Wrap(
                  spacing: 10.0,
                  runSpacing: 10.0,
                  alignment: WrapAlignment.center,
                  children: [
                    getBadge(_profile.points ?? 0, 'Chocolat', _profile, getMaxUnlockedLevel()),
                    getBadge(_profile.points ?? 0, 'Bronze', _profile, getMaxUnlockedLevel()),
                    getBadge(_profile.points ?? 0, 'Argent', _profile, getMaxUnlockedLevel()),
                    getBadge(_profile.points ?? 0, 'Or', _profile, getMaxUnlockedLevel()),
                    getBadge(_profile.points ?? 0, 'Diamant', _profile, getMaxUnlockedLevel()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({required String label, required IconData icon, required VoidCallback onPressed, Color color = Colors.blueAccent}) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: screenHeight * 0.03, color: color),
      label: Text(
        label,
        style: TextStyle(fontSize: screenHeight * 0.025, color: color),
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(screenWidth * 0.8, screenHeight * 0.07),
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1, vertical: screenHeight * 0.015),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int currentLevel = getMaxUnlockedLevel();
    String levelDescription = StatsScreen(profile: _profile).getLevelDescription(currentLevel).split(':').first;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double containerSize = screenWidth * 0.4;

    return Scaffold(
      appBar: TopAppBar(
        title: 'Profil',
        showBackButton: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/fond_d_ecran.svg',
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.15),
              colorBlendMode: BlendMode.modulate,
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.13),
                Center(
                  child: Text(
                    _profile.name,
                    style: TextStyle(fontSize: screenHeight * 0.05, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Center(
                  child: GestureDetector(
                    onTap: _changeFlag,
                    child: CircleAvatar(
                      radius: screenHeight * 0.1,
                      backgroundColor: Colors.black.withOpacity(0.9),
                      backgroundImage: AssetImage(_profile.flag),
                      child: null,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: containerSize,
                      height: containerSize,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            'Niveau $currentLevel',
                            style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          SizedBox(height: 8),
                          AutoSizeText(
                            levelDescription,
                            style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: containerSize,
                      height: containerSize,
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        border: Border.all(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            _profile.points.toString(),
                            style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold, color: Colors.black),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            'Points',
                            style: TextStyle(fontSize: screenHeight * 0.025, fontWeight: FontWeight.bold, color: Colors.black),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.03),
                Center(
                  child: _buildButton(
                    label: 'Mes Badges',
                    icon: Icons.badge,
                    onPressed: _showBadges,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: _buildButton(
                    label: 'Supprimer le compte',
                    icon: Icons.delete,
                    onPressed: _deleteProfile,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: _buildButton(
                    label: 'Se déconnecter',
                    icon: Icons.exit_to_app,
                    onPressed: _signOut,
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        profile: _profile,
        onTap: (index) {
          if (index != _selectedIndex) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ModeSelectionScreen(profile: _profile)),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StatsScreen(profile: _profile)),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileDetailScreen(profile: _profile)),
                );
                break;
              case 3:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen(profile: _profile)),
                );
                break;
              default:
                break;
            }
          }
        },
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: screenHeight * 0.03),
        SizedBox(width: screenWidth * 0.02),
        Text(
          '$label: ',
          style: TextStyle(fontSize: screenHeight * 0.03, fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(fontSize: screenHeight * 0.03, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}

Widget getBadge(int points, String badgeName, AppUser.AppUser profile, int currentLevel) {
  Color color;
  IconData icon;
  bool unlocked = false;

  switch (badgeName) {
    case 'Diamant':
      color = Colors.blueAccent;
      icon = Icons.diamond;
      unlocked = points >= 100000;
      break;
    case 'Or':
      color = Colors.amber;
      icon = Icons.star;
      unlocked = points >= 20000;
      break;
    case 'Argent':
      color = Colors.grey;
      icon = Icons.grade;
      unlocked = points >= 10000;
      break;
    case 'Bronze':
      color = Colors.brown;
      icon = Icons.military_tech;
      unlocked = points >= 9999;
      break;
    default:
      color = Colors.brown;
      icon = Icons.cake;
      unlocked = points >= 999;
  }

  return BadgeWidget(
      color: color,
      label: badgeName,
      icon: icon,
      unlocked: unlocked,
      profile: profile,
      currentLevel: currentLevel);
}

class BadgeWidget extends StatefulWidget {
  final Color color;
  final String label;
  final IconData icon;
  final bool unlocked;
  final AppUser.AppUser profile;
  final int currentLevel;

  BadgeWidget({
    required this.color,
    required this.label,
    required this.icon,
    this.unlocked = false,
    required this.profile,
    required this.currentLevel,
  });

  @override
  _BadgeWidgetState createState() => _BadgeWidgetState();
}

class _BadgeWidgetState extends State<BadgeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shareBadgeOnWhatsApp(String badgeName) async {
    String message = '🏆 Compétition lancée ! 🏆\n\n'
        'Je viens de remporter le badge $badgeName sur mathos !\n\n'
        'Nom du Profil : ${widget.profile.name}\n'
        'Niveau Actuel : ${widget.currentLevel}\n'
        'Total de Points : ${widget.profile.points}\n\n'
        'Téléchargez mathos et essayez de battre mon score !';
    Share.share(message);
  }

  @override
  Widget build(BuildContext context) {
    return widget.unlocked
        ? FadeTransition(
      opacity: _animation,
      child: _buildBadgeContent(),
    )
        : _buildBadgeContent();
  }

  Widget _buildBadgeContent() {
    return Opacity(
      opacity: widget.unlocked ? 1.0 : 0.3,
      child: Container(
        width: 100,
        height: 220,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: widget.color.withOpacity(0.2),
          border: Border.all(color: widget.color),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, color: widget.color, size: 40),
            SizedBox(height: 10.0),
            Text(widget.label, style: TextStyle(color: widget.color, fontWeight: FontWeight.bold)),
            SizedBox(height: 10.0),
            if (widget.unlocked)
              IconButton(
                icon: Icon(Icons.share, color: widget.color),
                onPressed: () => _shareBadgeOnWhatsApp(widget.label),
              ),
          ],
        ),
      ),
    );
  }
}
