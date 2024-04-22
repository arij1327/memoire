import 'package:app/authentification/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
   bool _isSigningIn = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    TextEditingController _userController = TextEditingController();
        TextEditingController _prenomController = TextEditingController();


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
  bool ischecked= false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        
        child: ListView(
          
          children: [
           
            Column(mainAxisAlignment: MainAxisAlignment.center,
            
              children: [
                Padding(padding: EdgeInsets.only(top :30)),
                 Row(children: [Image.asset("asset/logo.png",height: 50,), SizedBox(width: 250,),IconButton(onPressed: (){}, icon: Icon(Icons.close),)],),
                Text("S'inscrire",style: TextStyle(fontSize:40 ),),
                Padding(padding:EdgeInsets.all(20)),
                Row(children: [Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                                  labelText: 'Prenom',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                    controller: _userController,
                  ),
                ),SizedBox(width: 12,),Expanded(
                  child: TextField(
                    controller: _prenomController,
                   decoration: InputDecoration(
                                  labelText: 'Nom',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                  ),
                )],),Padding(padding:EdgeInsets.all(8)),
                TextFormField(
                  controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Adress Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              
                ),
                Padding(padding:EdgeInsets.all(8)),
                 TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                 ),
                 Padding(padding:EdgeInsets.all(8)),
                 TextFormField(
                  validator: (value) {
                    if (_passwordController.text!=_confirmpasswordController.text)return "verifier votre password";
                     return null;
                  },
                  controller: _confirmpasswordController,
                  obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirmz le Mot de passe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                 ),
                
            
                ElevatedButton(onPressed: ()async{try {
              final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
            
              );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
            } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
                print('The password provided is too weak.');
                 ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("The password provided is too weak."),
                  duration: Duration(seconds: 2),
                ),
              );
              } else if (e.code == 'email-already-in-use') {
                print('The account already exists for that email.');
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("the account already exists for that email"),
                  duration: Duration(seconds: 2),
                ),
              );
              }
            } catch (e) {
              print(e);
            }
            
                }, child: Text("Sinscrire")),
                 const SizedBox(height:230),
               Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?"),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  "Enregistrer",
                                  style: TextStyle(
                                    color:Color(0xFF53bcbd),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ), 
              ],
              
            ),
            
          ],
          
        ),
        
      ),
    );
  }
}