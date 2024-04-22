import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';

class PhoneRegister extends StatefulWidget {
  const PhoneRegister({super.key});

  @override
  State<PhoneRegister> createState() => _PhoneRegisterState();
}

class _PhoneRegisterState extends State<PhoneRegister> {
    final TextEditingController usernumController = TextEditingController();

    Country selectedCountry = Country(
phoneCode: "216", 
countryCode: "TN",
e164Sc: 0,
geographic: true,
level: 1,
name: "tunisia",
example: "tunisia",
displayName: "tunisia",
displayNameNoCountryCode: "TN",
e164Key: "",
);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Column(
      children: [ TextFormField(
                      controller: usernumController,
                      
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          padding: EdgeInsets.all(8.0),
                          child: InkWell(onTap: () {
                            showCountryPicker(context: context, onSelect: (value){
                              setState(() {
                                selectedCountry = value;
                              });
                            });
                            
                          },
                          child: Text("${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",style:TextStyle(fontSize:20),),
                        ),),
                        labelText: 'Num',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    ElevatedButton(onPressed: (){}, child: Text("Login"))
                    ,],
    ),
    );
  }
}