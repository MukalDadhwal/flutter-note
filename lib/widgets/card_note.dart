import 'package:flutter/material.dart';
import 'package:flutter_note/models/card_model.dart';
import 'package:flutter_note/providers/note_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../providers/auth_provider.dart';
import '../widgets/update_note_dialog.dart';

class CardNote extends StatefulWidget {
  @override
  State<CardNote> createState() => _CardNoteState();
}

class _CardNoteState extends State<CardNote> {
  bool _isCardHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardModel = Provider.of<CardModel>(context);
    final googleAuth = Provider.of<GoogleAuth>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    return InkWell(
      borderRadius: BorderRadius.circular(10.0),
      onTap: () {
        showDialog(
          context: context,
          builder: (_) {
            return UpdateNoteDialog(
              titleOfNote: cardModel.title,
              colorOfNote: cardModel.color,
              contentInJson: cardModel.contentJsonText,
              documentId: cardModel.documentId,
              isPinned: cardModel.isPinned,
              whenLastEdited: cardModel.lastEdited,
            );
          },
        );
      },
      onHover: (value) {
        if (value) {
          setState(() => _isCardHovered = true);
        } else {
          setState(() => _isCardHovered = false);
        }
      },
      child: Card(
        elevation: _isCardHovered ? 15.0 : 7.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: cardModel.color,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cardModel.title,
                    style: Theme.of(context).textTheme.headline2,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.clip,
                  ),
                  _isCardHovered
                      ? cardModel.isPinned
                          ? IconButton(
                              onPressed: () async {
                                await cardModel
                                    .togglePin(googleAuth.userData['uid']!);
                                noteProvider.refreshUserNotes();
                              },
                              icon: Icon(Icons.push_pin_sharp),
                              tooltip: 'pin note',
                            )
                          : IconButton(
                              onPressed: () async {
                                await cardModel
                                    .togglePin(googleAuth.userData['uid']!);
                                noteProvider.refreshUserNotes();
                              },
                              icon: Icon(Icons.push_pin_outlined),
                              tooltip: 'pin note',
                            )
                      : SizedBox.shrink(),
                ],
              ),
              SizedBox(height: 20),
              Text(
                cardModel.contentPlainText,
                style: Theme.of(context).textTheme.headline3,
                textAlign: TextAlign.left,
                overflow: TextOverflow.fade,
              ),
              _isCardHovered
                  ? Row(
                      children: [
                        IconButton(
                          onPressed: () async {
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: Text('Select a color'),
                                content: SingleChildScrollView(
                                  child: BlockPicker(
                                    pickerColor: cardModel.color,
                                    onColorChanged: (color) async {
                                      await cardModel.changeNoteColor(
                                        color,
                                        googleAuth.userData['uid']!,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          icon: Icon(Icons.color_lens_rounded),
                          tooltip: 'change background color',
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text('delete'),
                              onTap: () async {
                                await noteProvider.deleteNote(
                                  googleAuth.userData['uid']!,
                                  cardModel.documentId,
                                );
                                googleAuth.refreshAuth();
                              },
                            ),
                            PopupMenuItem(
                              child: Text('duplicate'),
                              onTap: () async {
                                await noteProvider.createNewNote(
                                  googleAuth.userData['uid']!,
                                  cardModel.title,
                                  cardModel.contentPlainText,
                                  cardModel.contentJsonText,
                                  cardModel.color.value,
                                  false,
                                  DateTime.now().toIso8601String(),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
