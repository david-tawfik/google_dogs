import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import '../../utilities/screen_size_handler.dart';

class RedditLoadingIndicator extends StatelessWidget {
  const RedditLoadingIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ScreenSizeHandler.screenHeight * 0.13,
      height: ScreenSizeHandler.screenHeight * 0.13,
      child: const LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader,
        colors: [Colors.red,Colors.orange, Colors.yellow, Colors.green, Colors.blue,],
        strokeWidth: 2,
      ),
    );
  }
}
