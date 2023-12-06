import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/utils/app_info.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/title.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {


  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _comPassword = TextEditingController();

  dynamic userData;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {


      userData = json.decode(await getData("local_user"));
      _username.text = userData["username"];
      _email.text = userData["email"];
      _password.text = userData["password"];
      _comPassword.text = userData["password"];

      setState(() {

      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(
        leading: true,
          title: S.of(context).profile_info
      ),

      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            TextField(
              controller: _username,
              enabled: false,
              decoration: InputDecoration(
                labelText: "${S.of(context).username}*：",
                labelStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            TextField(
              controller: _email,
              enabled: false,
              decoration: InputDecoration(
                labelText: "${S.of(context).email}：",
                labelStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "${S.of(context).password}*：",
                labelStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            TextField(
              controller: _comPassword,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "${S.of(context).confirm_password}*：",
                labelStyle: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            (loading)?CircularProgressIndicator():
            itemBtn(icon: Icons.radar, text: '${S.of(context).save}'),
          ],
        ),
      ),
    );
  }

  Widget itemBtn({required IconData icon, required String text}) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(colors: [
            Color(0xff000000),
            Colors.blue,
          ])),
      child: ElevatedButton(
        onPressed: () async {

          if(_username.text==""){
            SnackUtils.showSnack(context, "${S.of(context).please_enter_username}");
            return;
          }
          if(_email.text==""){
            SnackUtils.showSnack(context, "${S.of(context).please_enter_email}");
            return;
          }
          if(_password.text==""){
            SnackUtils.showSnack(context, "${S.of(context).please_enter_password}");
            return;
          }

          setState(() {
            loading = true;
          });
          FirebaseFirestore db = FirebaseFirestore.instance;

          //检查是否存在用户名
          var querySnapshotUser = await db.collection("user").where("user_name",isEqualTo: _username.text.toString()).get();
          if(querySnapshotUser.docs.isEmpty){
            // 接着修改密码
            SnackUtils.showSnack(context, "该用户名不存在");
            return;
          }

          await db.collection("user").doc("${userData['id']}").update({
            "user_name":_username.text,
            "email":_email.text,
            "password":_password.text,
          });

          SnackUtils.showSnack(context, "${S.of(context).account_success}");

          setState(() {
            loading = false;
          });

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


}
