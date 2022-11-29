import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';

class CreateNoteDialog extends StatefulWidget {
  @override
  State<CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends State<CreateNoteDialog> {
  bool _isPinned = false;
  Color _pickedColor = Colors.white;
  late QuillController _quillController;
  late TextEditingController _titleController;
  late ScrollController _scrollController;
  FocusNode _titleFocusNode = FocusNode();
  FocusNode _quillEditorFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _quillController = QuillController.basic();
    _scrollController = ScrollController();
    _titleFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _titleFocusNode.dispose();
    _quillController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(errorText) {
    final SnackBar snackBar = SnackBar(
      content: Text(errorText),
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Dismiss',
        onPressed: ScaffoldMessenger.of(context).hideCurrentSnackBar,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Select a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _pickedColor,
            onColorChanged: (color) => setState(() => _pickedColor = color),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final maxHeight = height * 0.7;
    final maxWidth = width * 0.5;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
        backgroundColor: _pickedColor,
        titlePadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        scrollable: true,
        title: Container(
          width: maxWidth + 20.0,
          height: maxHeight * 0.2,
          child: TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            cursorHeight: 30,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(bottom: 20),
              hintText: 'Title',
              hintStyle: TextStyle(fontSize: 20),
              border: InputBorder.none,
              suffix: _isPinned
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isPinned = !_isPinned;
                        });
                      },
                      icon: Icon(Icons.push_pin_sharp),
                      tooltip: 'pin note',
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _isPinned = !_isPinned;
                        });
                      },
                      icon: Icon(Icons.push_pin_outlined),
                      tooltip: 'pin note',
                    ),
            ),
          ),
        ),
        content: SizedBox(
          width: maxWidth,
          height: maxHeight * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    top: (maxHeight * 0.8) * 0.02,
                    bottom: (maxHeight * 0.8) * 0.02),
                child: Divider(
                  height: 0,
                ),
              ),
              SizedBox(
                width: maxWidth,
                height: (maxHeight * 0.8) * 0.75,
                child: QuillEditor(
                  maxContentWidth: maxWidth,
                  controller: _quillController,
                  scrollController: _scrollController,
                  scrollable: true,
                  expands: true,
                  autoFocus: false,
                  focusNode: _quillEditorFocusNode,
                  padding: EdgeInsets.zero,
                  readOnly: false,
                ),
              ),
              SizedBox(
                height: (maxHeight * 0.8) * 0.21,
                width: maxWidth,
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        QuillToolbar.basic(
                          controller: _quillController,
                          toolbarIconSize: 18,
                          iconTheme: QuillIconTheme(
                            iconUnselectedFillColor: Colors.transparent,
                            borderRadius: 10.0,
                          ),
                          dialogTheme: QuillDialogTheme(
                            dialogBackgroundColor: Colors.purple[300],
                          ),
                          customButtons: [
                            QuillCustomButton(
                              icon: Icons.color_lens_rounded,
                              onTap: () => _showColorPicker(),
                            ),
                          ],
                          showAlignmentButtons: true,
                          showBackgroundColorButton: false,
                          showBoldButton: true,
                          showCenterAlignment: false,
                          showClearFormat: false,
                          showCodeBlock: true,
                          showColorButton: false,
                          showDirection: false,
                          showDividers: false,
                          showFontFamily: false,
                          showFontSize: false,
                          showHeaderStyle: false,
                          showIndent: false,
                          showInlineCode: false,
                          showItalicButton: true,
                          showLeftAlignment: false,
                          showQuote: false,
                          showJustifyAlignment: false,
                          showLink: true,
                          showListCheck: true,
                          showListBullets: true,
                          showRedo: true,
                          showRightAlignment: false,
                          showListNumbers: false,
                          showSearchButton: false,
                          showSmallButton: false,
                          showStrikeThrough: false,
                          showUnderLineButton: true,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              child: Text(
                                'Discard',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.black12),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop('discard');
                              },
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            TextButton(
                              child: Text(
                                'Done',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith(
                                    (states) => Colors.black12),
                              ),
                              onPressed: () async {
                                final googleAuth = Provider.of<GoogleAuth>(
                                    context,
                                    listen: false);
                                final noteProvider = Provider.of<NoteProvider>(
                                    context,
                                    listen: false);

                                await noteProvider
                                    .createNewNote(
                                  googleAuth.userData['uid']!,
                                  _titleController.text,
                                  _quillController.document.toPlainText(),
                                  _quillController.document.toDelta().toJson(),
                                  _pickedColor.value,
                                  _isPinned,
                                  DateTime.now().toIso8601String(),
                                )
                                    .then(Navigator.of(context).pop,
                                        onError: (e) {
                                  _showErrorSnackBar(e.toString());
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
