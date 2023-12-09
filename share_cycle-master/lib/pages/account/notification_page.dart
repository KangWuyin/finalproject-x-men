import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/pages/account/notification_details_page.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/title.dart';

import '../../generated/l10n.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  UserBean? userBean;

  List<dynamic> messageData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));
      getMessageData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(leading: true, title: "${S.of(context).notification}"),
      body: Container(
        child: ListView.builder(
          padding: EdgeInsets.only(bottom: 15.h),
          itemCount: messageData.length,
          itemBuilder: (BuildContext context, int index) {
            dynamic dataTemp = messageData[index];
            return GestureDetector(
              onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
                  return NotificationDetailsPage(
                    data: dataTemp,
                  );
                }));
                getMessageData();
              },
              child: item(dataTemp),
            );
          },
        ),
      ),
    );
  }

  Widget item(dynamic dataTemp) {
    String datetime = dataTemp['datetime'];
    String content = dataTemp['content'];
    int type = dataTemp['type'];
    String title = "";
    if (type == 0) {
      title = "Borrowed";
      title = "${S.of(context).noti_ordinary}";
      // content = dataTemp['content'];
      // content = "${S.of(context).the_loan_application_was_rejected}"; // 借出申请 状态
      if (dataTemp["auditing_state"] == 0) {
        // Lending Request
      } else if (dataTemp["auditing_state"] == 1) {
        // Borrowing request rejected
        content = "${S.of(context).the_loan_application_was_rejected}";
      } else if (dataTemp["auditing_state"] == 2) {
        // Passed Borrowing request passed
        content = "${S.of(context).borrowing_application_approved}";
      } else if (dataTemp["auditing_state"] == 3) {
        // Lending application approved
        content = "${S.of(context).loan_application_approved}";
      } else {
        content = "${content}";
      }
    } else if (type == 1) {
      // return item
      title = "RETURN CONFIRMATION";
      title = "${S.of(context).noti_RETURN_CONFIRMATION}";
      var decode = json.decode(dataTemp['content']);
      content = decode['body'];
    } else if (type == 2) {
      title = "Lending"; //  lend
      title = "${S.of(context).noti_lend}";
      var decode = json.decode(dataTemp['content']);
      // lend to
      content = "${S.of(context).whether_to_store_the_item} ${decode['goods_name']} ${S.of(context).lending_to} ${decode['apply_user_name']}";
    } else if (type == 3) {
      // return
      title = "RETURN CONFIRMATION"; // return item
      title = "${S.of(context).noti_RETURN_CONFIRMATION}";
      var decode = json.decode(dataTemp['content']);
      content = "${decode['body']}${S.of(context).return_the_current_item}";
    }

    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, top: 5),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black, width: 2))),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20),
              ),
              Spacer(),
              Text(
                "${datetime}",
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(
                "${content}",
                style: TextStyle(fontSize: 20),
              )),
              if (dataTemp['state'] == 0)
                Icon(
                  Icons.lens,
                  size: 10,
                  color: Colors.red,
                ),
              Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  getMessageData() async {
    messageData.clear();
    FirebaseFirestore db = FirebaseFirestore.instance;
    var future = await db
        .collection("message")
        .orderBy("datetime", descending: true)
        .where("user_id", isEqualTo: userBean?.id) //
        .get();

    var docs = future.docs;
    for (var value in docs) {
      messageData.add({
        "id": value.id,
        "content": value.get("content"),
        "type": value.get("type"),
        "datetime": value.get("datetime"),
        "user_id": value.get("user_id"),
        "state": value.get("state"),
        "auditing_state": value.get("auditing_state"),
      });
    }
    setState(() {});
  }
}
