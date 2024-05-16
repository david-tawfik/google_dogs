import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_dogs/services/api_service.dart';
import 'package:google_dogs/constants.dart';
import 'package:google_dogs/screens/text_editor_page.dart';
import 'package:google_dogs/utilities/screen_size_handler.dart';
import 'package:google_dogs/components/document.dart';
import 'package:google_dogs/utilities/show_snack_bar.dart';
import 'package:google_dogs/utilities/user_id.dart';
import 'dart:convert';
import 'package:google_dogs/components/reddit_loading_indicator.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class DocumentManagerScreen extends StatefulWidget {
  static const String id = '/document_manager';
  DocumentManagerScreen({super.key});
  @override
  State<DocumentManagerScreen> createState() => _DocumentManagerScreenState();
}

class _DocumentManagerScreenState extends State<DocumentManagerScreen> {
  ApiService apiService = ApiService();
  String userInitial = 'u';
  String userId = '';
  List<DocumentStruct> documents = [];
  bool isLoading = false;

  Future<void> getAllUserDocuments() async {
    setState(() {
      isLoading = true;
    
    });
    ApiService apiService = ApiService();
    var response = await apiService.getAllUserDocuments({'userId': userId});
    List<DocumentStruct> docs = [];
    if (response.statusCode == 200) {
      var recievedDocuments = jsonDecode(response.body)['documents'];
      for (var document in recievedDocuments) {
        docs.add(DocumentStruct(
          docId: document['id'].toString(),
          docName: document['title'],
          userPermission: document['role'],
        ));
      }
      if (mounted) {
        setState(() {
          documents = docs;
        });
      }
    } else {
      if (mounted) {
        showSnackBar('Failed to get documents', context);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> renameDocument(String docId, String newName) async {
    setState(() {
      isLoading = true;
    
    });
    ApiService apiService = ApiService();
    print('BWAHAHAHAHHHAHAHAHAHAHHAHAHAHHAHAHA');
    var response =
        await apiService.renameDocument({"docId": docId, "newTitle": newName});
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
    } else {
      if (mounted) {
        showSnackBar('Failed to rename!', context);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteDocument(String docId) async {
    setState(() {
      isLoading = true;
    
    
    });
    ApiService apiService = ApiService();
    var response = await apiService.deleteDocument({'docId': docId});
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          showSnackBar('Document removed successfully', context);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          showSnackBar('Failed to remove!', context);
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    userId = UserIdStorage.getUserId().toString();
    // Map<String, dynamic> args =
    //     ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    // if (args['initialLetter'] != null) {
    //   userInitial = args['initialLetter'];
    // }
    super.didChangeDependencies();
    if (mounted) {
      setState(() {
        getAllUserDocuments();
      });
    }
  }

  Future<void> createDocument() async {
    setState(() {
      isLoading = true;
    });
    print('createDocument $userId');
    var response = await apiService.createDocument({'userId': userId});
    print(response);
    if (response.statusCode == 200) {
      var recievedDocument = jsonDecode(response.body);
      setState(() {
        Navigator.pushNamed(context, TextEditorPage.id,
            arguments: {"documentId": recievedDocument['id']}).then((value) {
          getAllUserDocuments();
            },);
      });
    } else {
      showSnackBar('Failed to create document', context);
    }
    setState(() {
      isLoading = false;
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
                const Align(
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
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                renameDocument(
                    documents[index].docId.toString(), _controller.text);
                setState(() {
                  documents[index].docName = _controller.text;
                });
                Navigator.pop(context);
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
          title: const Text('Delete Document'),
          content: const Text('Are you sure you want to delete this document?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                deleteDocument(documents[index].docId.toString());
                setState(() {
                  documents.removeAt(index);
                });
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
      child: ModalProgressHUD(
      inAsyncCall: isLoading,
      progressIndicator: const RedditLoadingIndicator(),
      blur: 0,
      opacity: 0,
      offset: Offset( ScreenSizeHandler.screenWidth*0.47,ScreenSizeHandler.screenHeight*0.6),
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
                Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 17,
                    child: Text(userInitial.toUpperCase()),
                  ),
                )
              ],
            ),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: ScreenSizeHandler.screenWidth * 0.12),
            child: LayoutBuilder(
              builder: (context, constraints) {
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
                      document: documents[index - 1],
                      index: index - 1,
                      showRenameDialog: _showRenameDialog,
                      showDeleteDialog: _showDeleteDialog,
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
