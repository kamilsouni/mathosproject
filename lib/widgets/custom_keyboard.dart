import 'package:flutter/material.dart';

class CustomKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onDelete;

  CustomKeyboard({
    required this.controller,
    required this.onSubmit,
    required this.onDelete,
  });

  Widget _buildKey(String label) {
    return Expanded(
      child: InkWell(
        onTap: () {
          controller.text += label;
        },
        child: Container(
          margin: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZeroKey(String label) {
    return Expanded(
      flex: 3,
      child: InkWell(
        onTap: () {
          controller.text += label;
        },
        child: Container(
          margin: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalActionKey(
      String label, VoidCallback onTap, Color color) {
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(1.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.grey[300],
      child: Row(
        children: [
          // Partie gauche avec les chiffres
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildKey('1'),
                      _buildKey('2'),
                      _buildKey('3'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildKey('4'),
                      _buildKey('5'),
                      _buildKey('6'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildKey('7'),
                      _buildKey('8'),
                      _buildKey('9'),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildZeroKey('0'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Partie droite avec Corriger et Valider
          Expanded(
            flex: 1,
            child: Center(
                child: Column(
              children: [
                _buildVerticalActionKey('Corriger', onDelete, Colors.orange),
                _buildVerticalActionKey('Passer', onSubmit, Colors.red),
              ],
            )),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: CustomKeyboard(
          controller: TextEditingController(),
          onSubmit: () => print("Submitted"),
          onDelete: () => print("Deleted"),
        ),
      ),
    ),
  ));
}
