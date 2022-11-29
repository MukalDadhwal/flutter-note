import 'package:flutter/material.dart';
import 'package:flutter_note/providers/note_provider.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import './search_bar.dart';

class NavBar extends StatefulWidget implements PreferredSizeWidget {
  static const String title = 'Flutter Note';
  final double navBarHeight;

  NavBar(this.navBarHeight);

  @override
  Size get preferredSize => Size.fromHeight(navBarHeight);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  Color _color = Colors.grey;
  bool searchBarVisible = false;
  late TextEditingController _textFieldController;

  @override
  void initState() {
    super.initState();
    _textFieldController = TextEditingController();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  void _setRefreshIconColorToBlack() {
    setState(() {
      _color = Colors.black;
    });
  }

  void _setRefreshIconColorToGrey() {
    setState(() {
      _color = Colors.grey;
    });
  }

  void _showSnackBar(String errorText) {
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

  @override
  Widget build(BuildContext context) {
    final googleAuth = Provider.of<GoogleAuth>(context);
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    final width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: searchBarVisible
          ? () {
              noteProvider.isUserSearching = false;
              noteProvider.refreshUserNotes();
              setState(() => searchBarVisible = false);
            }
          : null,
      child: Stack(
        children: [
          AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlutterLogo(),
                SizedBox(width: 5.0),
                Text(
                  NavBar.title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                )
              ],
            ),
            actions: [
              width < 550
                  ? IconButton(
                      onPressed: () => setState(() => searchBarVisible = true),
                      icon: Icon(Icons.search_rounded),
                      color: Colors.black,
                    )
                  : SizedBox.shrink(),
              MouseRegion(
                onEnter: (event) => _setRefreshIconColorToBlack(),
                onExit: (event) => _setRefreshIconColorToGrey(),
                child: IconButton(
                  onPressed: () {
                    noteProvider.refreshUserNotes();
                  },
                  icon: Icon(Icons.replay),
                  color: _color,
                  tooltip: "Refresh",
                ),
              ),
              SizedBox(width: 5.0),
              TextButton(
                child: Text(
                  'Sign Out',
                  style: TextStyle(color: Colors.black),
                ),
                style: ButtonStyle(
                  overlayColor: MaterialStateColor.resolveWith(
                      (states) => Colors.black12),
                ),
                onPressed: () async {
                  await googleAuth
                      .signOutWithGoogle()
                      .onError((error, __) => _showSnackBar(error.toString()));
                },
              ),
              SizedBox(width: 5.0),
              Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.zero,
                height: 10,
                child: Tooltip(
                  height: 30,
                  message:
                      "${googleAuth.userData['displayName']}\n${googleAuth.userData['email']}",
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      '${googleAuth.userData['displayName']![0].toUpperCase()}',
                      style: TextStyle(color: Colors.white),
                    ),
                    radius: 15,
                    // child: Image.network('${userData['photoUrl']}'),
                  ),
                ),
              ),
              SizedBox(width: 10.0),
            ],
            bottom: width >= 550
                ? SearchBar()
                : PreferredSize(
                    child: SizedBox(),
                    preferredSize: Size.fromHeight(0),
                  ),
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 1.0,
            scrolledUnderElevation: 10.0,
          ),
          width < 550
              ? searchBarVisible
                  ? Container(
                      color: Colors.transparent,
                      child: Container(
                        width: width * 0.37,
                        height: 30,
                        child: TextField(
                          controller: _textFieldController,
                          cursorHeight: 20,
                          onChanged: (_) {
                            noteProvider
                                .returnMatchedNotes(_textFieldController.text);
                          },
                          decoration: InputDecoration(
                            hintText: 'search notes',
                            contentPadding: const EdgeInsets.all(10.0),
                            filled: true,
                            fillColor: Colors.purpleAccent[100],
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      padding: EdgeInsets.only(left: width * 0.5, top: 10),
                    )
                  : SizedBox.shrink()
              : SizedBox.shrink()
        ],
      ),
    );
  }
}
