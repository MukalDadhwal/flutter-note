import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SignUpPage extends StatefulWidget {
  static const routeName = '/sign-up-page';

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100, bottom: 20),
                child: Text(
                  'Sign Up and start creating your notes',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () async {
                  final googleAuth =
                      Provider.of<GoogleAuth>(context, listen: false);

                  await googleAuth.signInWithGoogle().onError(
                    (error, _) {
                      SnackBar snackBar = SnackBar(
                        content: Text(error.toString()),
                        behavior: SnackBarBehavior.floating,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                  );
                },
                hoverElevation: 10.0,
                highlightColor: Colors.black38,
                height: 50,
                minWidth: 400,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/google-logo.png',
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Sign Up with Google',
                      style: TextStyle(color: Colors.purple),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
