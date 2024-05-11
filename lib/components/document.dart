import 'package:flutter/material.dart';
import 'package:google_dogs/Screens/text_editor_page.dart';
import 'package:google_dogs/constants.dart';

class DocumentStruct{
  String docId;
  String docName;
  String docContent;
  String userPermission;

  DocumentStruct({
    required this.docId,
    required this.docName,
    required this.docContent,
    required this.userPermission,
  });
}

class Document extends StatelessWidget {
  const Document({
    super.key,
    required this.document,
    required this.index,
    required this.showRenameDialog,
    required this.showDeleteDialog,
  });
  final DocumentStruct document;
  final int index;
  final Function(BuildContext, String, int) showRenameDialog;
  final Function(int) showDeleteDialog;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, TextEditorPage.id, arguments: {
          'documentId': document.docId,
        });
      },
      child: Column(
        children: [
          Container(
            height: kDocumentHeight,
            width: kDocumentWidth,
            color: Colors.white,
          ),
          Container(
            padding: const EdgeInsetsDirectional.only(top: 5, bottom: 5),
            color: Colors.grey[600],
            width: kDocumentWidth,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      document.docName,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Image(
                      image: AssetImage('assets/images/logo_white.png'),
                      height: 20,
                    ),
                    const Icon(Icons.people_alt_outlined, size: 15),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        final RenderBox button =
                            context.findRenderObject() as RenderBox;
                        final RenderBox overlay = Overlay.of(context)
                            .context
                            .findRenderObject() as RenderBox;
                        final RelativeRect position = RelativeRect.fromRect(
                          Rect.fromPoints(
                            button.localToGlobal(
                                const Offset(
                                    kDocumentWidth * 0.6, kDocumentHeight * 0.5),
                                ancestor: overlay),
                            button.localToGlobal(
                                button.size.bottomRight(const Offset(0, 0)),
                                ancestor: overlay),
                          ),
                          Offset.zero & overlay.size,
                        );
                        showMenu(
                            context: context,
                            position: position,
                            items: <PopupMenuEntry>[
                              PopupMenuItem(
                                onTap: () {
                                  showRenameDialog(context, document.docName, index);
                                },
                                height: 40,
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.edit, size: 14),
                                    ),
                                    Text('Rename'),
                                    Spacer(),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                onTap: () {
                                  showDeleteDialog(index);
                                },
                                height: 40,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.delete, size: 14),
                                    ),
                                    Text('Remove'),
                                  ],
                                ),
                              ),
                            ]);
                      },
                      child: const Icon(
                        Icons.more_vert,
                        size: 17,
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
