import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_dogs/constants.dart';
import 'package:google_dogs/services/api_service.dart';
import 'package:google_dogs/utilities/email_regex.dart';
import 'package:google_dogs/utilities/show_snack_bar.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/html.dart';

const String websocketURL = 'ws://localhost:5555/collab';
// const String baseURL = "google-dogs.bluewater-55be1484.uksouth.azurecontainerapps.io";

class User {
  final String email;
  String permission;

  User({required this.email, required this.permission});
}

class TextEditorPage extends StatefulWidget {
  static const String id = 'text_editor';
  @override
  _TextEditorPageState createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  TextEditingController _textEditingController = TextEditingController();
  bool isBold = false;
  bool isItalic = false;
  FocusNode boldFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode selectorFocusNode = FocusNode();
  FocusNode permissionFocusNode = FocusNode();
  bool _futureTextIsBold = false;
  FocusNode _editorFocusNode = FocusNode();
  String name = 'Document 1';
  TextEditingController _emailController = TextEditingController();
  bool isValid = false;
  String selectedPermission = 'editor';
  String documentId = '';
  ApiService apiService = ApiService();
  String documentTitle = '';
  String content = '';
  String role = '';
  String creatorId = '';
  String creatorEmail = '';
  List<User> users = [];
  bool isReadOnly = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> connect() async {
    final stompClient = StompClient(
      config: StompConfig(
        url: websocketURL,
        onConnect: (StompFrame frame) {
          print('Connected to WebSocket!');
          // Subscribe to topics after connection is established
          //subscribeToTopic();
        },
        onDisconnect: (StompFrame frame) {
          print('Disconnected from WebSocket!');
        },
        onWebSocketError: (dynamic error) {
          print('WebSocket error: $error');
        },
      ),
    );
    stompClient.activate();
  }

