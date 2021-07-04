import 'package:agrii_ransport/add_widget/NavButton.dart';
import 'package:agrii_ransport/add_widget/progressIndicator.dart';
import 'package:agrii_ransport/screens/homepage.dart';
import 'package:agrii_ransport/screens/registrationpage.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class LoginPage extends StatefulWidget {

  static const String id = 'login';
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  void showSnackBar(String title){
    final snackbar = SnackBar(
      content: Text(title, textAlign: TextAlign.center,style: TextStyle(fontSize: 15),),
    );
    // ignore: deprecated_member_use
    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  var emailController = TextEditingController();

  var passwordController = TextEditingController();

  void login() async {

      // show wait dialog
    showDialog(context: context,
    builder: (BuildContext context) => ProgressDialog(status: 'Ready to log you in',),
    );
    

    final firebaseUser  = (await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
    ).catchError((ex){

      //for checking error and displaying it

      Navigator.pop(context);
      PlatformException thisEx =ex;
      showSnackBar(thisEx.message);

    })).user;


    if(firebaseUser != null) {

      // login verification
     DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/${firebaseUser.uid}');

     userRef.once().then((DataSnapshot snapshot)
     {
       if(snapshot.value != null)
         {
           Navigator.pushNamedAndRemoveUntil(context, HomePage.id, (route) => false);
         }
        }
      );
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
                Text('Sign in as Rider ',
                textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),

               Padding(
                 padding: EdgeInsets.all(8.0),
                 child: Column(
                   children: <Widget>[
                     TextField(
                       controller: emailController ,
                       keyboardType: TextInputType.emailAddress,
                       decoration: InputDecoration(
                           labelText: 'Email Address',
                           labelStyle: TextStyle(
                         fontSize: 14.00,
                       )
                       ),
                       style:TextStyle(fontSize: 14.0),
                     ),

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
                       title: 'LOGIN',
                       color: Colors.yellow,
                       onPressed:() async {

                         var connectivityResult = await Connectivity().checkConnectivity();
                         if (connectivityResult != ConnectivityResult.mobile &&
                             connectivityResult != ConnectivityResult.wifi) {
                           showSnackBar('No Internet Connection');
                           return;
                         }

                         if(!emailController.text.contains('@')){
                           showSnackBar('Please enter a valid email address');
                           return;
                         }

                         if((passwordController.text.length < 8)){
                           showSnackBar('Please enter a valid password');
                           return;
                         }
                             login();  //login method called here
                       },
                     ),
                   ],
                 ),
               ),

                // ignore: deprecated_member_use
                FlatButton(onPressed: ()
                {
                  Navigator.pushNamedAndRemoveUntil(context, RegistrationPage.id, (route) => false);
                },
                    child: Text('Don\'t have an account , sign up here')

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


