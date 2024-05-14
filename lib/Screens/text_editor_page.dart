import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart' as quillDelta;
import 'package:google_dogs/constants.dart';
import 'package:google_dogs/services/api_service.dart';
import 'package:google_dogs/utilities/email_regex.dart';
import 'package:google_dogs/utilities/show_snack_bar.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:convert';
import 'package:google_dogs/utilities/user_id.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

const String webSocketURL = 'http://localhost:3000';
// const String baseURL = "google-dogs.bluewater-55be1484.uksouth.azurecontainerapps.io";

class User {
  final String email;
  String permission;

  User({required this.email, required this.permission});
}

class CRDTNode {
  final String siteID;
  final double fractionalID;
  final String character;
  final bool isBold;
  final bool isItalic;

  CRDTNode(this.siteID, this.fractionalID, this.character, this.isBold,
      this.isItalic);

  Map<String, dynamic> toJson() {
    return {
      'siteID': siteID,
      'fractionalID': fractionalID,
      'character': character,
      'isBold': isBold,
      'isItalic': isItalic,
    };
  }
}

class CRDT {
  final String siteId;
  final List<CRDTNode> struct;

  CRDT(this.siteId)
      : struct = [
          CRDTNode(siteId, 0.0, '', false, false),
          CRDTNode(siteId, 5000.0, '', false, false)
        ];

  CRDTNode localInsert(String value, int index) {
    final char = generateChar(value, index);
    struct.insert(index, char);
    return char;
  }

  CRDTNode generateChar(String value, int index) {
    // Your logic for generating a CRDTNode with fractionalID goes here
    // Use the index and adjacent nodes' positions to calculate fractionalID
    double fractionalId = (struct[index-1].fractionalID + struct[index+1].fractionalID) / 2; 
    double globalId = DateTime.now().millisecondsSinceEpoch.toDouble(); // TODO: ADD USER ID
    return CRDTNode(
      siteId,
      fractionalId, 
      value,
      false,
      false,
    );
  }

  CRDTNode localDelete(int index) {
    return struct.removeAt(index);
  }

  void remoteInsert(CRDTNode char) {
    final index = findInsertIndex(char);
    struct.insert(index, char);
  }

  int remoteDelete(CRDTNode char) {
    final index = findIndexByPosition(char);
    if (index != -1) {
      struct.removeAt(index);
    }
    return index;
  }

  int findInsertIndex(CRDTNode char) {
    // Implement binary search or other suitable algorithm to find insert index
    // based on fractionalID
    // Example:
    int low = 0;
    int high = struct.length - 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      int compareResult = comparePositions(struct[mid], char);

      if (compareResult == 0) {
        return mid; // Found equal position, insert here
      } else if (compareResult < 0) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return low; // Insert at the end if not found
  }

  int comparePositions(CRDTNode a, CRDTNode b) {
    // Compare fractional IDs of CRDTNodes
    // Example:
    if (a.fractionalID == b.fractionalID) {
      return 0;
    } else if (a.fractionalID < b.fractionalID) {
      return -1;
    } else {
      return 1;
    }
  }

  int findIndexByPosition(CRDTNode char) {
    // Implement binary search or other suitable algorithm to find index by position
    // based on fractionalID
    // Example:
    int low = 0;
    int high = struct.length - 1;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      int compareResult = comparePositions(struct[mid], char);

      if (compareResult == 0) {
        return mid; // Found, return index
      } else if (compareResult < 0) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return -1; // Not found
  }
}

class TextEditorPage extends StatefulWidget {
  static const String id = '/test-editor';

  const TextEditorPage({super.key});
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
  bool isLocalChange = true;
  StreamSubscription<quill.DocChange>? _changeSubscription;

  List<CRDTNode> document = [];

  late IO.Socket socket;

  @override
  void initState() {
    _changeSubscription =
        _controller.document.changes.listen((quill.DocChange change) {
      if (change.change.toList().last.isInsert) {
        handleLocalInsert(change);
      } else if (change.change.toList().last.isDelete) {
        handleLocalDelete(change);
      }
    });
    super.initState();
  }

