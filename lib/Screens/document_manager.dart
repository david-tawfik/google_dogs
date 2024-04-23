import 'dart:html';
import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_dogs/constants.dart';
import 'package:google_dogs/screens/text_editor_page.dart';
import 'package:google_dogs/utilities/screen_size_handler.dart';
import 'package:google_dogs/components/document.dart';

class DocumentManagerScreen extends StatefulWidget {
  static const String id = 'document_manager_screen';
  DocumentManagerScreen({super.key});
  @override
  State<DocumentManagerScreen> createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  final List<String> documents = [
    'Document 1',
    'Document 2',
    'Document 3',
    'Document 4',
    'Document 5',
    'Document 6',
    'Document 7',
    'Document 8',
    'Document 9',
    'Document 10',
  ];
  void _editDocumentName(String newName, int index) {
    setState(() {
      documents[index] = newName;
    });
  }

  void _removeDocument(int index) {
    setState(() {
      documents.removeAt(index);
    });
  }

  void _showRenameDialog(BuildContext context, String docName, int index) {
    final TextEditingController _controller = TextEditingController();
    _controller.text = docName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename'),
          content: IntrinsicHeight(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Please enter a new name for the item:',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextField(
                  controller: _controller,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                _editDocumentName(_controller.text, index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Document'),
          content: Text('Are you sure you want to delete this document?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                _removeDocument(index);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.menu),
                ),
                const Image(
                  image: AssetImage('assets/images/logo_white.png'),
                  height: 50,
                ),
                const Text('Dogs'),
                const Spacer(),
                const Icon(Icons.apps_rounded),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 17,
                    child: Text('P'),
                  ),
                )
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenSizeHandler.screenWidth * 0.12),
            child: LayoutBuilder(builder: (context, constraints) {
              return GridView.builder(
                itemCount: documents.length+1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (ScreenSizeHandler.screenWidth *
                                  0.9 ~/
                                  kDocumentWidth) -
                              2 >
                          0
                      ? (ScreenSizeHandler.screenWidth * 0.9 ~/ kDocumentWidth) -
                          2
                      : 1,
                  mainAxisExtent: kDocumentHeight + 62,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, TextEditorPage.id);
                        setState(() {
                          documents.insert(0, "Untitled Document");
                        });
                      },
                      child: const SizedBox(
                        height: kDocumentHeight,
                        width: kDocumentWidth,
                        child: Image(
                          image: AssetImage(
                            "assets/images/AddDocument.png",
                          ),
                        ),
                      ),
                    );
                  }
                  return Expanded(
                      child: Document(
                    docName: documents[index-1],
                    index: index-1,
                    showRenameDialog: _showRenameDialog,
                    showDeleteDialog: _showDeleteDialog,
                  ));
                },
              );
            }),
          )),
    );
  }
}
