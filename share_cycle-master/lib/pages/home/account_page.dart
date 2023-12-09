import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/event_utils.dart';
import 'package:share_cycle/pages/account/account_info_page.dart';
import 'package:share_cycle/pages/account/history_page.dart';
import 'package:share_cycle/pages/login_page.dart';
import 'package:share_cycle/widget/rating_bar_ex.dart';

import '../../generated/l10n.dart';
import '../../utils/sp_utils.dart';
import '../account/about_page.dart';
import '../account/notification_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  List<dynamic> dataItem = [];

  UserBean? userBean;
  dynamic scoreValue = 0;
  bool stateMessage = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));
      checkMessageState();
      dataItem.clear();
      dataItem = [
        {
          "label": "${S.of(context).my_account}",
          "icon": Icons.account_circle,
          "route": AccountInfoPage()
        },
        {
          "label": "${S.of(context).History}",
          "icon": Icons.history,
          "route": HistoryPage()
        },
        {
          "label": "${S.of(context).NOTIFICATION}",
          "icon": Icons.notifications_active_outlined,
          "route": NotificationPage()
        },
        {
          "label": "${S.of(context).ABOUTS}",
          "icon": Icons.accessibility_rounded,
          "route": AboutPage()
        },
        {
          "label": "${S.of(context).LOGOUT}",
          "icon": Icons.login_outlined,
          "route": LoginPage()
        },
      ];
      setState(() {});
      // Obtain Scores
      getAccountScore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "${(userBean == null) ? "" : userBean?.username ?? ""}",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 2 - 100.w),
                    child: RatingBarEx(
                      score: (int value) {},
                      scoreValue: scoreValue,
                      enable: false,
                    ),
                  ),
                ],
              )),
              Container(
                  child: Row(
                children: [
                  Icon(Icons.language),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      S.load(Locale("en"));
                      eventBus.fire(CheckLanguageEvent(check: true));
                      setLanguage();
                    },
                    child: Text("EN", style: TextStyle(fontSize: 18)),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      S.load(Locale("zh"));
                      eventBus.fire(CheckLanguageEvent(check: true));
                      setLanguage();
                    },
                    child: Text(
                      "ZH",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              )),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
              child: GridView.builder(
            padding: EdgeInsets.all(10),
            itemCount: dataItem.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1),
            itemBuilder: (BuildContext context, int index) {
              dynamic data = dataItem[index];
              return GestureDetector(
                onTap: () async {
                  if (data['route'] is LoginPage) {
                    Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return data['route'];
                    }), (route) => false);
                    return;
                  }
                  if (index == 2) {
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return data['route'];
                    }));
                    checkMessageState();
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) {
                      return data['route'];
                    }));
                  }
                },
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Stack(
                      children: [
                        if (index == 2 && stateMessage)
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              width: 15,
                              height: 15,
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                data['icon'],
                                color: Colors.white,
                                size: 30,
                              ),
                              Text(
                                "${data['label']}",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
              );
            },
          )),
        ],
      ),
    );
  }

  setLanguage() {
    setState(() {
      dataItem.clear();
    });
    dataItem = [
      {
        "label": "${S.of(context).my_account}",
        "icon": Icons.account_circle,
        "route": AccountInfoPage()
      },
      {
        "label": "${S.of(context).History}",
        "icon": Icons.history,
        "route": HistoryPage()
      },
      {
        "label": "${S.of(context).NOTIFICATION}",
        "icon": Icons.notifications_active_outlined,
        "route": NotificationPage()
      },
      {
        "label": "${S.of(context).ABOUTS}",
        "icon": Icons.accessibility_rounded,
        "route": AboutPage()
      },
      {
        "label": "${S.of(context).LOGOUT}",
        "icon": Icons.login_outlined,
        "route": LoginPage()
      },
    ];
    setState(() {});
  }

  getAccountScore() async {
    List<int> scoreData = [];

    FirebaseFirestore db = FirebaseFirestore.instance;
    var queryUserScore = await db
        .collection("user_score")
        .where("user_id", isEqualTo: userBean?.id)
        .get();

    var docs = queryUserScore.docs;
    dynamic allScore = 0;
    for (var value in docs) {
      scoreData.add(value.get("score"));
      allScore += value.get("score");
    }
    setState(() {
      if (allScore != 0) {
        scoreValue = allScore ~/ scoreData.length;
      } else {
        scoreValue = 0;
      }
    });
  }

  // Check if there are any unread messages.
  checkMessageState() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    var future = await db
        .collection("message")
        .orderBy("datetime", descending: true)
        .where("user_id", isEqualTo: userBean?.id) //
        .where("state", isEqualTo: 0)
        .get();

    var docs = future.docs;
    if (docs.isNotEmpty) {
      setState(() {
        stateMessage = true;
      });
    } else {
      setState(() {
        stateMessage = false;
      });
    }
  }
}
