import 'package:agrii_ransport/add_widget/AtDivider.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final List<String> members = <String>['ABC', 'KLM', 'HIJ' ];

    return new Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        shadowColor: Colors.black,
        title: Text('About', style: TextStyle(fontSize: 25 ,color: Colors.white,fontFamily: 'Brand-Bold'),),
      ),

        body:  Column(
          children: [

            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 5.0),

              child: Text('This App is Developed By "Team AgriTransport", Team consists of Following Members',
                style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold ,fontFamily: 'Brand-Bold',color: Colors.redAccent),
              ),
            ),

            AtDivider(),

            Expanded(child:
            ListView.separated(
            padding: const EdgeInsets.all(16),

              itemCount: members.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 130,
                  child: Card(
                  color: Colors.greenAccent,
                    elevation: 10,
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),

                          child: Container(
                            width: 85.0,
                            height: 85.0,
                            decoration: BoxDecoration(
                                color: Colors.red,
                                image: DecorationImage(
                                    image: AssetImage('images/user.png'),
                                    fit: BoxFit.cover),
                                borderRadius:
                                BorderRadius.all(Radius.circular(75.0)),
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 7.0, color: Colors.redAccent)
                                ]
                              ),
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            return showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext conext) {
                                return AlertDialog(
                                  title: Text('Flutter Developer'),
                                  content:
                                  const Text(
                                      'Hands on Experience on Flutter Framework'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Close'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                              padding: EdgeInsets.all(30.0),
                              child: Chip(
                                label: Text('${members[index]}'),
                                shadowColor: Colors.black,
                                backgroundColor: Colors.yellowAccent,
                                elevation: 10,
                                autofocus: true,
                              )
                            ),
                          ),
                        ],
                      ),
                     ),
                   );
                 }, separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ),
          ]
        )
      );
    }
  }
