import 'dart:ui_web';

import 'package:flutter/material.dart';
import 'package:google_dogs/constants.dart';
import 'package:google_dogs/utilities/screen_size_handler.dart';

class DocumentManagerScreen extends StatelessWidget {
  static const String id = 'document_manager_screen';
  const DocumentManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.menu),
            ),
            Image(
              image: const AssetImage('assets/images/logo_white.png'),
              height: 50,
            ),
            Text('Dogs'),
            Spacer(),
            Icon(Icons.apps_rounded),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: CircleAvatar(
                backgroundColor: Colors.deepPurple,
                radius: 17,
                child: Text('P'),
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 300 * 0.6,
                width: 220 * 0.6,
                color: Colors.white,
              ),
              Container(
                color: Colors.grey[600],
                width: 220 * 0.6,
                child: Document(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Document extends StatelessWidget {
  const Document({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          child: Text('QUIZ'),
          alignment: Alignment.centerLeft,
        ),
        Row(
          children: [
            Image(
              image: const AssetImage('assets/images/logo_white.png'),
              height: 30,
            ),
            Icon(Icons.people_alt_outlined),
            Spacer(),
            Icon(Icons.more_vert)
          ],
        )
      ],
    );
  }
}
