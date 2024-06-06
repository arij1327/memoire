import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileUser extends StatefulWidget {
  const ProfileUser({super.key});

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  List datauser = [];

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Votre Profile",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.edit),
          onPressed: datauser.isNotEmpty ? () {
            _showUpdateDialog(datauser[0]);
          } : null,
        ),
      ),
      body: datauser.isNotEmpty ? ListView.builder(
        itemBuilder: (context, i) {
          return Column(
            children: [
              SizedBox(height: 50),
              CircleAvatar(
                child: Icon(Icons.person),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    datauser[i]['Nom'],
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(width: 8),
                  // Uncomment the following line if you also want to display "Prénom"
                  // Text(datauser[i]['Prénom'], style: TextStyle(fontSize: 25)),
                ],
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.envelope,
                      size: 30,
                      color: Colors.black,
                    ),
                    SizedBox(width: 20),
                    Text(
                      datauser[i]['email'],
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        itemCount: datauser.length,
      ) : Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> getDataUser() async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('user')
        .child(FirebaseAuth.instance.currentUser!.uid);

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

  void _showUpdateDialog(dynamic userData) {
    TextEditingController nameController = TextEditingController(text: userData['Nom']);
    TextEditingController emailController = TextEditingController(text: userData['email']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Modifier le profile"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateUser(userData, nameController.text, emailController.text);
                Navigator.of(context).pop();
              },
              child: Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUser(dynamic userData, String newName, String newEmail) async {
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child('user')
        .child(FirebaseAuth.instance.currentUser!.uid);

    await ref.update({
      'Nom': newName,
      'email': newEmail,
    });

    setState(() {
      userData['Nom'] = newName;
      userData['email'] = newEmail;
    });
  }
}
