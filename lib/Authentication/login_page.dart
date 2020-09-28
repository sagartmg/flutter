import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:maddat/Authentication/homePage.dart';
import 'package:maddat/UI/loadMap.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'firebase_uth/f';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  //todo why do we use global keys in flutter??
  // ==> when we need to preserve state and switch between various widgets.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              
              validator: (input) {
                if (input.isEmpty) {
                  return "email can't be empty";
                }
              },
              onSaved: (input) {
                _email = input.trimRight();
              },
              // onSved:(input)=>_email=input
              decoration: InputDecoration(labelText: "email"),
            ),
            TextFormField(
              validator: (input) {
                if (input.length < 6) {
                  return "password can't be less than 6 chars";
                }
              },
              onSaved: (input) {
                _password = input;
              },
              // onSved:(input)=>_email=input
              decoration: InputDecoration(labelText: "password"),
              obscureText: true,
            ),
            RaisedButton(
              onPressed: signIn,
              child: Text("sign in "),
            )
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    ///todo validatate fileds
    // globalkeys to preserve state
    final formState = _formKey.currentState;
    if (formState.validate()) {
      formState.save();
      print("email${_email},password:${_password}");

      /// saves every formFields that is descendentates of theis form///!! thats why we use globlkeys.
      //login to firebase
      //todo how to get userID from firebase??
      FirebaseUser user;
      final user_id = (await FirebaseAuth.instance.currentUser()).uid;
      try {
        user = (await FirebaseAuth.instance
                .signInWithEmailAndPassword(email: _email, password: _password))
            .user;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoadMap(user: user,firebase_userId: user_id,);
            },
          ),
        );
      } catch (error) {
        print("erro occured${error.message}");
      }
    }

    ///
  }
}
