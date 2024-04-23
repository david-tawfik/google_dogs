import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_dogs/Screens/document_manager.dart';
import 'package:google_dogs/components/continue_button.dart';
import 'package:google_dogs/components/credentials_text_field.dart';
import 'package:google_dogs/constants.dart';
import 'package:google_dogs/utilities/email_regex.dart';

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
  bool _futureTextIsBold = false;
  FocusNode _editorFocusNode = FocusNode();
  String name = 'Document 1';
  TextEditingController _emailController = TextEditingController();
  bool isValid = false;

  final quill.QuillController _controller = quill.QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 100.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1.0),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Text Editor'),
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
                      final selectionStyle = _controller.getSelectionStyle();
                      isBold = !selectionStyle.containsKey('bold');
                      _futureTextIsBold = isBold;
                      if (isBold) {
                        _controller.formatSelection(quill.Attribute.bold);
                      } else {
                        _controller.formatSelection(
                            quill.Attribute.clone(quill.Attribute.bold, null));
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
                      final selectionStyle = _controller.getSelectionStyle();
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
                      return AlertDialog(
                        title: Text("Share '$name'"),
                        content: Column(
                          children: [
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: 'Add people',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  isValid = isEmailValid(_emailController.text);
                                });
                              },
                            ),
                            isValid & _emailController.text.isNotEmpty
                                ? DropdownButton(
                                    items:const [
                                      DropdownMenuItem(
                                        value: 'Editor',
                                        child: Text('Editor'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'Viewer',
                                        child: Text('Viewer'),
                                      ),
                                    ],
                                    onChanged: (value) {},
                                  )
                                : Text(
                                    'Please enter a valid email address',
                                    style: TextStyle(color: Colors.red),
                                  ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Copy Link'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.all(kBackgroundColor),
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.deepPurple[200]),
                            ),
                            child: Text('Done'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
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
            child: quill.QuillEditor.basic(
              focusNode: _editorFocusNode,
              configurations: quill.QuillEditorConfigurations(
                controller: _controller,
                autoFocus: true,
                readOnly: false, // true for view only mode
                placeholder: 'Add your text here...',
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
            },
            tooltip: 'Save',
            child: Icon(Icons.save),
          ),
        ),
      ),
    );
  }
}