  // void subscribeToTopic() {
  //   stompClient.subscribe(
  //       destination: '/topic/your-topic-name', // Replace with your topic name
  //       onMessage: (StompFrame frame) {
  //         print('Received message: ${frame.body}');
  //         // Handle incoming messages
  //       });
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    setState(() {
      documentId = args!['documentId'].toString();
      getDocument();
      getUsersFromDocumentID();
      _editorFocusNode.unfocus();
    });
  }

  Future<void> getUsersFromDocumentID() async {
    var response =
        await apiService.getUsersFromDocumentID({'docId': documentId});

    if (response.statusCode == 200) {
      var usersList = jsonDecode(response.body)['users'];
      print('Users LISTT: $usersList');
      List<User> tempUsers = [];
      for (var user in usersList) {
        tempUsers.add(User(email: user['email'], permission: user['role']));
      }
      tempUsers.removeAt(0);
      setState(() {
        users = tempUsers;
      });
    } else {
      showSnackBar('Failed to get users', context);
    }
  }

  Future<void> updateUserRole(email, docId, role) async {
    print('newRole: $role');
    var response = await apiService.updateUserRole({
      'email': email,
      'docId': docId,
      'newRole': role,
    });
    if (response.statusCode == 200) {
      showSnackBar('User role updated', context);
    } else {
      showSnackBar('Failed to update user role', context);
    }
  }

  Future<void> addUserToDocument(email, docId, role) async {
    print(email);
    print(docId);
    print(role);
    var response = await apiService.addUserToDocument({
      'email': email,
      'docId': docId,
      'role': role,
    });
    if (response.statusCode == 200) {
      showSnackBar('User added to document', context);
      print(users);
    } else {
      showSnackBar('Failed to add user to document', context);
    }
    setState(() {
      getUsersFromDocumentID();
    });
  }

  Future<void> updateDocumentContent() async {
    var response = await apiService.updateDocumentContent({
      'docId': documentId,
      'content': jsonEncode(_controller.document.toDelta().toJson()),
    });
    print(response);
    if (response.statusCode == 200) {
      showSnackBar('Document updated', context);
    } else {
      showSnackBar('Failed to update document', context);
    }
  }

  Future<void> getDocument() async {
    var response = await apiService.getDocumentById({'docId': documentId});
    if (response.statusCode == 200) {
      var document = jsonDecode(response.body);
      setState(() {
        documentTitle = document['title'];
        if (document['content'] != null && document['content'].isNotEmpty) {
          _controller.document =
              quill.Document.fromJson(jsonDecode(document['content']));
        }
        role = document['role'];
        // isReadOnly = role == 'viewer';
        creatorId = document['createdBy']['id'].toString();
        creatorEmail = document['createdBy']['email'];
      });
      print(documentTitle);
    } else {
      showSnackBar('Failed to get document', context);
    }
  }

  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 100.0, vertical: 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.0),
          ),
          child: Theme(
            data: ThemeData.light(),
            child: Scaffold(
              appBar: AppBar(
                title: Text(documentTitle),
                backgroundColor: Colors.deepPurple[200],
                actions: [
                  IconButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(kBackgroundColor),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepPurple[200]),
                      ),
                      focusNode: boldFocusNode,
                      onPressed: () {
                        setState(() {
                          final selectionStyle =
                              _controller.getSelectionStyle();
                          isBold = !selectionStyle.containsKey('bold');
                          _futureTextIsBold = isBold;
                          if (isBold) {
                            _controller.formatSelection(quill.Attribute.bold);
                          } else {
                            _controller.formatSelection(quill.Attribute.clone(
                                quill.Attribute.bold, null));
                          }
                          _editorFocusNode.requestFocus();
                        });
                      },
                      icon: Icon(Icons.format_bold)),
                  IconButton(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all(kBackgroundColor),
                        backgroundColor:
                            MaterialStateProperty.all(Colors.deepPurple[200]),
                      ),
                      onPressed: () {
                        setState(() {
                          final selectionStyle =
                              _controller.getSelectionStyle();
                          isItalic = !selectionStyle.containsKey('italic');

                          if (isItalic) {
                            _controller.formatSelection(quill.Attribute.italic);
                          } else {
                            _controller.formatSelection(quill.Attribute.clone(
                                quill.Attribute.italic, null));
                          }
                          // boldFocusNode.unfocus();
                          // _controller.moveCursorToEnd();
                          _editorFocusNode.requestFocus();
                        });
                      },
                      icon: Icon(Icons.format_italic)),
                  IconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Theme(
                            data: ThemeData.dark(),
                            child: AlertDialog(
                              title: Text(
                                "Share '$documentTitle'",
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              content: StatefulBuilder(
                                builder: (BuildContext context,
                                    StateSetter setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        focusNode: emailFocusNode,
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          hintText: 'Add people',
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            isValid = isEmailValid(value);
                                          });
                                        },
                                      ),
                                      isValid
                                          ? Align(
                                              alignment: Alignment.centerRight,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                                  focusNode: selectorFocusNode,
                                                  iconEnabledColor:
                                                      Colors.deepPurple[200],
                                                  style: TextStyle(
                                                    fontSize: 13.0,
                                                    color:
                                                        Colors.deepPurple[200],
                                                  ),
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  isDense: true,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                      vertical: 5.0),
                                                  items: const [
                                                    DropdownMenuItem(
                                                      value: 'editor',
                                                      child: Text('Editor'),
                                                    ),
                                                    DropdownMenuItem(
                                                      value: 'viewer',
                                                      child: Text('Viewer'),
                                                    ),
                                                  ],
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedPermission =
                                                          value.toString();
                                                      selectorFocusNode
                                                          .unfocus();
                                                    });
                                                  },
                                                  value: selectedPermission,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                              ),
                                            )
                                          : SizedBox(
                                              height: 34.0,
                                            ),
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'People with access',
                                            style: TextStyle(
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600),
                                          )),
                                      ButtonBar(
                                          alignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Icon(Icons.person),
                                            Text(creatorEmail),
                                            Text(
                                              'Owner',
                                              style: TextStyle(
                                                  fontSize: 13.0,
                                                  color: Colors.grey[400]),
                                            )
                                          ]),
                                      if (users.isNotEmpty)
                                        // ListView.builder(
                                        // itemCount: users.length,
                                        // itemBuilder: (BuildContext context, int index)
                                        // {
                                        SingleChildScrollView(
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          child: Column(
                                            children: [
                                              for (int index = 0;
                                                  index < users.length;
                                                  index++)
                                                ButtonBar(
                                                  alignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    Icon(Icons.person),
                                                    Text(users[index].email),
                                                    DropdownButtonHideUnderline(
                                                      child: DropdownButton(
                                                        // focusNode: permissionFocusNode,
                                                        iconEnabledColor: Colors
                                                            .deepPurple[200],
                                                        style: TextStyle(
                                                          fontSize: 13.0,
                                                          color: Colors
                                                              .deepPurple[200],
                                                        ),
                                                        alignment:
                                                            AlignmentDirectional
                                                                .center,
                                                        isDense: true,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.0,
                                                                vertical: 5.0),
                                                        items: const [
                                                          DropdownMenuItem(
                                                            value: 'editor',
                                                            child:
                                                                Text('Editor'),
                                                          ),
                                                          DropdownMenuItem(
                                                            value: 'viewer',
                                                            child:
                                                                Text('Viewer'),
                                                          ),
                                                        ],
                                                        onChanged: (value) {
                                                          setState(() {
                                                            users[index]
                                                                    .permission =
                                                                value
                                                                    .toString();
                                                            updateUserRole(
                                                                users[index]
                                                                    .email,
                                                                documentId,
                                                                users[index]
                                                                    .permission);
                                                            permissionFocusNode
                                                                .unfocus();
                                                          });
                                                        },
                                                        value: users[index]
                                                            .permission,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              // ;
                                            ],
                                          ),
                                        )

                                      // },

                                      // ),
                                    ],
                                  );
                                },
                              ),
                              // Column(
                              //   children: [
                              //     TextField(
                              //       controller: _emailController,
                              //       decoration: const InputDecoration(
                              //         hintText: 'Add people',
                              //       ),
                              //       onChanged: (value) {
                              //         setState(() {
                              //           isValid = isEmailValid(value);
                              //         });
                              //       },
                              //     ),
                              //      Visibility(
                              //         visible: isValid,
                              //        child: DropdownButton(
                              //               items:const [
                              //                 DropdownMenuItem(
                              //                   value: 'Editor',
                              //                   child: Text('Editor'),
                              //                 ),
                              //                 DropdownMenuItem(
                              //                   value: 'Viewer',
                              //                   child: Text('Viewer'),
                              //                 ),
                              //               ],
                              //               onChanged: (value) {},
                              //             ),
                              //      )
                              //         // : Text(
                              //         //     'Please enter a valid email address',
                              //         //     style: TextStyle(color: Colors.red),
                              //         //   ),
                              //   ],
                              // ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Copy Link'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                        kBackgroundColor),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.deepPurple[200]),
                                  ),
                                  child: Text('Done'),
                                  onPressed: () {
                                    if (isValid) {
                                      setState(
                                        () {
                                          addUserToDocument(
                                              _emailController.text,
                                              documentId,
                                              selectedPermission);
                                          _emailController.clear();
                                        },
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(
                      Icons.share,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    color: Colors.black,
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _textEditingController.clear();
                      _controller.clear();
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: EdgeInsets.all(16.0),
                child: AbsorbPointer(
                  absorbing: isReadOnly,
                  child: quill.QuillEditor.basic(
                    focusNode: _editorFocusNode,
                    configurations: quill.QuillEditorConfigurations(
                      controller: _controller,
                      autoFocus: false,
                      // readOnly: false, // true for view only mode
                      placeholder: 'Add your text here...',
                    ),
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                focusColor: Colors.deepPurple[200],
                onPressed: () {
                  // Add your functionality here, for example, saving the text
                  // String text = _controller.document.toPlainText();
                  // Handle the text
                  // print(text);
                  updateDocumentContent();
                },
                tooltip: 'Save',
                child: Icon(Icons.save),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
