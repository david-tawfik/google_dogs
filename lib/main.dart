import 'dart:html';

import 'package:flutter/material.dart';
import 'package:google_dogs/Screens/document_manager.dart';
import 'package:google_dogs/utilities/screen_size_handler.dart';

void main() {
  runApp(const GoogleDogs());
}

class GoogleDogs extends StatelessWidget {
  const GoogleDogs({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    ScreenSizeHandler.initialize(
        MediaQuery.of(context).size.width, MediaQuery.of(context).size.height);
    return MaterialApp(
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      routes: {
        DocumentManagerScreen.id: (context) => const DocumentManagerScreen(),
      },
      initialRoute: DocumentManagerScreen.id,
    );
  }
}
