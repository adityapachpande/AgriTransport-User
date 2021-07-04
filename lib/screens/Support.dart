import 'package:flutter/material.dart';

class Support extends StatelessWidget {
  const Support({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        shadowColor: Colors.black,
        title: Text('Support', style: TextStyle(fontSize: 25 ,color: Colors.white,fontFamily: 'Brand-Bold'),),
      ),
      body: Center(

        child: Container(
          height: 350,
          width: 300,

          child: Card(
            color: Colors.lightGreenAccent,
            elevation: 50,
            shadowColor: Colors.black,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),

                  child: Container(
                    width: 80.0,
                    height: 80.0,

                     decoration: BoxDecoration
                       (

                           image: DecorationImage(
                              image: AssetImage('images/logo AT.png'),
                               fit: BoxFit.cover),
                          boxShadow: [
                          BoxShadow
                            (
                              blurRadius: 10.0,
                              color: Colors.white
                            )
                        ]
                      ),
                    ),
                  ),
                Text('\nContact us at - \n\n +91 7414XXXXXX',
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ,color: Colors.black),)
              ],
            ),
          ),
          color: Colors.yellowAccent,
        ),
      ),
    );
  }
}
