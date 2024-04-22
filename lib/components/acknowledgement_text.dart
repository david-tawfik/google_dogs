import 'package:flutter/material.dart';
import '/constants.dart';
import '../../utilities/screen_size_handler.dart';

class AcknowledgementText extends StatelessWidget {
  const AcknowledgementText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenSizeHandler.screenWidth * kAcknowledgeTextWidthRatio,
          vertical: ScreenSizeHandler.screenHeight * kAcknowledgeTextHeightRatio),
      child: Text(
        'By continuing, you agree to our User Agreement\nand acknowlege that you understand the Privacy Policy',
        style: TextStyle(
          fontSize: ScreenSizeHandler.smaller * kAcknowledgeTextSmallerFontRatio*0.7,
          color: kHintTextColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
