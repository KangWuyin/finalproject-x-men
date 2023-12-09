

import 'package:flutter/material.dart';
import 'package:share_cycle/utils/snack_utils.dart';

import '../generated/l10n.dart';

class EmailUtils{

  static bool checkEmail(BuildContext context,String email,{String format=""}){
    if (email == "") {
      SnackUtils.showSnack(context, "${S.of(context).please_enter_email}");
      return false;
    }
    // Determine mailbox format
    String regexEmail = "^([a-z0-9A-Z]+[-|\\.]?)+[a-z0-9A-Z]@([a-z0-9A-Z]+(-[a-z0-9A-Z]+)?\\.)+[a-zA-Z]{2,}\$";
    if(!RegExp(regexEmail).hasMatch(email)){
      SnackUtils.showSnack(context, "${S.of(context).please_enter_correct_format_email}");
      return false;
    }
    // tail number judgment
    if(format!=""){
      if(email.substring(email.length-format.length,email.length)!="$format"){
        SnackUtils.showSnack(context, "${S.of(context).please_enter_correct_format_email}");
        return false;
      }
    }

    return true;
  }

}