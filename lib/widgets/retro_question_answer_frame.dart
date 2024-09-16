import 'package:flutter/material.dart';
import 'dart:async';

class RetroQuestionAnswerFrame extends StatefulWidget {
  final String question;
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmitted;

  RetroQuestionAnswerFrame({
    required this.question,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  _RetroQuestionAnswerFrameState createState() => _RetroQuestionAnswerFrameState();
}

class _RetroQuestionAnswerFrameState extends State<RetroQuestionAnswerFrame> {
  bool _showCursor = true;
  late Timer _cursorTimer;

  @override
  void initState() {
    super.initState();
    _cursorTimer = Timer.periodic(Duration(milliseconds: 500), (_) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  @override
  void dispose() {
    _cursorTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Color(0xFFFFFF00),
          width: 4,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                widget.question,
                style: TextStyle(
                  fontFamily: 'digital',
                  fontSize: 36,
                  color: Color(0xFFFFFF00),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Container(
            height: 2,
            color: Color(0xFFFFFF00),
          ),
          Expanded(
            flex: 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  keyboardType: TextInputType.none,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontFamily: 'digital',
                    color: Color(0xFFFFFF00),
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  onSubmitted: widget.onSubmitted,
                ),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.45 - (widget.controller.text.length * 12),
                  child: _showCursor
                      ? Container(
                    height: 40,
                    width: 3,
                    color: Color(0xFFFFFF00),
                  )
                      : SizedBox(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}