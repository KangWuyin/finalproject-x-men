import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:share_cycle/generated/l10n.dart';
import 'package:share_cycle/utils/email_utils.dart';
import 'package:share_cycle/utils/snack_utils.dart';

class RegPage extends StatefulWidget {
  const RegPage({super.key});

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  TextEditingController _username = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _code = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  bool loading = false;
  String btnText = "";

  int _secondsRemaining = 60;
  late Timer _timer;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
        // actions to be performed when the countdown ends
        setState(() {
          btnText = S.of(context).send;
        });
        _secondsRemaining = 60;
      } else {
        setState(() {
          _secondsRemaining--;
          btnText = "$_secondsRemaining";
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      btnText = S.of(context).send;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${S.of(context).register}"),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Semantics(
              label: "用户名",
              child: TextField(
                decoration: InputDecoration(
                  labelText: "${S.of(context).username}*：",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                controller: _username,
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: Semantics(
                  label: "邮箱地址",
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "${S.of(context).email}*：",
                      labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    controller: _email,
                  ),
                )),
                Container(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () async {
                        sendWR(_email.text);
                      },
                      style: ButtonStyle(
                          padding: MaterialStatePropertyAll(
                              EdgeInsets.only(left: 30, right: 30))),
                      child: Text("$btnText")),
                ),
              ],
            ),
            Semantics(
              label: "验证码",
              child: TextField(
                decoration: InputDecoration(
                  labelText: "${S.of(context).code_ver}*：",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                controller: _code,
              ),
            ),
            Semantics(
              label: "密码",
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "${S.of(context).password}*：",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                controller: _password,
              ),
            ),
            Semantics(
              label: "确认密码框",
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "${S.of(context).confirm_password}*：",
                  labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                ),
                controller: _confirmPassword,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            itemBtn(
              icon: Icons.radar,
              text: '${S.of(context).submit}',
            ),
            SizedBox(
              height: 10,
            ),
            Visibility(
              child: CircularProgressIndicator(),
              visible: loading,
            ),
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
        onPressed: () {
          if (loading) {
            return;
          }
          regUser();
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
          //remove shadow
          elevation: MaterialStateProperty.all(0),
          //set the button background to transparent
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
    );
  }

  regUser() async {
    if (_username.text == "") {
      SnackUtils.showSnack(context, "${S.of(context).please_enter_username}");
      return;
    }
    String email = _email.text;
    // if (!EmailUtils.checkEmail(context, email)) {
    //   print("邮箱不匹配");
    //   return;
    // }

    if (_password.text == "") {
      SnackUtils.showSnack(context, "${S.of(context).please_enter_password}");
      return;
    }

    // unmatch
    if (_confirmPassword.text != _password.text) {
      return;
    }
    setState(() {
      loading = true;
    });

    // check if the verification code matches
    int code = int.parse(_code.text.toString());
    var getRegCode = await db
        .collection("email")
        .where("email", isEqualTo: _email.text)
        .where("state", isEqualTo: 0)
        .where("code", isEqualTo: code)
        .get();
    if (getRegCode.size == 0) {
      // no verification code
      setState(() {
        loading = false;
      });
      return;
    }

    // extract the verification code information
    QueryDocumentSnapshot queryDocumentSnapshot = getRegCode.docs[0];

    // first query
    var getUser = await db
        .collection("user")
        .where("email", isEqualTo: _email.text)
        .get();
    if (getUser.size > 0) {
      // SnackUtils.showSnack(context, "The email already exists");
      SnackUtils.showSnack(
          context, "${S.of(context).the_email_already_exists}");
      return;
    }
    var createUser = await db.collection("user").add({
      "user_name": _username.text,
      "email": _email.text,
      "password": _password.text,
    });

    //modify the verification status
    await db.collection("email").doc(queryDocumentSnapshot.id).update({
      "state": 1,
    });

    setState(() {
      loading = false;
    });
    if (createUser.id == "") {
      return;
    } else {
      // SnackUtils.showSnack(context, "Registration successful");
      SnackUtils.showSnack(context, "${S.of(context).registration_successful}");
      Navigator.pop(context);
    }
  }

  sendWR(String email) async {
    if (!EmailUtils.checkEmail(context, email, format: "@northeastern.edu")) {
      return;
    }

    if (loading) {
      return;
    }
    if (_secondsRemaining != 60) {
      return;
    }
    setState(() {
      loading = true;
    });

    //first check if it has already been registered
    var getUser = await db
        .collection("user")
        .where("email", isEqualTo: _email.text)
        .get();
    if (getUser.size > 0) {
      // SnackUtils.showSnack(context, "The email already exists");
      SnackUtils.showSnack(context,
          "${S.of(context).the_email_already_exists}"); // have registered
      setState(() {
        loading = false;
      });
      return;
    }

    Random random = Random();
    int min =
        1000; // Minimum value (the minimum value for a 4-digit number is 1000)
    int max =
        9999; // The maximum value (the maximum value for a 4-digit number is 9999)
    int verificationCode = min + random.nextInt(max - min); //verification code
    // The storage of a verification code in data
    await db
        .collection("email")
        .add({"email": "${email}", "code": verificationCode, "state": 0});
    // email account
    String hotmailUserName = "shareagoods2023@outlook.com";
    // email password
    String hotmailPassword = "share2023";
    SmtpServer smtpServer = hotmail(hotmailUserName, hotmailPassword);
    final message = Message()
      ..from = Address("shareagoods2023@outlook.com", 'test')
      ..recipients.add("$email")
      ..subject = 'Registration verification code'
      ..text = 'The current verification code is: $verificationCode';

    try {
      SendReport sendReport = await send(message, smtpServer);
      print(sendReport);
      SnackUtils.showSnack(context, S.of(context).send_email_code_success);
      // SnackUtils.showSnack(context, "Send email code success");
      startTimer();
    } catch (error) {
      SnackUtils.showSnack(context, error.toString());
    }
    setState(() {
      loading = false;
    });
  }
}
