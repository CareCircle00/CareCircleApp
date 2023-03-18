import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';



class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  static String countryCode = "1";
  static String phNo = "";
  static String verify = "";


  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final numberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // final TextEditingController? numberController;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: <Widget>[
        Container(
          margin: EdgeInsets.fromLTRB(0, 30*height/740, 0, 30*height/740),
          alignment: Alignment.center,
          child:SvgPicture.asset(
            'assets/svgs/logo.svg',
            // scale: 0.69,
            width: 60*width/360,
            height: 60*width/360,
            fit: BoxFit.fill,
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0,0,0,30*height/740),
          alignment: Alignment.center,
          child: Text(
            'Welcome to Care Circle',
            style: TextStyle(
              fontSize: 30*width/360,
              fontWeight: FontWeight.w500,
            )
          ),
        ),
        Container(
          margin:EdgeInsets.fromLTRB(0, 0, 0, 20*height/740),
          alignment: Alignment.center,
          child: Text(
            'Login or Signup',
            style: TextStyle(
              fontSize: 20*width/360,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(30*height/740, 0, 30*height/740, 10*height/740),
          alignment: Alignment.center,
          decoration:BoxDecoration(
            border: Border.all(
              color:Colors.grey,
              width: 1,
            ),
            color:Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child:Row(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0,0,0,0),
                width:100*width/360,
                height:70*height/740,
                // alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    showCountryPicker(
                      context: context,
                      //Optional.  Can be used to exclude(remove) one ore more country from the countries list (optional).
                      // exclude: <String>['KN', 'MF'],
                      favorite: <String>['US','IN','SG'],
                      //Optional. Shows phone code before the country name.
                      showPhoneCode: true,
                      onSelect: (Country country) {
                        Login.countryCode = country.phoneCode;
                        setState(() {

                        });
                      },
                      // Optional. Sets the theme for the country list picker.
                      countryListTheme: CountryListThemeData(
                        // Optional. Sets the border radius for the bottom sheet.
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        // Optional. Styles the search field.
                        inputDecoration: InputDecoration(
                          labelText: 'Search',
                          hintText: 'Start typing to search',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color(0xFF8C98A8).withOpacity(0.2),
                            ),
                          ),
                        ),
                        // Optional. Styles the text in the search field
                        searchTextStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18*width/360,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    side:const BorderSide(
                      width:1,
                      color: Colors.grey,
                      style: BorderStyle.none,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    // backgroundColor: Colors.red,
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    '+${Login.countryCode}',
                    style: TextStyle(
                      color:Colors.black,
                      fontSize: 25*width/360,
                    ),
                  ),
                ),
              ),
              Container(
                // width: 220,
                width: 190,
                height: 70,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                // alignment: Alignment.center,
                child: TextField(
                  controller: numberController,
                  onChanged: (inp){
                    Login.phNo = inp;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.fromLTRB(0, 20.6*height/740, 0, 0),
                    // contentPadding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                    // fillColor: Colors.cyan,
                  ),
                  style: TextStyle(
                    fontSize: 25*width/360,
                  ),
                )
              ),
            ],
          )
        ),
        const SendCodeBTN(),
        Container(
          margin: EdgeInsets.fromLTRB(35*height/740, 0, 35*height/740, 50*height/740),
          alignment: Alignment.center,
          child: Text(
            style:TextStyle(
              fontSize: 16*width/360,
              fontWeight: FontWeight.w400,
              color: Colors.black45,
            ),
            'Please enter your phone number and we will send you a one time password by SMS.',
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }
}


class SendCodeBTN extends StatefulWidget {
  const SendCodeBTN({Key? key}) : super(key: key);

  @override
  State<SendCodeBTN> createState() => _SendCodeBTNState();
}

class _SendCodeBTNState extends State<SendCodeBTN> {



  bool? clicked;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      clicked = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.fromLTRB(25*width/360, 0, 25*height/740, 20*width/360),
      alignment: Alignment.center,
      child:ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: clicked == false? Colors.blueAccent:Colors.grey,
          minimumSize: Size(400*width/360, 60*width/360),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)
          ),
        ),
        onPressed: clicked == true? null :()async {
          // setState(() {
          //   clicked = true;
          // });
          // print('${Login.countryCode} ${Login.phNo}');
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: '+${Login.countryCode} ${Login.phNo}',
            verificationCompleted: (PhoneAuthCredential credential) {},
            verificationFailed: (FirebaseAuthException e) {},
            codeSent: (String verificationId, int? resendToken) {
              Login.verify = verificationId;
              Navigator.pushNamed(context, '/code_screen');
            },
            codeAutoRetrievalTimeout: (String verificationId) {},
          ).then((resp)=>{
            // pushCodeScreen();
            //   Navigator.pushNamed(context, '/code_screen'),
          });
        },
        child: const Text('Send Code', style: TextStyle(fontSize: 20.0),),
      ),
    );
  }
}
