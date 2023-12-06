import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/pages/home_page.dart';
import 'package:share_cycle/pages/reg_page.dart';
import 'package:share_cycle/utils/app_info.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/title.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool loading = false;

  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      _email.text = await getData("local_email")??"";
      _password.text = await getData("local_password")??"";

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(title: "ShareCycle", leading: true),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.asset("assets/images/about_us.jpg",fit: BoxFit.fill,width: 100,height: 100,),
            ),
            SizedBox(height: 20,),
            Divider(
              height: 2,
              color: Colors.black,
            ),
            TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: "${S.of(context).username}",
                labelStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "${S.of(context).password}",
                labelStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            SizedBox(
              height: 30,
            ),

            Container(
              width: 30,
              height: 30,
              child: Visibility(child: CircularProgressIndicator(),visible: loading,),
            ),

            itemBtn(
                icon: Icons.login,
                text: '${S.of(context).login}',
                click: () {
                  if(loading){
                    return;
                  }
                  loginUser();
                  // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  //   return HomePage();
                  // }));
                }),
            itemBtn(
                icon: Icons.radar,
                text: '${S.of(context).register}',
                click: () {
                  if(loading){
                    return;
                  }
                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                    return RegPage();
                  }));
                }),
          ],
        ),
      ),
    );
  }

  Widget itemBtn({required IconData icon, required String text, required Function click}) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [
            Color(0xff000000),
            Colors.blue,
          ])),
      child: ElevatedButton(
        onPressed: () {
          click();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.login,
              color: Colors.transparent,
            ),
            Text(
              "$text",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Icon(
              icon,
              color: Colors.white,
            )
          ],
        ),
        style: ButtonStyle(
          //去除阴影
          elevation: MaterialStateProperty.all(0),
          //将按钮背景设置为透明
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  loginUser() async {
    if (_email.text == "") {
      return;
    }
    if (_password.text == "") {
      return;
    }
    setState(() {
      loading = true;
    });

    FirebaseFirestore db = FirebaseFirestore.instance;
    var getUser = await db.collection("user").where("user_name", isEqualTo: _email.text).where("password", isEqualTo: _password.text).get();
    if (getUser.size == 0) {
      // SnackUtils.showSnack(context, "Account or password error");
      SnackUtils.showSnack(context, "${S.of(context).account_or_password_error}");
      setState(() {
        loading = false;
      });
      return;
    }
    var queryDocumentSnapshot = getUser.docs[0];
    dynamic userJson = {"id":"${queryDocumentSnapshot.id}","username":"${queryDocumentSnapshot["user_name"]}","email":"${queryDocumentSnapshot["email"]}","password":"${queryDocumentSnapshot["password"]}"};
    saveData("local_user", json.encode(userJson));
    saveData("local_email", _email.text);
    saveData("local_password", _password.text);
    setState(() {
      loading = false;
    });
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (BuildContext context) {
      return HomePage();
    }), (route) => false);
    // SnackUtils.showSnack(context, "Login successful");
    SnackUtils.showSnack(context, "${S.of(context).login_success}");
  }
}
