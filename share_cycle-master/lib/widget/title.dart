
import 'package:flutter/material.dart';


AppBar titleWidget({String title ="",bool leading = false,List<Widget>? actions }){
  return AppBar(
    centerTitle: true,
    leading: leading ? null:Text(""),
    title: Text(
      title,
      style: TextStyle(fontSize: 18,color: Colors.black,fontWeight: FontWeight.bold),
    ),
    actions: actions,
  );
}
