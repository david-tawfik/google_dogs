import 'package:flutter/material.dart';

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
              onPressed: (){},
                icon: Icon(Icons.menu),
              ),
            Text('Dogs'),
          ],
        ),
      ),
      body: Center(
        child: Text('Document Manager Screen'),
      ),
    );
  }
}