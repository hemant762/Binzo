import 'package:flutter/material.dart';

import '../constants.dart';

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
      ),
      elevation: 20,
      backgroundColor: Colors.white,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) => WillPopScope(
    onWillPop: () async { return false; },
    child: SizedBox(
      height: 80,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.rectangle,
        ),
        child: SizedBox(
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 25,),
                CircularProgressIndicator(valueColor: new AlwaysStoppedAnimation<Color>(kPrimaryColor),),
                SizedBox(width: 25,),
                Text("Loading ... ",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 17.0),)
              ],
            ),
          ),
        )
      ),
    ),
  );
}