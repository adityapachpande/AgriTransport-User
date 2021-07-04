
import 'package:firebase_database/firebase_database.dart';

class UserDetail{
  String fullName;
  String email;
  String phone;
  String id;

  UserDetail({
    this.email,
    this.fullName,
    this.phone,
    this.id,

});

  UserDetail.fromSnapshot(DataSnapshot snapshot){

    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    fullName = snapshot.value['fullname'];
  }
}