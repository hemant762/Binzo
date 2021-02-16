import 'dart:convert';

import 'package:app/Dialog/dialog_helpers.dart';
import 'package:app/components/already_have_an_account_acheck.dart';
import 'package:app/components/rounded_button.dart';
import 'package:app/components/rounded_input_field.dart';
import 'package:app/components/rounded_password_field.dart';
import 'package:app/screens/login/login_screen.dart';
import 'package:app/screens/signup/background.dart';
import 'package:app/services/enc.dart';
import 'package:app/services/http_post.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';

import '../../constants.dart';
import '../verifyOtp/otp_verify_screen.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _phoneController = TextEditingController();
  final _passController = TextEditingController();


  Future<bool> checkNumberRegisterd(phone_number) async{
    try{
      HttpPost httpPost = HttpPost(context: context,type: isNumberRegisterPost,voids: [phone_number]);
      Response response = await httpPost.postNow();
      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
      if(data["error"]){
        showToast(data['message'],
            context: context,
            animation: StyledToastAnimation.slideFromBottom,
            reverseAnimation: StyledToastAnimation.slideToBottom,
            startOffset: Offset(0.0, 3.0),
            reverseEndOffset: Offset(0.0, 3.0),
            position: StyledToastPosition.bottom,
            duration: Duration(seconds: 4),
            //Animation duration   animDuration * 2 <= duration
            animDuration: Duration(seconds: 1),
            curve: Curves.elasticOut,
            backgroundColor: Colors.red,
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        return true;
      }else{
        if(data["is_number_registerd"]){
          showToast(data['message'],
              context: context,
              animation: StyledToastAnimation.slideFromBottom,
              reverseAnimation: StyledToastAnimation.slideToBottom,
              startOffset: Offset(0.0, 3.0),
              reverseEndOffset: Offset(0.0, 3.0),
              position: StyledToastPosition.bottom,
              duration: Duration(seconds: 4),
              //Animation duration   animDuration * 2 <= duration
              animDuration: Duration(seconds: 1),
              curve: Curves.elasticOut,
              backgroundColor: Colors.amber[600],
              textStyle: TextStyle(color: Colors.black),
              reverseCurve: Curves.fastOutSlowIn);
          return true;
        }else{
          return false;
        }
      }
    }catch(e){
      print("Error : $e");
      showToast("Something is wrong",
          context: context,
          animation: StyledToastAnimation.slideFromBottom,
          reverseAnimation: StyledToastAnimation.slideToBottom,
          startOffset: Offset(0.0, 3.0),
          reverseEndOffset: Offset(0.0, 3.0),
          position: StyledToastPosition.bottom,
          duration: Duration(seconds: 4),
          //Animation duration   animDuration * 2 <= duration
          animDuration: Duration(seconds: 1),
          curve: Curves.elasticOut,
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
      return true;
    }
  }

  Future<void> sendOtp() async {

    bool isRegisterd = await checkNumberRegisterd(_phoneController.text.toString().trim());

    if(!isRegisterd){
      try{
        String phoneNumber = "+91 " + _phoneController.text.toString().trim();
        await Firebase.initializeApp();
        FirebaseAuth _firebaseAuth = await FirebaseAuth.instance;
//        if(kIsWeb){
//          ConfirmationResult confirmationResult = await _firebaseAuth.signInWithPhoneNumber(phoneNumber);
//          if(confirmationResult != null){
//
//            showToast("Otp Send Success",
//                context: context,
//                animation: StyledToastAnimation.slideFromBottom,
//                reverseAnimation: StyledToastAnimation.slideToBottom,
//                startOffset: Offset(0.0, 3.0),
//                reverseEndOffset: Offset(0.0, 3.0),
//                position: StyledToastPosition.bottom,
//                duration: Duration(seconds: 4),
//                //Animation duration   animDuration * 2 <= duration
//                animDuration: Duration(seconds: 1),
//                curve: Curves.elasticOut,
//                backgroundColor: Colors.green,
//                textStyle: TextStyle(color: Colors.white),
//                reverseCurve: Curves.fastOutSlowIn);
//            Navigator.of(context).pop();
//            Navigator.push(
//              context,
//              MaterialPageRoute(
//                builder: (context) {
//                  return OtpVerifyWeb(
//                    confirmationResult: confirmationResult,
//                    phone_number: _phoneController.text.toString().trim(),
//                    password: _passController.text.toString().trim(),
//                  );
//                },
//              ),
//            );
//
//          }else{
//            showToast("Something Is Wrong",
//                context: context,
//                animation: StyledToastAnimation.slideFromBottom,
//                reverseAnimation: StyledToastAnimation.slideToBottom,
//                startOffset: Offset(0.0, 3.0),
//                reverseEndOffset: Offset(0.0, 3.0),
//                position: StyledToastPosition.bottom,
//                duration: Duration(seconds: 4),
//                //Animation duration   animDuration * 2 <= duration
//                animDuration: Duration(seconds: 1),
//                curve: Curves.elasticOut,
//                backgroundColor: Colors.red,
//                textStyle: TextStyle(color: Colors.white),
//                reverseCurve: Curves.fastOutSlowIn);
//            Navigator.of(context).pop();
//          }
//        }
//        else{
          _firebaseAuth.verifyPhoneNumber(
              phoneNumber: phoneNumber,
              timeout: Duration(seconds: 60),
              verificationCompleted: (AuthCredential credential) async{
//          UserCredential result = await _firebaseAuth.signInWithCredential(credential);
//          if(result.user != null){
//            Navigator.push(context, MaterialPageRoute(
//                builder: (context) => WelcomeScreen()
//            ));
//          }else{
//            print("Error");
//          }
                //This callback would gets called when verification is done auto maticlly
              },
              verificationFailed: (FirebaseAuthException exception){
                Navigator.of(context).pop();
                print(exception);
                showToast("Something Is Wrong",
                    context: context,
                    animation: StyledToastAnimation.slideFromBottom,
                    reverseAnimation: StyledToastAnimation.slideToBottom,
                    startOffset: Offset(0.0, 3.0),
                    reverseEndOffset: Offset(0.0, 3.0),
                    position: StyledToastPosition.bottom,
                    duration: Duration(seconds: 4),
                    //Animation duration   animDuration * 2 <= duration
                    animDuration: Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    backgroundColor: Colors.red,
                    textStyle: TextStyle(color: Colors.white),
                    reverseCurve: Curves.fastOutSlowIn);
              },
              codeSent: (String verificationId, [int forceResendingToken]){
                showToast("Otp Send Success",
                    context: context,
                    animation: StyledToastAnimation.slideFromBottom,
                    reverseAnimation: StyledToastAnimation.slideToBottom,
                    startOffset: Offset(0.0, 3.0),
                    reverseEndOffset: Offset(0.0, 3.0),
                    position: StyledToastPosition.bottom,
                    duration: Duration(seconds: 4),
                    //Animation duration   animDuration * 2 <= duration
                    animDuration: Duration(seconds: 1),
                    curve: Curves.elasticOut,
                    backgroundColor: Colors.green,
                    textStyle: TextStyle(color: Colors.white),
                    reverseCurve: Curves.fastOutSlowIn);
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OtpVerify(
                        firebaseAuth: _firebaseAuth,
                        verificationId: verificationId,
                        resendToken:forceResendingToken,
                        phone_number: _phoneController.text.toString().trim(),
                        password: _passController.text.toString().trim(),
                      );
                    },
                  ),
                );
              },
              codeAutoRetrievalTimeout: (String verificationId){}
          );
//        }
      }catch(e){
        print("Error : $e");
        showToast("Something Is Wrong",
            context: context,
            animation: StyledToastAnimation.slideFromBottom,
            reverseAnimation: StyledToastAnimation.slideToBottom,
            startOffset: Offset(0.0, 3.0),
            reverseEndOffset: Offset(0.0, 3.0),
            position: StyledToastPosition.bottom,
            duration: Duration(seconds: 4),
            //Animation duration   animDuration * 2 <= duration
            animDuration: Duration(seconds: 1),
            curve: Curves.elasticOut,
            backgroundColor: Colors.red,
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        Navigator.of(context).pop();
      }
    }else{
      Navigator.of(context).pop();
    }

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Background(child: WillPopScope(
      onWillPop: () async{
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 100,),
              Text(
                "Signup",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
              ),
              SizedBox(height: size.height * 0.05),
//              kIsWeb ?
//              WebsafeSvg.asset(
//                "assets/icons/shop_icon2.svg",
//                height: size.height * 0.30,
//              ) :
              SvgPicture.asset(
                "assets/icons/signup.svg",
                height: size.height * 0.30,
              ),
              SizedBox(height: size.height * 0.05),
              RoundedInputField(
                hintText: "Phone No.",
                type: TextInputType.number,
                controller:_phoneController,
                onChanged: (value) {},
              ),
              RoundedPasswordField(
                onChanged: (value) {},
                controller: _passController,
              ),

              RoundedButton(
                text: "Send Otp",
                press: () {
                  if (_phoneController.text.toString().trim().length != 10){
                    showToast("Enter Valid Phone Number",
                        context: context,
                        animation: StyledToastAnimation.slideFromBottom,
                        reverseAnimation: StyledToastAnimation.slideToBottom,
                        startOffset: Offset(0.0, 3.0),
                        reverseEndOffset: Offset(0.0, 3.0),
                        position: StyledToastPosition.bottom,
                        duration: Duration(seconds: 4),
                        //Animation duration   animDuration * 2 <= duration
                        animDuration: Duration(seconds: 1),
                        curve: Curves.elasticOut,
                        backgroundColor: Colors.red,
                        textStyle: TextStyle(color: Colors.white),
                        reverseCurve: Curves.fastOutSlowIn);
                  }else if (_passController.text.toString().trim().length < 8) {
                    showToast("Minimul Password Length Is 8 Digit",
                        context: context,
                        animation: StyledToastAnimation.slideFromBottom,
                        reverseAnimation: StyledToastAnimation.slideToBottom,
                        startOffset: Offset(0.0, 3.0),
                        reverseEndOffset: Offset(0.0, 3.0),
                        position: StyledToastPosition.bottom,
                        duration: Duration(seconds: 4),
                        //Animation duration   animDuration * 2 <= duration
                        animDuration: Duration(seconds: 1),
                        curve: Curves.elasticOut,
                        backgroundColor: Colors.red,
                        textStyle: TextStyle(color: Colors.white),
                        reverseCurve: Curves.fastOutSlowIn);
                  }
                  else{
                    DialogHelper.loadingDialog(context);
                    sendOtp();
                  }

                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                login: false,
                press: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginScreen();
                      },
                    ),
                  );
                },
              ),
//            OrDivider(),
//            Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                SocalIcon(
//                  iconSrc: "assets/icons/facebook.svg",
//                  press: () {},
//                ),
//                SocalIcon(
//                  iconSrc: "assets/icons/google-plus.svg",
//                  press: () {},
//                ),
//              ],
//            ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    ));
  }
}
