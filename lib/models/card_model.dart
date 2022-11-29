import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardModel extends ChangeNotifier {
  final String documentId;
  String title;
  String contentPlainText;
  List contentJsonText;
  Color color;
  bool isPinned;
  DateTime lastEdited;

  CardModel({
    required this.documentId,
    required this.title,
    required this.contentPlainText,
    required this.contentJsonText,
    required this.lastEdited,
    this.color = const Color(0xffffffff),
    this.isPinned = false,
  });

  Future<void> changeNoteColor(Color chosedColor, String userUID) async {
    color = chosedColor;
    await FirebaseFirestore.instance
        .collection(userUID)
        .doc(documentId)
        .update({
      'backgroundColor': color.value,
    });
    notifyListeners();
  }

  Future<void> togglePin(String userUID) async {
    isPinned = !isPinned;
    await FirebaseFirestore.instance
        .collection(userUID)
        .doc(documentId)
        .update({
      'pinned': isPinned,
    });
    print(isPinned);
    // notifyListeners();
  }
}
