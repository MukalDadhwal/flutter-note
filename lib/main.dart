import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import './firebase_options.dart';
import './google_auth_cred.dart';
import './providers/auth_provider.dart';
import './screens/home_screen.dart';
import './screens/sign_up_screen.dart';
import './screens/check_login_screen.dart';
import './providers/note_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GoogleAuth>(
          create: (BuildContext context) => GoogleAuth(
            GoogleSignIn(
              clientId: AuthCred.cliendId, // insert your cliend id here
              scopes: ['email'],
            ),
          ),
        ),
        ChangeNotifierProvider<NoteProvider>(
          create: (BuildContext context) => NoteProvider(),
        ),
      ],
      child: MaterialApp(
        scrollBehavior: CustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        title: 'Flutter Note',
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.white,
            secondary: Colors.purple,
          ),
          textSelectionTheme: TextSelectionThemeData(
            selectionColor: Colors.blue[300],
            cursorColor: Colors.black,
          ),
          textTheme: TextTheme(
            headline2: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            headline3: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        home: CheckLoginScreen(),
        routes: {
          HomePage.routeName: (context) => HomePage(),
          SignUpPage.routeName: (context) => SignUpPage(),
        },
      ),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
