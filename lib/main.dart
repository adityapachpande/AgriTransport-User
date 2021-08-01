
import 'dart:io';
import 'package:agrii_ransport/screens/homepage.dart';
import 'package:agrii_ransport/screens/loginpage.dart';
import 'package:agrii_ransport/screens/registrationpage.dart';
import 'package:agrii_ransport/screens/searchpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dataprovider/appdata.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
      appId: 'YOUR APP ID',
      apiKey: 'YOUR API KEY',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: 'ID',
      databaseURL: 'DATABASE URL',
    )
        : FirebaseOptions(
      appId: 'YOUR APP ID',
      apiKey: 'YOUR API KEY',
      messagingSenderId: 'ID',
      projectId: 'flutter-firebase-plugins',
      databaseURL: 'YOUR DATABASE URL',
    ),
  );

  

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of the application.

  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider(
      create: (context) => AppData(),

      child: MaterialApp(
          debugShowCheckedModeBanner:false ,
          theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.red ,

          ),

        initialRoute: LoginPage.id, //firstscreen to display

        //navigation routes
        routes:
        {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          HomePage.id: (context) => HomePage(),
          MapView.id:(context)=> MapView(),
        },
      ),
    );
  }
}


