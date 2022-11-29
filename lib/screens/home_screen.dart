import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/note_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/card_grid.dart';
import '../widgets/nav_bar.dart';
import '../widgets/create_note_dialog.dart';
import '../models/card_model.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home-page';
  static const title = 'Flutter Note';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _showCreateNoteDialog() async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, _, __) {
        return CreateNoteDialog();
      },
    ).then((value) {
      if (value != 'discard') {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final googleAuth = Provider.of<GoogleAuth>(context, listen: false);
    final noteProvider = Provider.of<NoteProvider>(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: size.width < 550 ? NavBar(60) : NavBar(110),
      body: noteProvider.isUserSearching
          ? CardGrid(
              pinnedCardsList: noteProvider.separatePinnedAndUnpinnedNotes(
                  noteProvider.searchMatchingUserNotes)['pinnedNotes']!,
              unpinnedCardsList: noteProvider.separatePinnedAndUnpinnedNotes(
                  noteProvider.searchMatchingUserNotes)['unpinnedNotes']!,
            )
          : FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection(googleAuth.userData['uid']!)
                  .get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.purple[400],
                    ),
                  );
                } else {
                  final documents = snapshot.data.docs;

                  if (documents.length == 0) {
                    return Center(
                      child: Text(
                          'Click the plus button at the bottom to create a new note!'),
                    );
                  }

                  List<CardModel> _notesList = [];
                  for (int i = 0; i < documents.length; i++) {
                    var doc = documents[i];
                    _notesList.add(
                      CardModel(
                        documentId: doc.reference.id,
                        title: doc['title'],
                        contentJsonText: doc['contentJson'],
                        contentPlainText: doc['contentText'],
                        color: Color(doc['backgroundColor']).withOpacity(1),
                        isPinned: doc['pinned'],
                        lastEdited: DateTime.parse(doc['lastEdited']),
                      ),
                    );
                  }

                  noteProvider.setNotesList(_notesList);

                  Map<String, List<CardModel>> map =
                      noteProvider.separatePinnedAndUnpinnedNotes(_notesList);

                  return CardGrid(
                    pinnedCardsList: map['pinnedNotes']!,
                    unpinnedCardsList: map['unpinnedNotes']!,
                  );
                }
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateNoteDialog,
        child: Icon(Icons.add_rounded),
      ),
    );
  }
}
