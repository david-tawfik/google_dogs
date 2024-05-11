import 'package:flutter/material.dart';
import 'package:google_dogs/constants.dart';

import 'screen_size_handler.dart';

void showSnackBar(String snackBarText, BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Center(
          child: Text(
            snackBarText,
            style: TextStyle(
                color: Colors.black,
                fontSize: ScreenSizeHandler.bigger * 0.01,
                fontWeight: FontWeight.w500),
          ),
        ),
        padding: EdgeInsets.symmetric(
            vertical: ScreenSizeHandler.screenHeight * 0.02),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          left: ScreenSizeHandler.screenWidth * kButtonWidthRatio * 8,
          right: ScreenSizeHandler.screenWidth * kButtonWidthRatio * 8,
          bottom: ScreenSizeHandler.screenHeight * 0.05,
        ),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),
    );
  });
}
