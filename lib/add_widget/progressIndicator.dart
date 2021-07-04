import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

 // ignore: must_be_immutable
 class ProgressDialog extends StatelessWidget
 {
   String status;
   ProgressDialog({this.status});

   @override
   Widget build(BuildContext context) {
     return Dialog(

       backgroundColor: Colors.yellow,
       child: Container(

         margin: EdgeInsets.all(15.0),
         width: double.infinity,
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(6.0),
         ),
         child: Padding(

           padding:  EdgeInsets.all(15.0),

           child: Row(
             children: [
               SizedBox(width: 6.0,),
               CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red),),
               SizedBox(width: 20.0,),
               Text(status, style: TextStyle(color: Colors.black),),
             ],
           ),
         ),
       ),
     );
   }
 }