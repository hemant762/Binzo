import 'dart:convert';

import 'package:app/Dialog/dialog_helpers.dart';
import 'package:app/components/banner_slider.dart';
import 'package:app/components/rounded_button.dart';
import 'package:app/components/rounded_input_field.dart';
import 'package:app/components/text_field_container.dart';
import 'package:app/constants.dart';
import 'package:app/model/product_data.dart';
import 'package:app/model/redeem_data.dart';
import 'package:app/model/transaction_data.dart';
import 'package:app/screens/Privacy/privacy.dart';
import 'package:app/screens/Tnc/tnc.dart';
import 'package:app/screens/wellcome/wellcome_screen.dart';
import 'package:app/services/enc.dart';
import 'package:app/services/http_post.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_radio_grouped_button/CustomButtons/ButtonTextStyle.dart';
import 'package:custom_radio_grouped_button/CustomButtons/CustomRadioButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:paytm/paytm.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_share/social_share.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../../size_config.dart';
import 'background.dart';
import 'package:g_captcha/g_captcha.dart';
import 'package:upi_india/upi_india.dart';

class HomeScreen extends StatefulWidget {


  @override
  _HomeScreenState createState() => _HomeScreenState();
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel-id', 'fcm', 'androidcoding.in',
        importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.show(
      0,
      message['notification']['title'],
      message['notification']['body'],
      platformChannelSpecifics,
      payload: 'fcm',);
  }

  // Or do other work.
}

class _HomeScreenState extends State<HomeScreen> {

  int pageIndex = 0;
  SharedPreferences prefs;
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  List<ProductData> productsList = [];
  List<TransactionData> transactionsList = [];
  List<RedeemData> redeemsList = [];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  UpiIndia _upiIndia = UpiIndia();



  Future<String> getShareText() async{
    if(prefs != null){
      return "Install Binzo App and Earn Up tp 10% Of Your Invest Every Day\n\nDownload From Below Link and Use My Refer Code to get 10 Rs Bonus.\n\nRefer Code : "+prefs.getString(userId)+"\n\nDownload Link : https://noddys.in/binzo";
    }else{
      prefs = await SharedPreferences.getInstance();
      return "Install Binzo App and Earn Up tp 10% Of Your Invest Every Day\n\nDownload From Below Link and Use My Refer Code to get 10 Rs Bonus.\n\nRefer Code : "+prefs.getString(userId)+"\n\nDownload Link : https://noddys.in/binzo";
    }

  }

  String referCode(){
      if(prefs != null){
        return prefs.getString(userId);
      }else{
        return "";
      }
    }

  String getUserBalance(){
    if(prefs != null){
      return prefs.getString(userBalance);
    }else{
      return "";
    }
  }

  String getUserPhone(){
    if(prefs != null){
      return prefs.getString(userPhone);
    }else{
      return "";
    }
  }

  String getUserBalance1(){
    if(prefs != null){
      return prefs.getString(userBalance1);
    }else{
      return "";
    }
  }

