
import 'dart:convert';

import 'package:share_cycle/utils/sp_utils.dart';

class AppInfo{

  static getUserInfo() async{
    return  json.decode(await getData("local_user"));
  }



}