  void handleLocalInsert(quill.DocChange change) {
    if (!isLocalChange) {
      return;
    }
    print("CHANGE");
    print(change.change.toList());
    final operation = change.change.toList().last;
    if (operation.isInsert) {
      final siteID = Uuid().v4();
      final fractionalID = 0.0;
      final character = operation.data;
      final crdt =
          CRDTNode(siteID, fractionalID, character.toString(), false, false);
      socket.emit("insert", [
        documentId,
        crdt.character,
        crdt.siteID,
        crdt.fractionalID,
        crdt.isBold,
        crdt.isItalic
      ]);
    }
  }

  void handleRemoteInsert(data) {
    print('Insert event received: $data');
    // Parse the received data
    String character = data[0];
    String siteID = data[1];
    String fractionalID = data[2];
    bool isBold = data[3];
    bool isItalic = data[4];
    // Create a delta representing the insert operation
    print(_controller.document.length);
    quillDelta.Delta delta = quillDelta.Delta()
      ..retain(_controller.document.length -
          1) // Move the cursor to the desired position
      ..insert(character, {
        if (isBold) 'bold': true,
        if (isItalic) 'italic': true,
      });
    // Apply the delta to the document
    isLocalChange = false;
    if (mounted) {
      setState(() {
        _controller.document.compose(delta, quill.ChangeSource.remote);
      });
    }
    Future.microtask(() {
      isLocalChange = true;
    });
  }

  void handleLocalDelete(quill.DocChange change) {
    if (!isLocalChange) {
      return;
    }
    print("DELETE");
    print(change.change.toList());
    final operation = change.change.toList().last;
    if (operation.isDelete) {
      final length = operation.length;
      socket.emit("delete", [documentId, length]);
    }
  }

  void handleRemoteDelete(data) {
    print('Delete event received: $data');
    // Parse the received data
    int length = data[0];
    // Create a delta representing the delete operation
    quillDelta.Delta delta = quillDelta.Delta()
      ..retain(_controller.document.length -
          length -
          1) // Move the cursor to the desired position
      ..delete(length);
    // Apply the delta to the document
    isLocalChange = false;
    if (mounted) {
      setState(() {
        _controller.document.compose(delta, quill.ChangeSource.remote);
      });
    }
    Future.microtask(() {
      isLocalChange = true;
    });
  }

  void connect() {
    socket = IO.io(webSocketURL, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    // Connect to the server
    socket.connect();
    // Join the room corresponding to the document ID
    socket.emit("join", [documentId]);
    // Handle 'insert' events
    socket.on('insert', handleRemoteInsert);
    // Handle 'delete' events
    socket.on('delete', handleRemoteDelete);
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
    });
    connect();
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
      'userId': UserIdStorage.getUserId(),
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
      'userId': UserIdStorage.getUserId(),
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
    var response = await apiService.getDocumentById(
        {'docId': documentId, 'userId': UserIdStorage.getUserId()});
    if (response.statusCode == 200) {
      var document = jsonDecode(response.body);
      setState(() {
        documentTitle = document['title'];
        if (document['content'] != null && document['content'].isNotEmpty) {
          _controller.document =
              quill.Document.fromJson(jsonDecode(document['content']));
        }
        role = document['role'];
        print('Role: $role');
        isReadOnly = role == 'viewer' ? true : false;
        if (role == 'viewer') {
          _editorFocusNode.unfocus();
        } else {
          _editorFocusNode.requestFocus();
        }
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
                                        onTap: () {
                                          role == 'viewer'
                                              ? setState(() {
                                                  showSnackBar(
                                                      'You do not have permission to add users',
                                                      context);
                                                })
                                              : null;
                                        },
                                        readOnly:
                                            role == 'viewer' ? true : false,
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
                                                  padding: const EdgeInsets
                                                      .symmetric(
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
                                          : const SizedBox(
                                              height: 34.0,
                                            ),
                                      const Align(
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
                                                        padding:
                                                            const EdgeInsets
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
                                                          role == 'viewer'
                                                              ? setState(() {
                                                                  showSnackBar(
                                                                      'You do not have permission to add users',
                                                                      context);
                                                                })
                                                              : setState(() {
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
                              actions: <Widget>[
                                TextButton(
                                  style: ButtonStyle(
                                    foregroundColor: MaterialStateProperty.all(
                                        kBackgroundColor),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.deepPurple[200]),
                                  ),
                                  child: const Text('Done'),
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
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(
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
