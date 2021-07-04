import 'package:flutter/material.dart';


class NavButton extends StatelessWidget { //This button can be used anywhere in the projcet

  final String title;
  final Color color;
  final Function onPressed;// Variables for the button

  NavButton({this.title, this.onPressed, this.color}); //constructor


  @override
  Widget build(BuildContext context) {      //button on login and registration page
    return ElevatedButton(
      onPressed: onPressed,

      style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
       RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(21.0),
           side: BorderSide(color: Colors.redAccent)
        )
      )
    ),


      child:Container(
        height: 50,
        child: Center(
          child: Text(title,
            style: TextStyle( fontSize: 18, fontFamily: 'Brand-Bold'),
          ),
        ),
      ),
    );
  }
}