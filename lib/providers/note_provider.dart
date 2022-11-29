import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_note/models/http_exception.dart';

import '../models/card_model.dart';

class NoteProvider extends ChangeNotifier {
  List<CardModel> _userNotes = [];
  List<CardModel> _searchMatchingUserNotes = [];
  bool isUserSearching = false;

  List<CardModel> get currentUserNotes {
    return [..._userNotes];
  }

  List<CardModel> get searchMatchingUserNotes {
    return [..._searchMatchingUserNotes];
  }

  void setNotesList(List<CardModel> listOfNotes) {
    _userNotes = listOfNotes;
  }

  Future<void> createNewNote(
    String userUID,
    String title,
    String contentInPlainText,
    List contentInJson,
    int backgroundColor,
    bool isPinned,
    String lastEdited,
  ) async {
    Map<String, dynamic> data = {
      'title': title,
      'contentText': contentInPlainText,
      'contentJson': contentInJson,
      'backgroundColor': backgroundColor,
      'pinned': isPinned,
      'lastEdited': lastEdited,
    };
    try {
      await FirebaseFirestore.instance
          .collection(userUID)
          .doc(DateTime.now().toString())
          .set(data);
    } catch (error) {
      throw HttpException('Something went wrong while saving the data...');
    }
    notifyListeners();
  }

  Future<void> updateNote(
    String userUID,
    String documentId,
    String title,
    String contentInPlainText,
    List contentInJson,
    int backgroundColor,
    bool isPinned,
    String lastEdited,
  ) async {
    Map<String, dynamic> data = {
      'title': title,
      'contentText': contentInPlainText,
      'contentJson': contentInJson,
      'backgroundColor': backgroundColor,
      'pinned': isPinned,
      'lastEdited': lastEdited,
    };

    try {
      await FirebaseFirestore.instance
          .collection(userUID)
          .doc(documentId)
          .update(data);
    } catch (error) {
      throw HttpException('Something went wrong...');
    }
    notifyListeners();
  }

  Future<void> deleteNote(String userUID, String documentId) async {
    await FirebaseFirestore.instance
        .collection(userUID)
        .doc(documentId)
        .delete();
    notifyListeners();
  }

  Map<String, List<CardModel>> separatePinnedAndUnpinnedNotes(
      List<CardModel> currUserNotes) {
    Map<String, List<CardModel>> map = {'pinnedNotes': [], 'unpinnedNotes': []};
    List<CardModel> unpinnedNotesList = [];
    List<CardModel> pinnedNotesList = [];

    currUserNotes.forEach((CardModel element) {
      if (element.isPinned == true)
        pinnedNotesList.add(element);
      else
        unpinnedNotesList.add(element);
    });

    map['pinnedNotes'] = pinnedNotesList;
    map['unpinnedNotes'] = unpinnedNotesList;
    return map;
  }

  void returnMatchedNotes(String value) {
    List<String> notesDocumentIds = [];

    _searchMatchingUserNotes.clear();
    List<String> wordsList = value.split(' ');
    wordsList.removeWhere((element) => element == '');

    for (String word in wordsList) {
      for (CardModel cardModel in _userNotes) {
        if (!notesDocumentIds.contains(cardModel.documentId)) {
          if (cardModel.contentPlainText.contains(word)) {
            _searchMatchingUserNotes.add(cardModel);
            notesDocumentIds.add(cardModel.documentId);
            break;
          }
        }
      }
    }
    isUserSearching = true;
    notifyListeners();
  }

  void refreshUserNotes() {
    notifyListeners();
  }
}
