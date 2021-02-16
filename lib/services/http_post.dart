
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../constants.dart';
import 'enc.dart';

class HttpPost{

  BuildContext context;
  String type;
  List<String> voids;

  HttpPost({this.context,this.type,this.voids,});

  Future<Response> postNow() async{
    Response response =  await post(
      "https://noddys.in/binzo/g4ulbJdqSrAcBQy0Fx5W.php",
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: getBody(type),
      encoding: Encoding.getByName("utf-8"),
    );
    print(response.body);
    print(decrypt(response.body));
//    print(getBody(type));
    return response;
  }


  dynamic getBody(type){
    switch (type){
      case isNumberRegisterPost:
        String data = type+"="+access_key+"&"+userPhone+"="+voids[0];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case registerUserPost:
        String data = type+"="+access_key+"&"+userPhone+"="+voids[0]+"&"+"referral_code"+"="+voids[1]+"&"
        +userPassword+"="+voids[2]+"&"+userNotiKey+"="+voids[3]+"&"+"recapcha_token"+"="+voids[4];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case loginUserPost:
        String data = type+"="+access_key+"&"+userPhone+"="+voids[0]+"&"
            +userPassword+"="+voids[1];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case forgetPasswordPost:
        String data = type+"="+access_key+"&"+userPhone+"="+voids[0]+"&"
            +userPassword+"="+voids[1];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case getProduct:
        String data = type+"="+access_key;
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case buyProduct:
        String data = type+"="+access_key+"&"+userId+"="+voids[0]+"&"
            +"product_id"+"="+voids[1];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case getUserProduct:
        String data = type+"="+access_key+"&"+userId+"="+voids[0];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case getTransactions:
        String data = type+"="+access_key+"&"+userId+"="+voids[0];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case getRedeems:
        String data = type+"="+access_key+"&"+userId+"="+voids[0];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case setRedeem:
        String data = type+"="+access_key+"&"+userId+"="+voids[0]+"&"
            +"redeem_id"+"="+voids[1]+"&"+"redeem_amount"+"="+voids[2];
        return <String, String>{
          "q" : encrypt(data)
        };
        break;
      case getUpi:
        String data = type+"="+access_key;
        return <String, String>{
          "q" : encrypt(data)
        };
      case addMoney:
        String data = type+"="+access_key+"&"+userId+"="+voids[0]+"&"
            +"recharge_amount"+"="+voids[1]+"&"+"txn_id"+"="+voids[2]+"&"+"recapcha_token"+"="+voids[3];
        return <String, String>{
          "q" : encrypt(data)
        };
    }
  }

}