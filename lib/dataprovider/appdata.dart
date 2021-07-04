

import 'dart:async';

import 'package:agrii_ransport/screens/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier{

}

 /// verify the provided email id

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({Key key}) : super(key: key);

  @override
  _VerifyEmailState createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {

  final auth = FirebaseAuth.instance;
  User user;
  Timer timer;



  @override
  void initState() {
    user = auth.currentUser;
    user.sendEmailVerification();

    timer = Timer.periodic(Duration(seconds: 5),(timer) {
       checkEmailIsVerified();

     });
     super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Container(
          color: Colors.white,
          width: 300,
          height: 300,
          padding: new EdgeInsets.all(10.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.yellowAccent,
            elevation: 15,
            child: Column(

              children: [
                SizedBox(width: 6.0,),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),),
                ),
                Text(
                  'An Email has been sent to ${user.email} please verify', style: TextStyle(fontSize: 20 ,color: Colors.red),
                ),
              ],
            ),
          ),
        )
    );
  }

  Future<void> checkEmailIsVerified() async {
    user = auth.currentUser;
    await user.reload();


    timer.cancel();
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }
}



