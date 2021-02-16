import 'dart:convert';

import 'package:app/Dialog/dialog_helpers.dart';
import 'package:app/components/already_have_an_account_acheck.dart';
import 'package:app/components/rounded_button.dart';
import 'package:app/components/rounded_input_field.dart';
import 'package:app/components/rounded_password_field.dart';
import 'package:app/screens/forgot_password/forgot_password.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/signup/signup_screen.dart';
import 'package:app/services/enc.dart';
import 'package:app/services/http_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import 'background.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _phoneController = TextEditingController();
  final _passController = TextEditingController();

  Future<void> loginUser() async{
    try{
      HttpPost httpPost = HttpPost(context: context,type: loginUserPost,voids: [_phoneController.text.trim(),_passController.text.trim()]);
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
        Navigator.of(context).pop();
      }else{
        SharedPreferences prefs = await SharedPreferences.getInstance();
        Map<dynamic,dynamic> row = jsonDecode(data["data"]);

        prefs.setBool(isUserLogin, true);
        prefs.setString(userId,row["id"]);
        prefs.setString(userPhone,row["user_phone"]);
        prefs.setString(userPassword,row["user_password"]);
        prefs.setString(userBalance,row["user_balance"]);
        prefs.setString(userBalance1,row["user_balance_1"]);

        List<String> banners = data['banner'].cast<String>();
        prefs.setStringList("banner", banners);

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
            backgroundColor: Colors.green,
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);

        Navigator.of(context).pop();
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(
              builder: (context) {
                return HomeScreen();
              },
            ),
                (route) => false
        );
      }
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
                "Login",
                style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
              ),
              SizedBox(height: size.height * 0.05),
//              kIsWeb ?
//              WebsafeSvg.asset(
//                "assets/icons/shop_icon1.svg",
//                height: size.height * 0.30,
//              ) :
              SvgPicture.asset(
                "assets/icons/login.svg",
                height: size.height * 0.30,
              ),
              SizedBox(height: size.height * 0.05),
              RoundedInputField(
                hintText: "Phone No.",
                controller: _phoneController,
                type: TextInputType.number,
                onChanged: (value) {},
              ),
              RoundedPasswordField(
                onChanged: (value) {},
                controller: _passController,
              ),
              RoundedButton(
                text: "Login",
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

                  }else{
                    if (_passController.text.toString().trim().length < 8) {
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
                    }else{
                      DialogHelper.loadingDialog(context);
                      loginUser();
                    }
                  }
                },
              ),
              SizedBox(height: size.height * 0.03),
              AlreadyHaveAnAccountCheck(
                press: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return SignupScreen();
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 8),
              GestureDetector(
                  onTap: (){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ForgotPassword();
                        },
                      ),
                    );
                  },
                  child: Text("Forgot your password ?",style: TextStyle(color: kPrimaryColor,fontWeight: FontWeight.w600),)
              ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    ));
  }
}
