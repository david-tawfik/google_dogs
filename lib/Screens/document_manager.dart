import 'dart:html';
import 'dart:ui_web';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_dogs/constants.dart';
import 'package:google_dogs/screens/text_editor_page.dart';
import 'package:google_dogs/services/api_service.dart';
import 'package:google_dogs/utilities/screen_size_handler.dart';
import 'package:google_dogs/components/document.dart';
import 'package:google_dogs/utilities/show_snack_bar.dart';
import 'dart:convert';

class DocumentManagerScreen extends StatefulWidget {
  static const String id = 'document_manager_screen';
  DocumentManagerScreen({super.key});
  @override
  State<DocumentManagerScreen> createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  ApiService apiService = ApiService();
  List<String> documents = [
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
  bool firstTime = true;
  String userId = '';
  void _editDocumentName(String newName, int index) {
    setState(() {
      documents[index] = newName;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (firstTime) {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.arguments != null) {
        final Map<String, dynamic> args = route.settings.arguments as Map<String, dynamic>;
        userId = args['userId'].toString();
        getAllUserDocuments();
        firstTime = false;
      }
    }
  }

  Future<void> getAllUserDocuments() async {
    print('getAllUserDocuments $userId');
    setState(() {
      documents.clear();
    });
    var response = await apiService.getAllUserDocuments({'userId': userId});
    print(response.statusCode);
    if (response.statusCode == 200) {
      var documentNames = jsonDecode(response.body);
      for (var document in documentNames) {
        documentNames.add(document['title']);
      }
      setState(() {
        documents = documentNames;
      });
    } else {
      if (mounted) {
        showSnackBar('Failed to get documents', context);
      }
    }
  }

  Future<void> createDocument() async {
    print('createDocument $userId');
    var response = await apiService.createDocument({'userId': userId});
    print(response);
    if (response.statusCode == 200) {
      var document = jsonDecode(response.body);
      setState(() {
        documents.insert(0, document['title']);
        Navigator.pushNamed(context, TextEditorPage.id,
            arguments: {"documentId": document['id']});
      });
    } else {
      showSnackBar('Failed to create document', context);
    }
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
                itemCount: documents.length + 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      (ScreenSizeHandler.screenWidth * 0.9 ~/ kDocumentWidth) -
                                  2 >
                              7
                          ? 7
                          : (ScreenSizeHandler.screenWidth *
                                          0.9 ~/
                                          kDocumentWidth) -
                                      2 >
                                  0
                              ? (ScreenSizeHandler.screenWidth *
                                      0.9 ~/
                                      kDocumentWidth) -
                                  2
                              : 1,
                  mainAxisExtent: kDocumentHeight + 62,
                ),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        createDocument();
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
                  return Document(
                    docName: documents[index - 1],
                    index: index - 1,
                    showRenameDialog: _showRenameDialog,
                    showDeleteDialog: _showDeleteDialog,
                  );
                },
              );
            }),
          )),
    );
  }
}
