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
  void initState(){
    super.initState();
    getDataUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile User"),
      ),
      body: ListView.builder(itemBuilder: 
      (context,i) {
        return Column(
          children: [
           /* CircleAvatar(
              child:Image.network(data[i]['image']) ,
            ),*/
            
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(datauser[i]['Nom'],style: TextStyle(fontSize: 25),),
               SizedBox(width:8),
             //   Text(data[i]['Prénom'],style: TextStyle(fontSize: 25),),

            ],
           )
          ],
        );

      }, itemCount: datauser.length),
    );
  }
 Future<void> getDataUser() async {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('user').child(FirebaseAuth.instance.currentUser!.uid);

  // Fetch data once
  DataSnapshot snapshot = await ref.get();

  if (snapshot.value != null) {
    // Data exists, add it to your list or use it as needed
    dynamic data = snapshot.value;
    

    setState(() {
      datauser.add(data);    

    });
  } else {
    print("Document does not exist");
  }
}
}