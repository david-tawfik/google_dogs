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
import 'dart:math';

const String webSocketURL = 'http://localhost:3000';
// const String webSocketURL = 'http://20.90.88.241';
// const String baseURL = "google-dogs.bluewater-55be1484.uksouth.azurecontainerapps.io";

class User {
  final String email;
  String permission;

  User({required this.email, required this.permission});
}

double generateRandomTimestamp() {
  var random = Random();
  var randomNumber = (random.nextDouble() * 10000).round();
  var timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
  return timestamp + randomNumber;
}

class CRDTNode {
  double uniqueId;
  double fractionalID;
  String character;
  bool isBold;
  bool isItalic;

  CRDTNode(this.uniqueId, this.fractionalID, this.character, this.isBold,
      this.isItalic);

  Map<String, dynamic> toJson() {
    return {
      'uniqueId': uniqueId,
      'fractionalID': fractionalID,
      'character': character,
      'isBold': isBold,
      'isItalic': isItalic,
    };
  }
}

class CRDT {
  double siteId;
  List<CRDTNode> struct;

  CRDT(String docId)
      : siteId = double.parse(docId),
        struct = [
          CRDTNode(
            DateTime.now().millisecondsSinceEpoch.toDouble(),
            0.0,
            '',
            false,
            false,
          ),
          CRDTNode(
            DateTime.now().millisecondsSinceEpoch.toDouble() + 1,
            5000.0,
            '',
            false,
            false,
          ),
        ];

  CRDTNode localInsert(String value, int index, bool isBold, bool isItalic) {
    print("BEFORE");
    // for (var i = 0; i < struct.length; i++) {
    //   print(struct[i].fractionalID);
    // }
    for (var i = 0; i < struct.length; i++) {
      print(struct[i].character);
    }
    print('local');
    final char = generateChar(value, index, isBold, isItalic);
    // struct = struct.reversed.toList();
    print("han insert harf: ${char.character} at ${index + 1}");
    struct.insert(index + 1, char);
    // struct = struct.reversed.toList();
    print("AFTER");
    for (var i = 0; i < struct.length; i++) {
      print(struct[i].fractionalID);
    }
    return char;
  }

  List<CRDTNode> localBold(int start, int length) {
    List<CRDTNode> updatedNodes = [];

    // struct = struct.reversed.toList();
    for (var i = start + 1; i < start + 1 + length; i++) {
      struct[i].isBold = true;
      updatedNodes.add(struct[i]);
    }
    // struct = struct.reversed.toList();

    return updatedNodes;
  }

  List<CRDTNode> localUnbold(int start, int length) {
    List<CRDTNode> updatedNodes = [];
    // struct = struct.reversed.toList();
    for (var i = start + 1; i < start + 1 + length; i++) {
      struct[i].isBold = false;
      updatedNodes.add(struct[i]);
    }
    // struct = struct.reversed.toList();

    return updatedNodes;
  }

  List<CRDTNode> localItalic(int start, int length) {
    List<CRDTNode> updatedNodes = [];
    // struct = struct.reversed.toList();
    for (var i = start + 1; i < start + 1 + length; i++) {
      struct[i].isItalic = true;
      updatedNodes.add(struct[i]);
    }
    // struct = struct.reversed.toList();

    return updatedNodes;
  }

  List<CRDTNode> localUnitalic(int start, int length) {
    List<CRDTNode> updatedNodes = [];
    // struct = struct.reversed.toList();
    for (var i = start + 1; i < start + 1 + length; i++) {
      struct[i].isItalic = false;
      updatedNodes.add(struct[i]);
    }
    // struct = struct.reversed.toList();

    return updatedNodes;
  }

  List<int> remoteBold(int uniqueId) {
    List<int> updatedIndices = [];
    int index = struct.indexWhere((char) => char.uniqueId == uniqueId);
    if (index != -1) {
      struct[index - 1].isBold = true;
      updatedIndices.add(index - 1);
    }
    return updatedIndices;
  }

  List<int> remoteUnbold(int uniqueId) {
    List<int> updatedIndices = [];
    int index = struct.indexWhere((char) => char.uniqueId == uniqueId);
    if (index != -1) {
      struct[index - 1].isBold = false;
      updatedIndices.add(index - 1);
    }
    return updatedIndices;
  }

