import 'package:flutter/material.dart';

import 'loading_dialog.dart';

class DialogHelper {

//  static exit(context) => showDialog(context: context, builder: (context) => ExitConfirmationDialog());
//
//  static referDialog(context) => showDialog(context: context, builder: (context) => EnterReferCode());

  static loadingDialog(context) => showDialog(context: context, builder: (context) => LoadingDialog(),barrierDismissible: false);
}