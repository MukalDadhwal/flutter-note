import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../providers/auth_provider.dart';
import '../providers/note_provider.dart';

class UpdateNoteDialog extends StatefulWidget {
  final String titleOfNote;
  final String documentId;
  final List contentInJson;
  final Color colorOfNote;
  final bool isPinned;
  final DateTime whenLastEdited;

  UpdateNoteDialog({
    required this.titleOfNote,
    required this.documentId,
    required this.contentInJson,
    required this.colorOfNote,
    required this.isPinned,
    required this.whenLastEdited,
  });

  @override
  State<UpdateNoteDialog> createState() => _UpdateNoteDialogState();
}

class _UpdateNoteDialogState extends State<UpdateNoteDialog> {
  late bool _isPinned;
  late Color _pickedColor;
  late QuillController _quillController;
  late TextEditingController _titleController;
  late ScrollController _scrollController;
  late DateTime _lastEdited;
  FocusNode _quillEditorFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _lastEdited = widget.whenLastEdited;
    _isPinned = widget.isPinned;
    _pickedColor = widget.colorOfNote;
    _titleController = TextEditingController(text: widget.titleOfNote);
    _quillController = QuillController(
      document: Document.fromJson(widget.contentInJson),
      selection: TextSelection(baseOffset: 0, extentOffset: 0),
    );
    _scrollController = ScrollController();
    _quillEditorFocusNode.requestFocus();
    _quillController.addListener(_updateLastEditedForEditor);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    _quillController.removeListener(_updateLastEditedForEditor);
    super.dispose();
  }

  void _updatelastEditedForTitle() {
    _lastEdited = DateTime.now();
  }

  void _updateLastEditedForEditor() {
    Stream stream = _quillController.changes;
    stream.listen((_) {
      setState(() => _lastEdited = DateTime.now());
    });
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

  String _returnLastEdited() {
    Map<int, String> monthMap = {
      1: 'Jan',
      2: 'Feb',
      3: 'March',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec'
    };
    if (widget.whenLastEdited.day == DateTime.now().day) {
      return "Edited ${_lastEdited.hour}:${_lastEdited.minute}";
    } else {
      return "Edited ${_lastEdited.day} ${monthMap[_lastEdited.month]}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final maxHeight = height * 0.8;
    final maxWidth = width * 0.5;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ),
      child: AlertDialog(
        insetPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
        backgroundColor: _pickedColor,
        titlePadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 0, horizontal: 12.0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        scrollable: true,
        title: Container(
          width: maxWidth + 20.0,
          height: maxHeight * 0.2,
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _titleController,
            onChanged: (_) => _updatelastEditedForTitle(),
            cursorHeight: 30,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            textAlignVertical: TextAlignVertical.center,
            expands: false,
            decoration: InputDecoration(
              hintText: 'Title',
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                width: maxWidth,
                height: (maxHeight * 0.8) * 0.05,
                child: Row(children: [
                  Spacer(),
                  Text(
                    _returnLastEdited(),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: (maxHeight * 0.8) * 0.20,
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
                                    .updateNote(
                                  googleAuth.userData['uid']!,
                                  widget.documentId,
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
