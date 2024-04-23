import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

import 'screens/first_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'utilities/screen_size_handler.dart';
import 'package:google_dogs/Screens/document_manager.dart';
import 'package:google_dogs/constants.dart';

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
        title: 'Dogs',
        // theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        routes: {
          FirstScreen.id: (context) => FirstScreen(),
          SignupScreen.id: (context) => const SignupScreen(),
          LoginScreen.id: (context) => const LoginScreen(),
          DocumentManagerScreen.id: (context) => const DocumentManagerScreen(),
          TextEditorPage.id: (context) => TextEditorPage(),
        },
        initialRoute: TextEditorPage
            .id //(token==null)?FirstScreen.id: (JwtDecoder.isExpired(token)) ? LoginScreen.id : HomePageScreen.id,
        );
  }
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
                    foregroundColor: isBold
                        ? MaterialStateProperty.all(Colors.white)
                        : MaterialStateProperty.all(kBackgroundColor),
                    backgroundColor: isBold
                        ? MaterialStateProperty.all(Colors.deepPurple[400])
                        : MaterialStateProperty.all(Colors.deepPurple[200]),
                  ),
                  focusNode: boldFocusNode,
                  onPressed: () {
                    setState(() {
                      // isBold = !isBold;

                      final selectionStyle = _controller.getSelectionStyle();
                      // isBold = selectionStyle.contains(quill.Attribute.bold);
                      isBold = !selectionStyle.containsKey('bold');

                      if (isBold) {
                        _controller.formatSelection(quill.Attribute.bold);
                      } else {
                         _controller.formatSelection(
                            quill.Attribute.clone(quill.Attribute.bold, null));
                      }
                      boldFocusNode.unfocus();
                      // textFieldFocusNode.requestFocus();
                    });
                  },
                  icon: Icon(Icons.format_bold)),
              IconButton(
                  style: ButtonStyle(
                    foregroundColor: isItalic
                        ? MaterialStateProperty.all(Colors.white)
                        : MaterialStateProperty.all(kBackgroundColor),
                    backgroundColor: isItalic
                        ? MaterialStateProperty.all(Colors.deepPurple[400])
                        : MaterialStateProperty.all(Colors.deepPurple[200]),
                  ),
                  onPressed: () {
                    setState(() {
                      isItalic = !isItalic;
                      // textFieldFocusNode.requestFocus();
                    });
                  },
                  icon: Icon(Icons.format_italic)),
              IconButton(
                color: Colors.black,
                icon: Icon(Icons.clear),
                onPressed: () {
                  _textEditingController.clear();
                },
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: quill.QuillEditor.basic(
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
              String text = _controller.document.toPlainText();
              // Handle the text
              print(text);
            },
            tooltip: 'Save',
            child: Icon(Icons.save),
          ),
        ),
      ),
    );
  }
}
