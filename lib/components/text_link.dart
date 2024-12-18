import 'package:flutter/material.dart';
import '../constants.dart';
import '../../utilities/screen_size_handler.dart';

class TextLink extends StatelessWidget {
  const TextLink({
    Key? key,
    required this.onTap,
    required this.text, 
    required this.fontSizeRatio,
  }) : super(key: key);

  final VoidCallback onTap;
  final String text; 
  final double? fontSizeRatio;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(left: ScreenSizeHandler.smaller * kTextLinkPaddingRatio),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSizeRatio,
            color: Colors.deepPurple,
            decoration: TextDecoration.underline,
            decorationColor: Colors.deepPurple,
            
          ),
        ),
      ),
    );
  }
}