  Future<void> logOut() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await Firebase.initializeApp();
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    if(_firebaseAuth.currentUser != null){
      await _firebaseAuth.signOut();
    }
    Navigator.of(context).pop();
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
      builder: (context) {
        return WellcomeScreen();
      },
    ), (route) => false);
  }

  Future<void> checkAddress() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _addressController.text = prefs.getString("user_address") ?? "";
    _numberController.text = prefs.getString("user_contact") ?? "";
  }

  Future<void> saveAddress() async{
    prefs.setString("user_address",_addressController.text);
    prefs.setString("user_contact",_numberController.text);
    Navigator.of(context).pop();
    Navigator.of(context).pop();

  }

  void _addAddress(BuildContext context){
    _addressController.text = "";
    _numberController.text = "";
    checkAddress();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0),topRight: Radius.circular(25.0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Text("Add Address",style: TextStyle(color: kPrimaryColor,fontSize: 18),),
                SizedBox(height: 20,),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      children: [
                        TextFieldContainer(
                          minHeight:120,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            maxLength: null,
                            maxLines: null,
                            controller: _addressController,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.location_on,
                                color: kPrimaryColor,
                              ),
                              hintText: "Your Address",
                              border: InputBorder.none,
                            ),

                          ),
                        ),
                        TextFieldContainer(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _numberController,
                            cursorColor: kPrimaryColor,
                            decoration: InputDecoration(
                              icon: Icon(
                                Icons.phone,
                                color: kPrimaryColor,
                              ),
                              hintText: "Contact Number",
                              border: InputBorder.none,
                            ),

                          ),
                        ),
                        RoundedButton(
                          text: "Save Address",
                          press: () {
                            if (_addressController.text.toString().trim().length == 0){
                              showToast("Enter Valid Address",
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
                                  backgroundColor: Colors.red[600],
                                  textStyle: TextStyle(color: Colors.white),
                                  reverseCurve: Curves.fastOutSlowIn);

                            }else{
                              if (_numberController.text.toString().trim().length != 10) {
                                showToast("Enter Valid Contact Detail",
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
                                    backgroundColor: Colors.red[600],
                                    textStyle: TextStyle(color: Colors.white),
                                    reverseCurve: Curves.fastOutSlowIn);

                              }else{
                                DialogHelper.loadingDialog(context);
                                saveAddress();
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }


  Future displayNotification(Map<String, dynamic> message) async{
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'android', 'android', 'android',
      importance: Importance.max, priority: Priority.high,);
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      message['notification']['title'],
      message['notification']['body'],
      platformChannelSpecifics,
      payload: "paylod",);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void>  init() async{
    prefs = await SharedPreferences.getInstance();
    var initializationSettingsAndroid = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = new InitializationSettings(
        android: initializationSettingsAndroid, iOS: null);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) {
        print('on message $message');
        displayNotification(message);
        return;
      },

      onResume: (Map<String, dynamic> message) {
        print('on resume $message');
//        displayNotification(message);
        return;
      },
      onLaunch: (Map<String, dynamic> message) {
        print('on launch $message');
//        displayNotification(message);
        return;
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
//    _firebaseMessaging.getToken().then((String token) {
//      assert(token != null);
//      print(token);
//    });
  }

  Future<bool> getProducts() async{
    try{
      HttpPost httpPost = HttpPost(
          type: getProduct,
          context: context,
          voids: []
      );
      Response response = await httpPost.postNow();
      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
      if(data["error"]){
        showToast(data["message"],
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
            backgroundColor: Colors.red[600],
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        return false;
      }else{
        productsList.clear();
        data['products'].forEach((product) {
          ProductData productData = ProductData(
              imgUrl: product['product_img'],
              productName: product['product_name'],
              id: product["id"],
              productPrice: product['product_price'],
              intrest: product['intrest']
          );
          productsList.add(productData);
        });
        return true;
      }

    }catch(e) {
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
          backgroundColor: Colors.red[600],
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
    }
    return false;
  }

  Future<bool> getUserProducts() async{
    if(prefs == null){
      prefs = await SharedPreferences.getInstance();
    }
    try{
      HttpPost httpPost = HttpPost(
          type: getUserProduct,
          context: context,
          voids: [prefs.getString(userId)]
      );
      Response response = await httpPost.postNow();
      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
      if(data["error"]){
        showToast(data["message"],
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
            backgroundColor: Colors.red[600],
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        return false;
      }else{
        productsList.clear();
        data['products'].forEach((product) {
          ProductData productData = ProductData(
              imgUrl: product['product_img'],
              productName: product['product_name'],
              id: product["id"],
              productPrice: product['product_price'],
              intrest: product['intrest']
          );
          productsList.add(productData);
        });
        return true;
      }

    }catch(e) {
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
          backgroundColor: Colors.red[600],
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
    }
    return false;
  }

  Future<bool> getTransactionsFunction() async{
    try{
      HttpPost httpPost = HttpPost(
          type: getTransactions,
          context: context,
          voids: [prefs.getString(userId)]
      );
      Response response = await httpPost.postNow();
      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
      if(data["error"]){
        showToast(data["message"],
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
            backgroundColor: Colors.red[600],
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        return false;
      }else{
        if(!(prefs.getString(userBalance) == data['user_balance'] && prefs.getString(userBalance1) == data['user_balance_1'])){
          prefs.setString(userBalance,data["user_balance"]);
          prefs.setString(userBalance1,data["user_balance_1"]);
          setState(() {});
        }
        transactionsList.clear();
        data['data'].forEach((element) {
          transactionsList.add(TransactionData(id:element["id"], title:element["title"], amount:element["amount"], date:element["time"]));
        });
        return true;
      }

    }catch(e) {
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
          backgroundColor: Colors.red[600],
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
    }
    return false;
  }

  Future<bool> getRedeemsFunction() async{
    try{
      HttpPost httpPost = HttpPost(
          type: getRedeems,
          context: context,
          voids: [prefs.getString(userId)]
      );
      Response response = await httpPost.postNow();
      Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
      if(data["error"]){
        showToast(data["message"],
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
            backgroundColor: Colors.red[600],
            textStyle: TextStyle(color: Colors.white),
            reverseCurve: Curves.fastOutSlowIn);
        return false;
      }else{
        redeemsList.clear();
        data['data'].forEach((element) {
          String _status;
          Color _status_color;
          if(element["status"] == "1"){
            _status = "Success";
            _status_color = Colors.green;
          }else if (element["status"] == "0"){
            _status = "Panding";
            _status_color = Colors.amber;
          }else{
            _status = "Cancel";
            _status_color = Colors.red;
          }
          redeemsList.add(
              RedeemData(id:element["id"], title:element["title"], amount:element["amount"], date:element["time"],redeem_id: element["redeem_id"],status: _status,status_color: _status_color)
          );
        });
        return true;
      }

    }catch(e) {
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
          backgroundColor: Colors.red[600],
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
    }
    return false;
  }

  void redeemMoney(){
    String paytm_number="";
    String redeem_amount="";
    Alert(
        context: context,
        title: "Redeem Now",
        content: Column(
          children: <Widget>[
            SizedBox(height: 15,),

            RoundedInputField(
              hintText: "Enter Paytm Number",
              type: TextInputType.number,
              onChanged: (value) =>paytm_number=value,
            ),

            SizedBox(height: 10,),

            CustomRadioButton(
              elevation: 0,
              absoluteZeroSpacing: false,
              unSelectedColor: Colors.white,
              padding: 5,
              enableButtonWrap: true,
              buttonLables: [
                '$rupee 400',
                '$rupee 600',
                '$rupee 800',
                '$rupee 1000',
              ],
              buttonValues: [
                "400",
                "600",
                "800",
                "1000"
              ],
              buttonTextStyle: ButtonTextStyle(
                  selectedColor: Colors.white,
                  unSelectedColor: kPrimaryColor,
                  textStyle: TextStyle(fontSize: 16)),
              radioButtonValue: (value) {
                redeem_amount = value;
              },
              selectedColor: kPrimaryColor,
              unSelectedBorderColor: kPrimaryColor,
              selectedBorderColor: kPrimaryColor,
            ),

          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async{
              if(paytm_number.length != 10){
                showToast("Enter Valid Paytm Number",
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
                    backgroundColor: Colors.red[600],
                    textStyle: TextStyle(color: Colors.white),
                    reverseCurve: Curves.fastOutSlowIn);
              }else if(redeem_amount.length == 0 ){
                showToast("Select Redeem Amount",
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
                    backgroundColor: Colors.red[600],
                    textStyle: TextStyle(color: Colors.white),
                    reverseCurve: Curves.fastOutSlowIn);
              }else if(int.parse(getUserBalance1()) < int.parse(redeem_amount)){
                Navigator.pop(context);
                Alert(
                  context: context,
                  type: AlertType.warning,
                  title: "Error",
                  content: Column(
                    children: [
                      SizedBox(height: 5,),
                      Text("You not have enough money to make this redeem request.",textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                      SizedBox(height: 5,),
                    ],
                  ),
                  buttons: [
                    DialogButton(
                      child: Text(
                        "Close",
                        style: TextStyle(color: kPrimaryColor, fontSize: 20),
                      ),
                      onPressed: () => Navigator.pop(context),
                      color: kPrimaryLightColor,
                      radius: BorderRadius.circular(5),
                    ),
                  ],
                ).show();
              }else{
                Navigator.pop(context);
                DialogHelper.loadingDialog(context);
                if(prefs == null){
                  prefs = await SharedPreferences.getInstance();
                }
                HttpPost httpPost = HttpPost(
                    type: setRedeem,
                    context: context,
                    voids: [prefs.getString(userId),paytm_number,redeem_amount]
                );
                Response response = await httpPost.postNow();
                Navigator.pop(context);
                Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));

                if(data["error"]){
                  Alert(
                    context: context,
                    type: AlertType.error,
                    title: "Error",
                    content: Column(
                      children: [
                        SizedBox(height: 5,),
                        Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                        SizedBox(height: 5,),
                      ],
                    ),
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Close",
                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: kPrimaryLightColor,
                        radius: BorderRadius.circular(5),
                      ),
                    ],
                  ).show();

                }else{
                  prefs.setString(userBalance1, data["user_balance_1"]);
                  Alert(
                    context: context,
                    type: AlertType.success,
                    title: "Success",
                    content: Column(
                      children: [
                        SizedBox(height: 5,),
                        Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                        SizedBox(height: 5,),
                      ],
                    ),
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Close",
                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: kPrimaryLightColor,
                        radius: BorderRadius.circular(5),
                      ),
                    ],
                  ).show();
                  setState(() {});
                }

              }

              },
            child: Text(
              "Redeem",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }


  void addMoneyFunction(){
    int recharge_amount=0;
    Alert(
        context: context,
        title: "Add Cash",
        content: Column(
          children: <Widget>[
            SizedBox(height: 15,),

            CustomRadioButton(
              elevation: 0,
              absoluteZeroSpacing: false,
              unSelectedColor: Colors.white,
              padding: 5,
              enableButtonWrap: true,
              buttonLables: [
                '$rupee 400',
                '$rupee 600',
                '$rupee 800',
                '$rupee 1000',
              ],
              buttonValues: [
                400,
                600,
                800,
                1000
              ],
              buttonTextStyle: ButtonTextStyle(
                  selectedColor: Colors.white,
                  unSelectedColor: kPrimaryColor,
                  textStyle: TextStyle(fontSize: 16)),
              radioButtonValue: (value) {
                recharge_amount = value;
              },
              selectedColor: kPrimaryColor,
              unSelectedBorderColor: kPrimaryColor,
              selectedBorderColor: kPrimaryColor,
            ),

          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () async{
              String recapcha_token;
              if(recharge_amount == 0 ){
                showToast("Select Amount For Recharge",
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
                    backgroundColor: Colors.red[600],
                    textStyle: TextStyle(color: Colors.white),
                    reverseCurve: Curves.fastOutSlowIn);
              }else{
                Navigator.pop(context);
                DialogHelper.loadingDialog(context);
                HttpPost httpPost = HttpPost(
                    type: getUpi,
                    context: context,
                    voids: []
                );

                try{
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
                  }
                  else {
                    String reciver_upi = data['upi'];
                    String reciver_name = data['name'];
                    String orderId = DateTime.now().millisecondsSinceEpoch.toString();
                    recapcha_token = await GCaptcha.reCaptcha(CAPTCHA_SITE_KEY);
                    List<UpiApp> apps = await _upiIndia.getAllUpiApps(includeOnly: [UpiApp.googlePay,UpiApp.phonePe,UpiApp.paytm,UpiApp.amazonPay]);
                    _upiIndia.startTransaction(
                      app: apps[0],
                      receiverUpiId: reciver_upi,
                      receiverName: reciver_name,
                      transactionRefId: orderId,
                      transactionNote: 'Binzo App $recharge_amount Payment.',
                      amount: recharge_amount.toDouble(),
                    ).then((value) async{
                      if (value.status == "success"){
                        DialogHelper.loadingDialog(context);
                        if(prefs == null){
                          prefs = await SharedPreferences.getInstance();
                        }
                        HttpPost httpPost = HttpPost(
                            type: addMoney,
                            context: context,
                            voids: [prefs.getString(userId),recharge_amount.toString(),value.transactionId,recapcha_token]
                        );
                        Response response = await httpPost.postNow();
                        Navigator.pop(context);
                        Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));

                        if(data["error"]){
                          Alert(
                            context: context,
                            type: AlertType.error,
                            title: "Error",
                            content: Column(
                              children: [
                                SizedBox(height: 5,),
                                Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                                SizedBox(height: 5,),
                              ],
                            ),
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "Close",
                                  style: TextStyle(color: kPrimaryColor, fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                color: kPrimaryLightColor,
                                radius: BorderRadius.circular(5),
                              ),
                            ],
                          ).show();

                        }else{
                          prefs.setString(userBalance, data["user_balance"]);
                          Alert(
                            context: context,
                            type: AlertType.success,
                            title: "Success",
                            content: Column(
                              children: [
                                SizedBox(height: 5,),
                                Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                                SizedBox(height: 5,),
                              ],
                            ),
                            buttons: [
                              DialogButton(
                                child: Text(
                                  "Close",
                                  style: TextStyle(color: kPrimaryColor, fontSize: 20),
                                ),
                                onPressed: () => Navigator.pop(context),
                                color: kPrimaryLightColor,
                                radius: BorderRadius.circular(5),
                              ),
                            ],
                          ).show();
                          setState(() {});
                        }
                      }else{

                        Alert(
                          context: context,
                          type: AlertType.error,
                          title: "Payment Cancel",
                          content: Column(
                            children: [
                              SizedBox(height: 5,),
                              Text("Your payment hase been canceled please retry.",textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                              SizedBox(height: 5,),
                            ],
                          ),
                          buttons: [
                            DialogButton(
                              child: Text(
                                "Close",
                                style: TextStyle(color: kPrimaryColor, fontSize: 20),
                              ),
                              onPressed: () => Navigator.pop(context),
                              color: kPrimaryLightColor,
                              radius: BorderRadius.circular(5),
                            ),
                          ],
                        ).show();
                      }
                    });

                  }

                }catch(e){
                  print("Error : $e");
                  showToast("Please Retry",
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
                Navigator.pop(context);
//                DialogHelper.loadingDialog(context);
//                if(prefs == null){
//                  prefs = await SharedPreferences.getInstance();
//                }
//                HttpPost httpPost = HttpPost(
//                    type: addMoney,
//                    context: context,
//                    voids: [prefs.getString(userId),recharge_amount]
//                );
//                Response response = await httpPost.postNow();
//                Navigator.pop(context);
//                Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
//
//                if(data["error"]){
//                  Alert(
//                    context: context,
//                    type: AlertType.error,
//                    title: "Error",
//                    content: Column(
//                      children: [
//                        SizedBox(height: 5,),
//                        Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
//                        SizedBox(height: 5,),
//                      ],
//                    ),
//                    buttons: [
//                      DialogButton(
//                        child: Text(
//                          "Close",
//                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
//                        ),
//                        onPressed: () => Navigator.pop(context),
//                        color: kPrimaryLightColor,
//                        radius: BorderRadius.circular(5),
//                      ),
//                    ],
//                  ).show();
//
//                }else{
//                  prefs.setString(userBalance1, data["user_balance_1"]);
//                  Alert(
//                    context: context,
//                    type: AlertType.success,
//                    title: "Success",
//                    content: Column(
//                      children: [
//                        SizedBox(height: 5,),
//                        Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
//                        SizedBox(height: 5,),
//                      ],
//                    ),
//                    buttons: [
//                      DialogButton(
//                        child: Text(
//                          "Close",
//                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
//                        ),
//                        onPressed: () => Navigator.pop(context),
//                        color: kPrimaryLightColor,
//                        radius: BorderRadius.circular(5),
//                      ),
//                    ],
//                  ).show();
//                  setState(() {});
//                }

              }

            },
            color: kPrimaryLightColor,
            child: Text(
              "Add Cash",
              style: TextStyle(color: kPrimaryColor, fontSize: 20),
            ),
          )
        ]).show();
  }


  Widget currentPage(){
    switch (pageIndex){
      case 0:
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            BannerSlider(),
            SizedBox(
              height: 20,
            ),
            Text("Buy Power Bank And Start Earning",),
            Expanded(
              child: FutureBuilder(
                future: getProducts(),
                builder:(context, snapshot) {
                  if (snapshot.data != null) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: productsList.length,
                          itemBuilder: (context,index){
                            return ProductTile(
                              data: productsList[index],
                              rechargeNow: (){
                                setState(() {
                                  pageIndex=3;
                                });
                              },
                              context: context,
                            );
                          }
                      ),
                    );
                  }
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [

                          Expanded(
                            child: ListView.builder(
                                itemCount: 6,
                                itemBuilder: (ctx, index){
                                  return  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.white24,
                                      highlightColor: Colors.grey[100],
                                      child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey[100]
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0) //                 <--- border radius here
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: ClipRRect(
                                                  child: Container(width: 110,height: 110,color: Colors.white,),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                              SizedBox(width: 10,),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(height: 5,),
                                                    Container(width: 200,height: 20,color: Colors.white,),

                                                    SizedBox(height: 5,),

                                                    Container(width: 150,height: 20,color: Colors.white,),

                                                    SizedBox(height: 5,),

                                                    Container(width: 150,height: 20,color: Colors.white,),

                                                    SizedBox(height: 5,),

                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 5,),
                                            ],
                                          )
                                      ),
                                    ),
                                  );
                                }
                            ),
                          ),

                        ],
                      )
                  );
                },
              ),
            )
          ],
        );
        break;
      case 1:
        return FutureBuilder(
          future: getUserProducts(),
          builder:(context, snapshot) {
            if (snapshot.data != null) {
              return productsList.length == 0 ?
              Container(
                child: Center(
                  child: Column(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/svg/cart.svg",width: 100,height: 100,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                              child: Text("You Not Buy Any Power Bank Yet.\nBuy A Power Bank And Start Your Earning.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: kPrimaryColor
                                ),),
                            ),
                            SizedBox(height: 10,),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  pageIndex=0;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(color: kPrimaryColor)
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 7),
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      SizedBox(width: 15,),
                                      Text("Buy Power Bank",style: TextStyle(color: kPrimaryColor,fontSize: 17),),
                                      SizedBox(width: 15,),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  :
              Column(
                children: [
                  SizedBox(height: 10,),
                  Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text("My Power Bank",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w500,
                                  color: kPrimaryColor,
                                ),),
                            ),
                          )
                        ],
                      ),
