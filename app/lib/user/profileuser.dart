import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  List datauser = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(itemBuilder: (context,i){
        return Column(
          children: [
            Text(datauser[i]['name']),
           
          ],
        );
      }),
    );
  }
  Future<void> getdatauser()async{
DatabaseReference ref=FirebaseDatabase.instance.ref().child("user").child(FirebaseAuth.instance.currentUser!.uid);
DataSnapshot snapshot=await ref.get();
dynamic dataa =snapshot.value;

if(snapshot.value!=null){

datauser.add(dataa);
  }}
}