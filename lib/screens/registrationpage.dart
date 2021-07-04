
import 'package:agrii_ransport/add_widget/NavButton.dart';
import 'package:agrii_ransport/add_widget/progressIndicator.dart';
import 'package:agrii_ransport/screens/loginpage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'homepage.dart';

// ignore: must_be_immutable
class RegistrationPage extends StatefulWidget {

  static const String id = 'register';
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
    );
    // ignore: deprecated_member_use
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var fullNameController = TextEditingController();

  var phoneController = TextEditingController();

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void registerUser()  async//method for registrating the user
      {

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'We are registrating you in',),
    );

    final firebaseUser  = (await _auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    ).catchError((ex){
      //for checking error and displaying it
      Navigator.pop(context); // showdialog reference
      PlatformException thisEx =ex;
      showSnackBar(thisEx.message);

    })).user;

    //Check if registration is successful
    Navigator.pop(context);

    if(firebaseUser != null){
      DatabaseReference newUserRef = FirebaseDatabase.instance.reference().child('users/${firebaseUser.uid}');

      //Data fields to be stored on users table in firebase
      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };

      newUserRef.set(userMap);

      //This will take the user to the main page after successful registration
      Navigator.pushNamedAndRemoveUntil(context, HomePage.id, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:  EdgeInsets.all(8.0),
            child: Column(
              children: <Widget> [

                SizedBox(height: 70,),
                Image(
                    alignment: Alignment.center,
                    height: 150,
                    width: 120,
                    image: AssetImage('images/logo AT.png')
                ),

                SizedBox(height: 40,),
                Text('Create a Rider\'s Account ',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: fullNameController, //for firebase
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(
                              fontSize: 14.00,
                            )
                        ),
                        style:TextStyle(fontSize: 14.0),
                      ),//FullName
                      SizedBox(height: 10,),

                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: TextStyle(
                              fontSize: 14.00,
                            )
                        ),
                        style:TextStyle(fontSize: 14.0),
                      ),//PhoneNumber

                      SizedBox(height: 10,),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              fontSize: 14.00,
                            )
                        ),
                        style:TextStyle(fontSize: 14.0),
                      ),//EmailAddress

                      SizedBox(height: 10,),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              fontSize: 14.00,
                            )
                        ),
                        style:TextStyle(fontSize: 14.0),

                      ),

                      SizedBox(height: 40,),

                      NavButton(           // Using button as a function
                        title: 'REGISTER',
                        color: Colors.yellow ,
                        onPressed:() async{
                          //Have to check internet connectivity
                          var connectivityResult = await Connectivity().checkConnectivity();
                          if(connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi){
                            showSnackBar('No Internet Connection');
                            return;


                          }


                          if(fullNameController.text.length < 3)
                          {
                            showSnackBar('Please provide a valid Full Name');
                            return;
                          }

                          if(phoneController.text.length < 10)
                          {
                            showSnackBar(
                                'Please provide a valid phone number');
                            return;
                          }

                          if(!emailController.text.contains('@'))
                          {
                            showSnackBar('Please provide a valid email address');
                            return;
                          }

                          if(passwordController.text.length < 8){
                            showSnackBar('password must be at least 8 characters');
                          }

                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),

                TextButton(onPressed: ()
                {
                  Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
                },
                    child: Text('Already have a RIDER account? Log in')
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
