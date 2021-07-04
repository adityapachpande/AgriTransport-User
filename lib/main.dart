
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
      appId: '1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : FirebaseOptions(
      appId: '1:1077846897323:android:d5fbc7f0d34c68e3cafdee',
      apiKey: 'AIzaSyD5NuKqAzz2qlyqZq_sJ5ZXQeWAjgFl4Bk',
      messagingSenderId: '297855924061',
      projectId: 'flutter-firebase-plugins',
      databaseURL: 'https://agritransport-10f46-default-rtdb.firebaseio.com',
    ),
  );

  // currentFirebaseUser = await FirebaseAuth.instance.currentUser;

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


