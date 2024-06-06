import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class A_propos extends StatefulWidget {
  const A_propos({super.key});

  @override
  State<A_propos> createState() => _A_proposState();
}

class _A_proposState extends State<A_propos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.arrow_back)),),
      body:  Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Image.network(
          
            //   width: 300,
            //   height: 300,
            // ),
            SizedBox(height: 20),
            Text(
              'À PROPOS DE NOS SERVICES',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          
            SizedBox(height: 20),
            Text(
"À LuxBlack, nous redéfinissons le transport en offrant bien plus qu'un simple service de taxi. Notre engagement est de créer des expériences agréables à chaque trajet. Nos chauffeurs qualifiés et nos véhicules bien entretenus garantissent un niveau de service exceptionnel. Que ce soit pour des trajets professionnels ou des déplacements personnels, nous offrons un mélange parfait de confort, de sécurité et de fiabilité. Chez LuxBlack, votre satisfaction est notre priorité absolue, et chaque kilomètre parcouru est une démonstration de notre dévouement à l'excellence."       ,
       textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    
    
    );
  }
}