  List<int> remoteItalic(int uniqueId) {
    List<int> updatedIndices = [];
    int index = struct.indexWhere((char) => char.uniqueId == uniqueId);
    if (index != -1) {
      struct[index - 1].isItalic = true;
      updatedIndices.add(index - 1);
    }
    return updatedIndices;
  }

  List<int> remoteUnitalic(int uniqueId) {
    List<int> updatedIndices = [];
    int index = struct.indexWhere((char) => char.uniqueId == uniqueId);
    if (index != -1) {
      struct[index - 1].isItalic = false;
      updatedIndices.add(index - 1);
    }
    return updatedIndices;
  }

  CRDTNode generateChar(String value, int index, bool isBold, bool isItalic) {
    // Your logic for generating a CRDTNode with fractionalID goes here
    // Use the index and adjacent nodes' positions to calculate fractionalID
    print(index);
    print(struct[index].fractionalID);
    print(struct[index + 1].fractionalID);
    double fractionalId =
        (struct[index].fractionalID + struct[index + 1].fractionalID) / 2;
    print(fractionalId);
    double globalId = generateRandomTimestamp();
    return CRDTNode(globalId, fractionalId, value, isBold, isItalic);
  }

  CRDTNode localDelete(int index) {
    return struct.removeAt(index);
  }

  Map<String, dynamic> remoteInsert(CRDTNode char) {
    final index = findInsertIndex(char);
    struct.insert(index, char);
    return {'char': char.character, 'index': index};
  }

