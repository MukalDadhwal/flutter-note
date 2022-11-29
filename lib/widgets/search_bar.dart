import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/note_provider.dart';

class SearchBar extends StatefulWidget implements PreferredSizeWidget {
  static const double searchBarSize = 50;

  @override
  Size get preferredSize => Size.fromHeight(searchBarSize);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late FocusNode _focusNode;
  late TextEditingController _textFieldController;
  double _searchBarElevation = 1.0;
  var _searchBarFillColor = Colors.grey[300];

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_getElevation);
    _focusNode.addListener(_refreshNotesWhenUnfocused);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_getElevation);
    _focusNode.removeListener(_refreshNotesWhenUnfocused);
    _focusNode.dispose();
    _textFieldController.dispose();
    super.dispose();
  }

  void _refreshNotesWhenUnfocused() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    if (!_focusNode.hasFocus) {
      noteProvider.isUserSearching = false;
      noteProvider.refreshUserNotes();
    }
  }

  void _getElevation() {
    if (_focusNode.hasFocus) {
      setState(() {
        _searchBarFillColor = Colors.white;
        _searchBarElevation = 10.0;
      });
    } else {
      setState(() {
        _searchBarFillColor = Colors.grey[300];
        _searchBarElevation = 1.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    return Container(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Material(
        elevation: _searchBarElevation,
        borderRadius: BorderRadius.circular(5.0),
        child: Container(
          width: width * 0.7,
          child: TextField(
            controller: _textFieldController,
            cursorColor: Colors.black,
            cursorWidth: 1.0,
            focusNode: _focusNode,
            onChanged: (_) =>
                noteProvider.returnMatchedNotes(_textFieldController.text),
            decoration: InputDecoration(
              filled: true,
              fillColor: _searchBarFillColor,
              hintText: "Search",
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Icon(
                  Icons.search_rounded,
                  color: Colors.black,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5.0),
                borderSide: BorderSide(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