//                  Padding(
//                    padding: const EdgeInsets.only(left: 8,top: 8),
//                    child: IconButton(
//                      icon: Icon(
//                        Icons.close,
//                        size: 30,
//                        color: kPrimaryColor,
//                      ),
//                      onPressed: () {
//                        if (Navigator.canPop(context)) {
//                          Navigator.pop(context);
//                        } else {
//                          SystemNavigator.pop();
//                        }
//                      },
//                    ),
//                  ),
                    ],
                  ),
                  SizedBox(height: 10,),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: productsList.length,
                          itemBuilder: (context,index){
                            return ProductTileCart(
                              data: productsList[index],
                            );
                          }
                      ),
                    ),
                  ),
                ],
              );
            }
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [

                    Expanded(
                      child: ListView.builder(
                          itemCount: 6,
                          itemBuilder: (ctx, index){
                            return  Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                              child: Shimmer.fromColors(
                                baseColor: Colors.white24,
                                highlightColor: Colors.grey[100],
                                child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.grey[100]
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0) //                 <--- border radius here
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ClipRRect(
                                            child: Container(width: 110,height: 110,color: Colors.white,),
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(height: 5,),
                                              Container(width: 200,height: 20,color: Colors.white,),

                                              SizedBox(height: 5,),

                                              Container(width: 150,height: 20,color: Colors.white,),

                                              SizedBox(height: 5,),

                                              Container(width: 150,height: 20,color: Colors.white,),

                                              SizedBox(height: 5,),

                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 5,),
                                      ],
                                    )
                                ),
                              ),
                            );
                          }
                      ),
                    ),

                  ],
                )
            );
          },
        );
        break;
      case 2:
        return Container(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              SizedBox(height: 10,),

              Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text("Invite And Earn",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryColor,
                            ),),
                        ),
                      )
                    ],
                  ),
