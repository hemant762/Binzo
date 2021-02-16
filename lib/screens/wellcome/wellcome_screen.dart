import 'dart:convert';

import 'package:app/components/round_icon.dart';
import 'package:app/components/rounded_button.dart';
import 'package:app/constants.dart';
import 'package:app/screens/Privacy/privacy.dart';
import 'package:app/screens/Tnc/tnc.dart';
import 'package:app/screens/home/home_screen.dart';
import 'package:app/screens/login/login_screen.dart';
import 'package:app/screens/signup/signup_screen.dart';
import 'package:app/screens/wellcome/background.dart';
import 'package:app/services/enc.dart';
import 'package:app/services/http_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WellcomeScreen extends StatefulWidget {
  @override
  _WellcomeScreenState createState() => _WellcomeScreenState();
}

class _WellcomeScreenState extends State<WellcomeScreen> {

  Future<bool> _future;

  Future<bool> checkLogin() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    await prefs.clear();
    if (prefs.getBool(isUserLogin) ?? false){
      try{
        HttpPost httpPost = HttpPost(context: context,type: loginUserPost,voids: [prefs.getString(userPhone) ?? "none",prefs.getString(userPassword) ?? "none"]);
        Response response = await httpPost.postNow();
        Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
        if(data["error"]){
          return false;
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

          Navigator.pushAndRemoveUntil(context,
              MaterialPageRoute(
                builder: (context) {
                  return HomeScreen();
                },
              ),
                  (route) => false
          );
          return true;
        }
      }catch(e){
        print("Error : $e");
        return false;
      }
    }else{
      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _future = checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(child: Scaffold(
//        backgroundColor: Colors.white,
        body: FutureBuilder(
          future: _future ,
          builder:(context, snapshot) {
            print("snapshot"+snapshot.toString());
            if (snapshot.data == false) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 100,),
                    Text(
                      "Welcome To Binzo",
                      style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                    ),
                    SizedBox(height: size.height * 0.09),
//                  kIsWeb ?
//                  WebsafeSvg.asset(
//                    "assets/icons/shop_icon.svg",
//                    height: size.height * 0.30,
//                  ) :
                    SvgPicture.asset(
                      "assets/icons/chat.svg",
                      height: size.height * 0.30,
                    ),
                    SizedBox(height: size.height * 0.09),
                    RoundedButton(
                      text: "Login",
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoginScreen();
                            },
                          ),
                        );
                      },
                    ),
                    RoundedButton(
                      text: "Sign Up",
                      color: kPrimaryLightColor,
                      textColor: Colors.black,
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SignupScreen();
                            },
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 15,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: [
                            RoundIcon(
                              iconSrc: Icons.assignment,
                              press: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => TNC(),
                                ));
                              },
                            ),
                            SizedBox(height: 4,),
                            Text("Terms", style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,)
                          ],
                        ),
                        Column(
                          children: [
                            RoundIcon(
                              iconSrc: Icons.security,
                              press: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => Privacy(),
                                ));
                              },
                            ),
                            SizedBox(height: 4,),
                            Text("Policy", style: TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,)
                          ],
                        ),

                      ],
                    ),
                    SizedBox(height: 20,),

                  ],
                ),
              );
            }
            return Container(
              color: Color(0xFFF7F7F7),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                ),
              ),
            );
          },
        )
    ));
  }
}
