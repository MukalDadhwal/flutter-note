import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/sign_up_screen.dart';

class CheckLoginScreen extends StatefulWidget {
  @override
  State<CheckLoginScreen> createState() => _CheckLoginScreenState();
}

class _CheckLoginScreenState extends State<CheckLoginScreen> {
  @override
  Widget build(BuildContext context) {
    final googleAuth = Provider.of<GoogleAuth>(context);
    return FutureBuilder(
      future: googleAuth.tryAutoLogin(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.connectionState == ConnectionState.done &&
            snapshot.error == null) {
          if (snapshot.data == true) {
            return HomePage();
          } else {
            return SignUpPage();
          }
        } else {
          return Center(
            child: Text(
              'Something went wrong while getting your notes from server!',
            ),
          );
        }
      },
    );
  }
}