  int remoteDelete(CRDTNode char) {
    final index = struct.indexWhere((node) => node.uniqueId == char.uniqueId);
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
    if (a.fractionalID == b.fractionalID) {
      // Use uniqueId as a tie breaker
      if (a.uniqueId == b.uniqueId) {
        return 0;
      } else if (a.uniqueId < b.uniqueId) {
        return -1;
      } else {
        return 1;
      }
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

    return -1;
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
  bool isFirstTime = true;

  CRDT? crdt;

  late IO.Socket socket;

  @override
  void dispose() {
    _changeSubscription?.cancel();
    _controller.dispose();
    socket.disconnect();
    super.dispose();
  }

  void crdtToQuill(
    List<CRDTNode> crdts,
  ) {
    print('started function');
    final length = crdts.length;
    print(crdts);

    for (var i = 0; i < length; i++) {
      final crdt = crdts[i];
      var style = quill.Style();
      if (crdt.isBold) {
        style = style.put(quill.Attribute.bold);
      }
      if (crdt.isItalic) {
        style = style.put(quill.Attribute.italic);
      }
      print(i);
      print('inserting');
      print("Size: ${_controller.document.length}");

      // Ensure that crdt.character is a String
      String character = crdt.character.toString();

      // Check if character is not emptyF
      if (character.isNotEmpty) {
        // Use the compose method to insert the character with styling
        _controller.document.compose(
            quillDelta.Delta()..insert(character, style.attributes),
            quill.ChangeSource.remote);
        print('after insert');
      }
    }
  }

  void updateQuill(String char, int index, bool isBold, bool isItalic) {
    var style = quill.Style();
    if (isBold) {
      style = style.put(quill.Attribute.bold);
    }
    if (isItalic) {
      style = style.put(quill.Attribute.italic);
    }
    print('inserting');
    print("Size: ${_controller.document.length}");
    // Ensure that crdt.character is a String
    if (char.isNotEmpty) {
      // Use the compose method to insert the character with styling
      print(index);

      _controller.document.compose(
          quillDelta.Delta()
            ..retain(index - 1)
            ..insert(char, style.attributes),
          quill.ChangeSource.remote);
    }
    print('after insert');
  }

  @override
  void initState() {
    _changeSubscription =
        _controller.document.changes.listen((quill.DocChange change) {
      print(change.source);
      if (change.source == quill.ChangeSource.remote) {
        print('msh hab3at');
        return;
      }
      print('hohohoho');
      print(change.change.toList());
      final operations = change.change.toList();
      final lastOperation = operations.last;
      if (lastOperation.isInsert) {
        handleLocalInsert(change);
      } else if (lastOperation.isDelete) {
        handleLocalDelete(change);
      } else if (lastOperation.isRetain && lastOperation.attributes != null) {
        if (lastOperation.attributes!.containsKey('bold')) {
          if (lastOperation.attributes!['bold'] != null) {
            print('etba3 henaaa');
            handleLocalBold(change);
          } else {
            handleLocalUnbold(change);
          }
        } else if (lastOperation.attributes!.containsKey('italic')) {
          if (lastOperation.attributes!['italic'] != null) {
            handleLocalItalic(change);
          } else {
            handleLocalUnitalic(change);
          }
        }
      }
    });
    super.initState();
  }

  //   void loadDocument() async {
  //   // Send a GET request to the server
  //   http.Response response = await http.get('$webSocketURL/documents/$documentId' as Uri);

  //   // Check the status code of the response
  //   if (response.statusCode == 200) {
  //     // Parse the response body into a map
  //     Map<String, dynamic> document = jsonDecode(response.body);

  //     // Get the content of the document
  //     String content = document['content'];

  //     // Set the content of the QuillEditor widget
  //     _controller.document.insert(0, content);
  //   } else {
  //     print('Failed to load document');
  //   }
  // }

  void handleLocalInsert(quill.DocChange change) {
    // if (!isLocalChange) {
    //   return;
    // }
    print("CHANGE");
    final operations = change.change.toList();
    print(operations);

    int position = 0;
    String? character;
    bool isBold = false;
    bool isItalic = false;

    for (var operation in operations) {
      if (operation.isRetain) {
        position = operation.length!;
      } else if (operation.isInsert) {
        character = operation.data.toString();
        if (operation.attributes != null) {
          isBold = operation.attributes!['bold'] != null;
          isItalic = operation.attributes!['italic'] != null;
        }
      }
    }

    if (character != null) {
      print("here");
      CRDTNode justInserted =
          crdt!.localInsert(character, position, isBold, isItalic);
      //crdtToQuill(crdt!.struct);
      print('ana ha insert');
      socket.emit("insert", [
        documentId,
        justInserted.character,
        justInserted.uniqueId.toString(),
        justInserted.fractionalID.toString(),
        justInserted.isBold,
        justInserted.isItalic
      ]);
    }
  }

  void handleLocalBold(quill.DocChange change) {
    // if (!isLocalChange) {
    //   return;
    // }
    print("CHANGE");
    final operations = change.change.toList();
    print(operations);

    int position = 0;
    int length = 0;
    bool isBold = false;

    for (var operation in operations) {
      if (operation.isRetain) {
        if (operation.attributes != null &&
            operation.attributes!.containsKey('bold')) {
          isBold = operation.attributes!['bold'] != null;
          length = operation.length!;
        } else {
          position = operation.length!;
        }
      }
    }

    print(position);
    print(length);

    if (isBold) {
      print("Bold change at position: $position, length: $length");
      List<CRDTNode> updatedNodes = crdt!.localBold(position, length);
      print("el hayb2o bold: ${updatedNodes[0].character}");
      print(updatedNodes[0].character);
      socket.emit("update", [documentId, "bold", updatedNodes]);
    }
  }

  void handleLocalUnbold(quill.DocChange change) {
    // if (!isLocalChange) {
    //   return;
    // }
    print("CHANGE");
    final operations = change.change.toList();
    print(operations);

    int position = 0;
    int length = 0;
    bool isUnbold = false;

    for (var operation in operations) {
      if (operation.isRetain) {
        if (operation.attributes != null &&
            operation.attributes!.containsKey('bold')) {
          isUnbold = operation.attributes!['bold'] == null;
          length = operation.length!;
        } else {
          position = operation.length!;
        }
      }
    }

    if (isUnbold) {
      print("Unbold change at position: $position, length: $length");
      List<CRDTNode> updatedNodes = crdt!.localUnbold(position, length);
      socket.emit("update", [documentId, "unbold", updatedNodes]);
    }
  }

  void handleLocalItalic(quill.DocChange change) {
    // if (!isLocalChange) {
    //   return;
    // }
    print("CHANGE");
    final operations = change.change.toList();
    print(operations);

    int position = 0;
    int length = 0;
    bool isItalic = false;

    for (var operation in operations) {
      if (operation.isRetain) {
        if (operation.attributes != null &&
            operation.attributes!.containsKey('italic')) {
          isItalic = operation.attributes!['italic'] != null;
          length = operation.length!;
        } else {
          position = operation.length!;
        }
      }
    }

    if (isItalic) {
      print("Italic change at position: $position, length: $length");
      List<CRDTNode> updatedNodes = crdt!.localItalic(position, length);
      socket.emit("update", [documentId, "italic", updatedNodes]);
    }
  }

  void handleLocalUnitalic(quill.DocChange change) {
    // if (!isLocalChange) {
    //   return;
    // }
    print("CHANGE");
    final operations = change.change.toList();
    print(operations);

    int position = 0;
    int length = 0;
    bool isUnitalic = false;

    for (var operation in operations) {
      if (operation.isRetain) {
        if (operation.attributes != null &&
            operation.attributes!.containsKey('italic')) {
          isUnitalic = operation.attributes!['italic'] == null;
          length = operation.length!;
        } else {
          position = operation.length!;
        }
      }
    }

    if (isUnitalic) {
      print("Unitalic change at position: $position, length: $length");
      List<CRDTNode> updatedNodes = crdt!.localUnitalic(position, length);
      socket.emit("update", [documentId, "unitalic", updatedNodes]);
    }
  }

  void handleRemoteInsert(data) {
    print('Insert event received: $data');
    // Parse the received data
    String character = data[0];
    double siteID = double.parse(data[1].toString());
    double fractionalID = double.parse(data[2].toString());
    bool isBold = data[3];
    bool isItalic = data[4];

    for (var i = 0; i < crdt!.struct.length; i++) {
      print(crdt!.struct[i].fractionalID);
    }

    // Insert the character into the CRDT structure
    CRDTNode newNode =
        CRDTNode(siteID, fractionalID, character, isBold, isItalic);
    var result = crdt!.remoteInsert(newNode);
    var returnedChar = result['char'];
    var returnedIndex = result['index'];

    // Apply the delta to the document
    isLocalChange = false;
    if (mounted) {
      setState(() {
        updateQuill(returnedChar, returnedIndex, isBold, isItalic);
      });
    }
    Future.microtask(() {
      isLocalChange = true;
    });
  }

  void handleLocalDelete(quill.DocChange change) {
    // if (!isLocalChange) {
    //   return;
    // }
    print("DELETE");
    final operations = change.change.toList();
    print(operations);

    int position = 0;

    for (var operation in operations) {
      if (operation.isRetain) {
        position = operation.length!;
      } else if (operation.isDelete) {
        position += operation.length!;
      }
    }

    CRDTNode justDeleted = crdt!.localDelete(position);

    print("Delete position: $position");
    socket.emit("delete", [
      documentId,
      justDeleted.character,
      justDeleted.uniqueId.toString(),
      justDeleted.fractionalID.toString(),
      justDeleted.isBold,
      justDeleted.isItalic
    ]);
  }

  void handleRemoteDelete(data) {
    print('Delete event received: $data');
    // Parse the received data
    CRDTNode newNode = CRDTNode(
      double.parse(data[1].toString()),
      double.parse(data[2].toString()),
      data[0],
      data[3],
      data[4],
    );

    int index = crdt!.remoteDelete(newNode);
    // Create a delta representing the delete operation
    quillDelta.Delta delta = quillDelta.Delta()
      // Move the cursor to the desired position
      ..retain(index - 1)
      ..delete(1);
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

  void updateQuillDocument(String operation, List<int> updatedIndices) {
    switch (operation) {
      case 'bold':
        print("gowa: $updatedIndices");
        updatedIndices.forEach((index) {
          var delta = quillDelta.Delta()
            ..retain(index)
            ..retain(1, {'bold': true});
          _controller.document.compose(delta, quill.ChangeSource.remote);
        });
        break;
      case 'unbold':
        updatedIndices.forEach((index) {
          var delta = quillDelta.Delta()
            ..retain(index)
            ..retain(1, {'bold': null});
          _controller.document.compose(delta, quill.ChangeSource.remote);
        });
        break;
      case 'italic':
        updatedIndices.forEach((index) {
          var delta = quillDelta.Delta()
            ..retain(index)
            ..retain(1, {'italic': true});
          _controller.document.compose(delta, quill.ChangeSource.remote);
        });
        break;
      case 'unitalic':
        updatedIndices.forEach((index) {
          var delta = quillDelta.Delta()
            ..retain(index)
            ..retain(1, {'italic': null});
          _controller.document.compose(delta, quill.ChangeSource.remote);
        });
        break;
      default:
        print('Invalid operation: $operation');
    }
  }

  void handleRemoteUpdate(data) {
    print('Update event received: $data');
    String updateType = data[0];
    List<dynamic> updatedNodes = data[1];
    List<int> updatedIndices = [];

    updatedNodes.forEach((node) {
      int uniqueId = node['uniqueId'];
      switch (updateType) {
        case 'bold':
          updatedIndices = crdt!.remoteBold(uniqueId);
          print("1: $updatedIndices");
          updatedIndices = updatedIndices.reversed.toList();
          print("2: $updatedIndices");
          isLocalChange = false;
          if (mounted) {
            setState(() {
              updateQuillDocument('bold', updatedIndices);
            });
          }
          Future.microtask(() {
            isLocalChange = true;
          });
          break;
        case 'unbold':
          updatedIndices = crdt!.remoteUnbold(uniqueId);
          isLocalChange = false;
          if (mounted) {
            setState(() {
              updateQuillDocument('unbold', updatedIndices);
            });
          }
          Future.microtask(() {
            isLocalChange = true;
          });
          break;
        case 'italic':
          updatedIndices = crdt!.remoteItalic(uniqueId);
          isLocalChange = false;
          if (mounted) {
            setState(() {
              updateQuillDocument('italic', updatedIndices);
            });
          }
          Future.microtask(() {
            isLocalChange = true;
          });
          break;
        case 'unitalic':
          updatedIndices = crdt!.remoteUnitalic(uniqueId);
          isLocalChange = false;
          if (mounted) {
            setState(() {
              updateQuillDocument('unitalic', updatedIndices);
            });
          }
          Future.microtask(() {
            isLocalChange = true;
          });
          break;
        default:
          print('Invalid update type: $updateType');
      }
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
    socket.on('document', loadContent);
    socket.on('update', handleRemoteUpdate);
  }

  void loadContent(data) {
    if (!isFirstTime) {
      return;
    }
    isFirstTime = false;
    print('Load content event received: $data');
    // Parse the received data
    List<CRDTNode> crdts = [];
    for (var i = 0; i < data.length; i++) {
      crdts.add(CRDTNode(
        double.parse(data[i]["uniqueId"].toString()),
        double.parse(data[i]["fractionalId"].toString()),
        data[i]["char"],
        data[i]["isBold"],
        data[i]["isItalic"],
      ));
    }
    // Update the Quill editor with the received content
    crdt!.struct = crdts; //TA3ALA HENA TANYY
    isLocalChange = false;
    if (mounted) {
      setState(() {
        crdtToQuill(crdts.reversed.toList());
      });
    }

    crdt!.struct = crdts;

    // Future.microtask(() {
    //   isLocalChange = true;
    // });
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
    crdt = CRDT(documentId);
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

  // Future<void> updateDocumentContent() async {
  //   var response = await apiService.updateDocumentContent({
  //     'docId': documentId,
  //     'content': jsonEncode(_controller.document.toDelta().toJson()),
  //   });
  //   print(response);
  //   if (response.statusCode == 200) {
  //     showSnackBar('Document updated', context);
  //   } else {
  //     showSnackBar('Failed to update document', context);
  //   }
  // }

  Future<void> getDocument() async {
    var response = await apiService.getDocumentById(
        {'docId': documentId, 'userId': UserIdStorage.getUserId()});
    if (response.statusCode == 200) {
      var document = jsonDecode(response.body);
      setState(() {
        documentTitle = document['title'];
        // if (document['content'] != null && document['content'].isNotEmpty) {
        //   _controller.document =
        //       quill.Document.fromJson(jsonDecode(document['content']));
        // }
        if (document['content'] != null && document['content'].isNotEmpty) {
          _controller.document = quill.Document.fromJson([
            {"insert": ""}
          ]);
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

  quill.QuillController _controller = quill.QuillController.basic();

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
                                            ],
                                          ),
                                        )
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
                  // updateDocumentContent();
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