//                  Padding(
//                    padding: const EdgeInsets.only(left: 8,top: 8),
//                    child: IconButton(
//                      icon: Icon(
//                        Icons.close,
//                        size: 30,
//                        color: kPrimaryColor,
//                      ),
//                      onPressed: () {
//                        if (Navigator.canPop(context)) {
//                          Navigator.pop(context);
//                        } else {
//                          SystemNavigator.pop();
//                        }
//                      },
//                    ),
//                  ),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      SizedBox(
                        height: 35.0,
                      ),

                      Center(
                        child: Image.asset("assets/images/refer.jpg",height: 200,width: 200,fit: BoxFit.cover,),
                      ),

                      SizedBox(height: 10.0,),


                      Center(
                        child: Text(
                          "$rupee 10",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 50.0
                          ),
                        ),
                      ),

                      SizedBox(height: 5.0,),

                      Center(
                        child: Text(
                          "Invite Your Friend And Get",
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 18.0,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),


                      SizedBox(height: 20.0,),

                      GestureDetector(
                        onTap: () {
                          SocialShare.copyToClipboard(referCode());
//                          HapticFeedback.mediumImpact();
                          Vibration.vibrate(duration: 200);
                          showToast("Refer Code Copied",
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
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                                  color: kPrimaryColor
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 30,top: 15,right: 30,bottom: 15),
                              child: Text(referCode(),textAlign: TextAlign.center,style: TextStyle(fontSize: 20,fontWeight: FontWeight.w600,color: kPrimaryColor),),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0,),


                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: FloatingActionButton(
                                child: SvgPicture.asset("assets/icons/whatsapp.svg",height: 30,),
                                backgroundColor: Colors.white,
                                onPressed: () async{
                                  String text = await getShareText();
                                  SocialShare.shareWhatsapp(text);
                                },
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: FloatingActionButton(
                                child: SvgPicture.asset("assets/icons/telegram.svg",height: 30,),
                                backgroundColor: Colors.white,
                                onPressed: () async {
                                  String text = await getShareText();
                                  SocialShare.shareTelegram(text);
                                },
                              ),
                            ),





                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: FloatingActionButton(
                                child: SvgPicture.asset("assets/icons/more.svg",height: 35,),
                                backgroundColor: Colors.white,
                                onPressed: () async{
                                  String text = await getShareText();
                                  SocialShare.shareOptions(text);
                                },
                              ),
                            )
                          ],
                        ),
                      ),


                      SizedBox(height: 10.0,),


                      Text("Share On Social Media",style: TextStyle(color: Colors.grey,fontSize: 12),)



                    ],
                  ),
                ),
              ),





            ],
          ),
        );
        break;
      case 3:
        return Column(
          children: [

            SizedBox(height: 10,),

            Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text("Wallet",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                            color: kPrimaryColor,
                          ),),
                      ),
                    )
                  ],
                ),
              ],
            ),

            Row(
              children: [

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 1.5,
                            color: kPrimaryColor
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0) //                 <--- border radius here
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                        child: Column(
                          children: [
                            SizedBox(height: 10,),
                            Text("Cash Balance",style: TextStyle(color:kPrimaryColor),),
                            SizedBox(height: 10,),
                            Text(rupee+" "+getUserBalance(),style: TextStyle(fontSize: 25,color:kPrimaryColor,fontWeight: FontWeight.w600),),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    child: Text("Add Cash",style: TextStyle(color:kPrimaryColor),),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateColor.resolveWith((states) => kPrimaryLightColor),
                                    ),
                                    onPressed: () {
                                      addMoneyFunction();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],

                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            width: 1.5,
                            color: kPrimaryColor
                        ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(10.0) //                 <--- border radius here
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                        child: Column(
                          children: [
                            SizedBox(height: 10,),
                            Text("Redeemable",style: TextStyle(color:kPrimaryColor),),
                            SizedBox(height: 10,),
                            Text(rupee+" "+getUserBalance1(),style: TextStyle(fontSize: 25,color:kPrimaryColor,fontWeight: FontWeight.w600),),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    child: Text("Redeem",style: TextStyle(color:kPrimaryColor),),
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateColor.resolveWith((states) => kPrimaryLightColor),
                                    ),
                                    onPressed: () {
                                      redeemMoney();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],

                        ),
                      ),
                    ),
                  ),
                )

              ],
            ),


            Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: DefaultTabController(
                  length: 2,
                  child: Scaffold(
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(kToolbarHeight),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 50.0,
                          child: TabBar(
                            tabs: [
                              Tab(text: "Wallet History"),
                              Tab(text: "Redeem History"),
                            ],
                            indicatorColor: kPrimaryColor,
                            labelColor: kPrimaryColor,
                            unselectedLabelColor: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    body: TabBarView(
                      children: [


                        Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: FutureBuilder(
                              future: getTransactionsFunction(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return transactionsList.length == 0 ?
                                  Container(
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Image.asset("assets/transaction_icon.jpg",width: 80,height: 80,),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                                                  child: Text("No Wallet History.",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: kPrimaryColor
                                                    ),),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      :
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: transactionsList.length,
                                        itemBuilder: (context,index){
                                          return TransactionTile(
                                            d: transactionsList[index],
                                          );
                                        }
                                    ),
                                  );
                                }
                                return Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Column(
                                      children: [

                                        Expanded(
                                          child: ListView.builder(
                                              itemCount: 6,
                                              itemBuilder: (ctx, index){
                                                return  Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Shimmer.fromColors(
                                                    baseColor: Colors.white24,
                                                    highlightColor: Colors.grey[100],
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Colors.grey[100]
                                                          ),
                                                          borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0) //                 <--- border radius here
                                                          ),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Expanded(
                                                              child: ClipRRect(
                                                                child: Container(height: 80,color: Colors.white,),
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                  ),
                                                );
                                              }
                                          ),
                                        ),

                                      ],
                                    )
                                );
                              },
                            )

                        ),

                        Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder(
                              future: getRedeemsFunction(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return redeemsList.length == 0 ?
                                  Container(
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Image.asset("assets/transaction_icon.jpg",width: 80,height: 80,),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 8),
                                                  child: Text("No Redeem History.",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 17,
                                                        color: kPrimaryColor
                                                    ),),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                      :
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: redeemsList.length,
                                        itemBuilder: (context,index){
                                          return RedeemTile(
                                            d: redeemsList[index],
                                          );
                                        }
                                    ),
                                  );
                                }
                                return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [

                                        Expanded(
                                          child: ListView.builder(
                                              itemCount: 6,
                                              itemBuilder: (ctx, index){
                                                return  Padding(
                                                  padding: const EdgeInsets.all(4.0),
                                                  child: Shimmer.fromColors(
                                                    baseColor: Colors.white24,
                                                    highlightColor: Colors.grey[100],
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(
                                                              width: 1,
                                                              color: Colors.grey[100]
                                                          ),
                                                          borderRadius: BorderRadius.all(
                                                              Radius.circular(10.0) //                 <--- border radius here
                                                          ),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          children: [
                                                            Expanded(
                                                              child: ClipRRect(
                                                                child: Container(height: 80,color: Colors.white,),
                                                                borderRadius: BorderRadius.circular(10.0),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                    ),
                                                  ),
                                                );
                                              }
                                          ),
                                        ),

                                      ],
                                    )
                                );
                              },
                            )

                        ),


                      ],
                    ),
                  ),
                )
              ),
            ),

          ],
        );
        break;
      case 4:
        return Container(
          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              SizedBox(height: 10,),
              Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text("My Profile",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: kPrimaryColor,
                            ),),
                        ),
                      )
                    ],
                  ),
                ],
              ),



              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      SizedBox(
                        height: 25.0,
                      ),

                      Center(
                        child: Image.asset("assets/images/profile.png",height: 90,),
                      ),

                      SizedBox(height: 10.0,),

                      Center(
                        child: Text(
                          "Welcome",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 13.0
                          ),
                        ),
                      ),

                      SizedBox(height: 1.0,),

                      Center(
                        child: Text(
                          "+91 "+ prefs.getString(userPhone),
                          style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 17.0
                          ),
                        ),
                      ),

                      SizedBox(height: 20.0,),



                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Divider(
                          height: 1.5,
                          color: kPrimaryColor,
                        ),
                      ),

                      SizedBox(height: 20.0,),



                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () {
                            _addAddress(context);
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                                  color: kPrimaryColor
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  SvgPicture.asset(
                                    "assets/svg/map.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Add Default Address",
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => Privacy(),
                            ));
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                                  color: kPrimaryColor
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0)
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  SvgPicture.asset(
                                    "assets/icons/privacy.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Privacy Policy",
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => TNC(),
                            ));
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                                  color: kPrimaryColor
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  SvgPicture.asset(
                                    "assets/icons/tnc.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Terms & Condition",
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () async{
                            if (await canLaunch(telegramUrl)) {
                            await launch(telegramUrl);
                            } else {
                            throw 'Could not launch $telegramUrl';
                            }
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                                  color: kPrimaryColor
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  SvgPicture.asset(
                                    "assets/icons/telegram.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Help & Support",
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                        child: GestureDetector(

                          onTap: () {
                            logOut();
                          },

                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  width: 1.5,
                                  color: kPrimaryColor
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10.0) //                 <--- border radius here
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                              child: Row(
                                children: [

                                  SvgPicture.asset(
                                    "assets/icons/exit.svg",
                                    height: 40,
                                    width: 40,
                                  ),

                                  SizedBox(width: 10,),

                                  Expanded(
                                    child: Text("Logout Or Exit",
                                      style: TextStyle(
                                        color: kPrimaryColor,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w400,
                                      ),),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),





            ],
          ),
        );
        break;
      default:
        return Container();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  Widget build(BuildContext context) {
    // It help us to  make our UI responsive
    SizeConfig().init(context);
    return Background(
        child: Scaffold(
          body: SafeArea(
            child: currentPage(),
          ),
          bottomNavigationBar: TitledBottomNavigationBar(
            reverse: true,
            currentIndex: pageIndex,
            onTap: (index){
              setState(() {
                pageIndex = index;
              });
              print("Selected Index: $index");
            },
            items: [
              TitledNavigationBarItem(title: Text('Home',style: TextStyle(fontWeight: FontWeight.bold),), icon: Icons.home),
              TitledNavigationBarItem(title: Text('Product',style: TextStyle(fontWeight: FontWeight.bold)), icon: Icons.shopping_cart),
              TitledNavigationBarItem(title: Text('Invite',style: TextStyle(fontWeight: FontWeight.bold)), icon: Icons.share),
              TitledNavigationBarItem(title: Text('Wallet',style: TextStyle(fontWeight: FontWeight.bold)), icon: Icons.account_balance_wallet_outlined),
              TitledNavigationBarItem(title: Text('Profile',style: TextStyle(fontWeight: FontWeight.bold)), icon: Icons.person_outline),
            ],
            inactiveColor: kPrimaryColor,

//            tabs: [
//              TabData(iconData: Icons.home, title: "Home"),
//              TabData(iconData: Icons.shopping_cart, title: "Investment"),
//              TabData(iconData: Icons.group, title: "Team"),
//              TabData(iconData: Icons.person, title: "Profile")
//            ],
//            onTabChangedListener: (position) {
//              setState(() {
////                currentPage = position;
//              });
//            },
//            textColor: Colors.black,
//            circleColor: kPrimaryColor,
//            inactiveIconColor: kPrimaryColor,
          ),
    ));
  }

}


class ProductTile extends StatelessWidget {

  final ProductData data;
  final BuildContext context;
  final Function rechargeNow;

  const ProductTile({Key key, this.data, this.context, this.rechargeNow}) : super(key: key);

  Future<void> buyPowerBank(String id,String price) async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if(int.parse(prefs.getString(userBalance)) >= int.parse(price)) {
        Alert(
          context: context,
          type: AlertType.info,
          title: "Are You Sure ?",
          content: Column(
            children: [
              SizedBox(height: 5,),
              Text("You want to buy "+rupee+" "+price+" (Level "+id+") Power Bank",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
              SizedBox(height: 5,),
            ],
          ),
          buttons: [
            DialogButton(
              child: Text(
                "Buy Now",
                style: TextStyle(color: kPrimaryColor, fontSize: 20),
              ),
              onPressed: () async{
                Navigator.pop(context);
                DialogHelper.loadingDialog(context);
                HttpPost httpPost = HttpPost(
                    type: buyProduct,
                    context: context,
                    voids: [prefs.getString(userId),id]
                );
                Response response = await httpPost.postNow();
                Map<dynamic,dynamic> data = jsonDecode(decrypt(response.body));
                Navigator.pop(context);
                if(data["error"]){
                  Alert(
                    context: context,
                    type: AlertType.error,
                    title: "Error",
                    content: Column(
                      children: [
                        SizedBox(height: 5,),
                        Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                        SizedBox(height: 5,),
                      ],
                    ),
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Close",
                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: kPrimaryLightColor,
                        radius: BorderRadius.circular(5),
                      ),
                    ],
                  ).show();

                }else{
                  prefs.setString(userBalance, data["user_balance"]);
                  Alert(
                    context: context,
                    type: AlertType.success,
                    title: "Success",
                    content: Column(
                      children: [
                        SizedBox(height: 5,),
                        Text(data["message"],textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
                        SizedBox(height: 5,),
                      ],
                    ),
                    buttons: [
                      DialogButton(
                        child: Text(
                          "Close",
                          style: TextStyle(color: kPrimaryColor, fontSize: 20),
                        ),
                        onPressed: () => Navigator.pop(context),
                        color: kPrimaryLightColor,
                        radius: BorderRadius.circular(5),
                      ),
                    ],
                  ).show();
                }
              },
              color: kPrimaryLightColor,
              radius: BorderRadius.circular(5),
            ),
          ],
        ).show();
      }
      else{
        Alert(
          context: context,
          type: AlertType.error,
          title: "Low Balance",
          content: Column(
            children: [
              SizedBox(height: 5,),
              Text("Not enough money to buy power bank recharge your wallet.",textAlign:TextAlign.center,style: TextStyle(fontSize: 14)),
              SizedBox(height: 5,),
            ],
          ),
          buttons: [
            DialogButton(
              child: Text(
                "Close",
                style: TextStyle(color: kPrimaryColor, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              color: kPrimaryLightColor,
              radius: BorderRadius.circular(5),
            ),

            DialogButton(
              child: Text(
                "Recharge",
                style: TextStyle(color: kPrimaryColor, fontSize: 20),
              ),
              onPressed: () {
                Navigator.pop(context);
                rechargeNow.call();
              },
              color: kPrimaryLightColor,
              radius: BorderRadius.circular(5),
            ),
          ],
        ).show();

      }

    }catch(e) {
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
          backgroundColor: Colors.red[600],
          textStyle: TextStyle(color: Colors.white),
          reverseCurve: Curves.fastOutSlowIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: GestureDetector(
        onTap: () {
//          _showProductDetails(context,widget.data);
        },
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  width: 0,
                  color: kPrimaryColor.withOpacity(0.4)
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0) //                 <--- border radius here
              ),
            ),
            child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: ClipRRect(
                          child: FadeInImage(
                            placeholder: AssetImage("assets/spinner.gif"),
                            width: 90,height: 90,fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(data.imgUrl),
                          ),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10)),
                        ),
                      ),
                      SizedBox(width: 15,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10,),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(data.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: kPrimaryColor,

                                    ),),
                                ),
                                SizedBox(width: 45,),
                              ],
                            ),

                            SizedBox(height: 8,),

                            Row(
                              children: [


//                                SizedBox(width: 25,),


                                Text(data.intrest+"%",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200
                                  ),),

                                SizedBox(width: 6,),

                                Text("Intrest Every Day",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),),
                              ],
                            ),

                            Row(
                              children: [
                                Text(rupee+" "+data.productPrice,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600
                                  ),),

                                SizedBox(width: 6,),

                                Text(rupee+" "+data.productPrice,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.lineThrough
                                  ),),
                                Expanded(
                                  child: Container(),
                                ),
                                TextButton(
                                  child: Text("Buy Now",style: TextStyle(color:kPrimaryColor),),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateColor.resolveWith((states) => kPrimaryLightColor),
                                  ),
                                  onPressed: () {
                                    buyPowerBank(data.id,data.productPrice);
                                  },
                                ),
                              ],
                            ),

                            SizedBox(height: 2,),

                            SizedBox(height: 5,),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text("Level "+data.id,style: TextStyle(fontSize: 12,color: Colors.white),),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            )
                        ),
                      )
                    ],
                  )
                ]
            )
        ),
      ),
    );
  }
}

