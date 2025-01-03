import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:gplusapp/Helper/Constance.dart';
import 'package:niri9/Constants/constants.dart';

import '../Navigation/Navigate.dart';

class AlertX {
  AlertX._privateConstructor();

  static final AlertX instance = AlertX._privateConstructor();

  showAlert(
      {required String title,
        required String msg,
        String? negativeButtonText,
        required String positiveButtonText,
        void Function()? negativeButtonPressed,
        required void Function() positiveButtonPressed}) {
    var context = Navigation.instance.navigatorKey.currentContext;
    if (context != null) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ));
      showDialog(
          barrierDismissible: true,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              contentPadding:
              const EdgeInsets.only(left: 24, right: 24, top: 8),
              actionsPadding: const EdgeInsets.only(left: 16, right: 16),
              content: Text(
                msg,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.black87,
                ),
              ),
              actions: [
                if (negativeButtonText != null)
                  TextButton(
                    onPressed: negativeButtonPressed,
                    child: Text(
                      negativeButtonText,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                    positiveButtonText,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          });
    }
  }
}