class ProductTileCart extends StatelessWidget {

  final ProductData data;

  const ProductTileCart({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
      child: GestureDetector(
        onTap: () {
//          _showProductDetails(context,widget.data);
        },
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  width: 0,
                  color: kPrimaryColor.withOpacity(0.4)
              ),
              borderRadius: BorderRadius.all(
                  Radius.circular(10.0) //                 <--- border radius here
              ),
            ),
            child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: ClipRRect(
                          child: FadeInImage(
                            placeholder: AssetImage("assets/spinner.gif"),
                            width: 90,height: 90,fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(data.imgUrl),
                        ),
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10)),
                        ),
                      ),
                      SizedBox(width: 15,),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 10,),

                            Row(
                              children: [
                                Expanded(
                                  child: Text(data.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.5,
                                      color: kPrimaryColor,

                                    ),),
                                ),
                                SizedBox(width: 45,),
                              ],
                            ),

                            SizedBox(height: 5,),

                            Row(
                              children: [


//                                SizedBox(width: 25,),


                                Text(data.intrest+"%",
                                  style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w200
                                  ),),

                                SizedBox(width: 6,),

                                Text("Intrest Every Day",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),),
                              ],
                            ),

                            Row(
                              children: [
                                Text(rupee+" "+data.productPrice,
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600
                                  ),),

                                SizedBox(width: 6,),

                                Text(rupee+" "+data.productPrice,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.lineThrough
                                  ),),
                              ],
                            ),

                            SizedBox(height: 2,),

                            SizedBox(height: 5,),
                          ],
                        ),
                      ),
                      SizedBox(width: 10,),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text("Level "+data.id,style: TextStyle(fontSize: 12,color: Colors.white),),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.9),
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0)
                            )
                        ),
                      )
                    ],
                  )
                ]
            )
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {

  final TransactionData d;

  const TransactionTile({Key key, this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(

          children: [

            SizedBox(width: 3,),

            Image.asset("assets/transaction_icon.jpg",width:40,height:40),

//            Icon(Icons.loop,size: 40,color: Colors.grey[800],),

            SizedBox(width: 13,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4,),

                  Text(d.title,style: TextStyle(color:Colors.black,fontSize: 16),),

                  SizedBox(height: 4,),

                  Text(d.date,style: TextStyle(color:Colors.grey,fontSize: 10),),

                  SizedBox(height: 4,),
                ],
              ),
            ),

            Text(d.amount[0]+" $rupee "+d.amount.substring(1),style: TextStyle(color:
            d.amount.contains("-") ? Colors.red : Colors.green,
                fontSize: 18,fontWeight: FontWeight.w600),),

            SizedBox(width: 10,),

          ],
        ),
      ),
    );
  }
}

class RedeemTile extends StatelessWidget {

  final RedeemData d;

  const RedeemTile({Key key, this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Row(

          children: [

            SizedBox(width: 3,),

//            Icon(Icons.redeem,size: 40,color: Colors.grey[800],),
            Image.asset("assets/transaction_icon.jpg",width:40,height:40),

            SizedBox(width: 13,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4,),
                  Text(d.title,style: TextStyle(color:Colors.black,fontSize: 15),),

                  SizedBox(height: 4,),
                  Text(d.date,style: TextStyle(color:Colors.grey,fontSize: 12),),
                  SizedBox(height: 4,),
                  Text(d.redeem_id,style: TextStyle(color:Colors.grey,fontSize: 12),),
                  SizedBox(height: 4,),
                ],
              ),
            ),

            Text(d.status,style: TextStyle(color:d.status_color,fontSize: 17,fontWeight: FontWeight.w500),),

            SizedBox(width: 10,),

          ],
        ),
      ),
    );
  }
}
