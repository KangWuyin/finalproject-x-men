import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_cycle/bean/user_bean.dart';
import 'package:share_cycle/utils/date_tool.dart';
import 'package:share_cycle/utils/image_utils.dart';
import 'package:share_cycle/utils/snack_utils.dart';
import 'package:share_cycle/utils/sp_utils.dart';
import 'package:share_cycle/widget/rating_bar_ex.dart';
import 'package:share_cycle/widget/title.dart';

import '../../generated/l10n.dart';

class NotificationDetailsPage extends StatefulWidget {
  dynamic data;

  NotificationDetailsPage({super.key, required this.data});

  @override
  State<NotificationDetailsPage> createState() => _NotificationDetailsPageState();
}

class _NotificationDetailsPageState extends State<NotificationDetailsPage> {
  FirebaseFirestore db = FirebaseFirestore.instance;

  bool applyRefuse = false;
  int selectScore = 1;
  UserBean? userBean;
  bool goodsState = false;
  String borrowedComment = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      userBean = UserBean.fromJson(json.decode(await getData("local_user")));

      await db.collection("message").doc("${widget.data['id']}").update({"state": 1});

      if (widget.data["type"] == 1) {}
      if (widget.data["type"] == 2) {
        dynamic body = json.decode(widget.data["content"]);
        // Check whether the query has been processed
        var applyResult = await db.collection("apply").doc(body['apply_id']).get();
        if (applyResult.id != "") {
          var state = applyResult.data()!["state"];
          if (state == 2 || state == 3) {
            setState(() {
              applyRefuse = true;
            });
          } else {
            setState(() {
              applyRefuse = false;
            });
          }
        }
      }
      if (widget.data["type"] == 3) {}
      if (widget.data["type"] == 4) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: titleWidget(leading: true, title: "${S.of(context).noti_title}"),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          child: Column(
            children: [
              if (widget.data["type"] == 0) ordinaryData(),
              if (widget.data["type"] == 1) ordinaryData(),
              if (widget.data["type"] == 2) lending(), // lending authorization
              if (widget.data["type"] == 3) submitData(), // Notice of return of items
              // if (widget.data["type"] == 4) submitData(), // Being lent, this is an ordinary message
              Container(
                width: 30,
                height: 30,
                child: Visibility(
                  child: CircularProgressIndicator(),
                  visible: loading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // General notice
  Widget ordinaryData() {
    return Column(
      children: [
        Container(
          height: 100,
          width: double.maxFinite,
          child: Icon(
            Icons.account_circle,
            size: 50,
          ),
        ),
        Text(
          "${widget.data["content"]}",
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  // Notice of return
  Widget submitData() {
    dynamic body = json.decode(widget.data["content"]);
    var data = body["return_goods_img"];
    List<dynamic> images = (json.decode(data) as List<dynamic>).map((e) => e).toList(); // 归还的图片
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150.h,
            child: (images.isNotEmpty)
                ? PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.all(1),
                        child: Image.network(
                          ImageUtils.firebaseImageUrl(fileName: images[index]),
                          fit: BoxFit.fill,
                          width: double.maxFinite,
                        ),
                      );
                    },
                  )
                : Container(),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${S.of(context).noti_goods_bad}",
                style: TextStyle(fontSize: 20),
              ),
              Checkbox(
                  value: goodsState,
                  onChanged: (value) {
                    setState(() {
                      goodsState = value!;
                    });
                  }),
            ],
          ),
          Text(
            "${S.of(context).noti_goods_score}",
            style: TextStyle(fontSize: 20),
          ),
          RatingBarEx(
            count: 5,
            scoreValue: selectScore,
            score: (value) {
              selectScore = value;
            },
          ),
          Text(
            "${S.of(context).noti_goods_comment}",
            style: TextStyle(fontSize: 20),
          ),
          Container(
            padding: EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
            width: double.maxFinite,
            height: 200,
            child: TextField(
              decoration: InputDecoration(border: InputBorder.none),
              onChanged: (value) {
                borrowedComment = value;
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            margin: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(colors: [
                  Color(0xff000000),
                  Colors.blue,
                ])),
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  loading = true;
                });
                // Check whether the query has been processed
                var applyResult = await db.collection("lend").doc(body['lend_id']).get();
                if (applyResult.id != "") {
                  var state = applyResult.data()!["state"];
                  if (state == 0) {
                    setState(() {
                      loading = false;
                    });
                    // SnackUtils.showSnack(context, "当前归还已经处理,无法继续操作");
                    SnackUtils.showSnack(context, "${S.of(context).the_current_return_has_been_processed}");
                    return;
                  }
                }
                // Returning items
                await db.collection("lend").doc(body['lend_id']).update({
                  "state": 0, // restore status
                  "goods_state": goodsState ?"damage" : "intact"// "damaged" : "good"
                });
                // score
                await db.collection("user_score").add({
                  "user_id": body['return_user_id'],
                  "score": selectScore, "scoring_user": userBean?.id //
                });
                // Edit comment
                await db.collection("return").doc(body['return_id']).update({
                  "lender_comment": borrowedComment, // lender
                });
                // "lender_comment": value.get("lender_comment"), // lender
                // "borrowed_comment": value.get("borrowed_comment"), // borrower

                // Comments to borrowers
                // Modify the corresponding data
                QuerySnapshot searchHistory = await db
                    .collection("history")
                    .where("apply_id", isEqualTo: body["apply_id"]) // Query based on application id
                    .where("lend_user_id", isEqualTo: userBean?.id) // Current user query
                    .get();
                // Modify scores, comment
                await db.collection("history").doc(searchHistory.docs[0].id).update({
                  "goods_score": selectScore, // score
                  "to_apply_comment": "${borrowedComment}", // Comment  // Item has been damaged  ${(goodsState)?"The item has been damaged":""}
                  "goods_bad":goodsState? 1:0,  // Whether it has been damaged, 0 no 1 yes
                  "state": "return", // state
                });


                SnackUtils.showSnack(context, "Successfully submitted"); // Submitted successfully
                setState(() {
                  loading = false;
                });
                Navigator.pop(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${S.of(context).noti_goods_submit}",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
              style: ButtonStyle(
                // remove shadow
                elevation: MaterialStateProperty.all(0),
                //Set button background to transparent
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Lending authorization
  Widget lending() {
    dynamic body = json.decode(widget.data["content"]);
    var data = body["goods_img"];

    // var decode = json.decode(dataTemp['content']);
    // // lend items to
    String content = "${S.of(context).whether_to_store_the_item} ${body['goods_name']} ${S.of(context).lending_to} ${body['apply_user_name']}" ;

    // Address required
    List<dynamic> images = (json.decode(data) as List<dynamic>).map((e) => e).toList(); // Returned pictures
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150.h,
            child: (images.isNotEmpty)
                ? PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.all(1),
                        child: Image.network(
                          ImageUtils.firebaseImageUrl(fileName: images[index]),
                          fit: BoxFit.fill,
                          width: double.maxFinite,
                        ),
                      );
                    },
                  )
                : Container(),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "$content", // who wants to borrow
            // "Jason wants to borrow the PEN", //
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            "${S.of(context).you_want_to} :",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () async {
                  // Check whether the query has been processed
                  setState(() {
                    loading = true;
                  });

                  // Determine whether the current message has been processed
                  var applyResultEx = await db.collection("apply").doc(body['apply_id']).get();
                  if (applyResultEx.id != "") {
                    var order_state = applyResultEx.data()?["order_state"];
                    if (order_state!=null && order_state == 1) {
                      showToast(S.of(context).the_current_application_has_been_processed_and_cannot_proceed_with_the_operation);
                      setState(() {
                        loading = false;
                      });
                      return;
                    }
                  }

                  var applyResult = await db.collection("apply").doc(body['apply_id']).get();
                  if (applyResult.data() != null) {
                    var state = applyResult.data()!["state"];
                    if (state == 2 || state == 3) {
                      applyRefuse = true;
                      showToast(S.of(context).the_current_application_has_been_processed_and_cannot_proceed_with_the_operation);
                      setState(() {
                        loading = false;
                      });
                      return;
                    }
                  }
                  // Agree, status modified
                  await db.collection("apply").doc(body['apply_id']).update({
                    "state": 3, // state 3 Approved and has been lent to the other party
                    "last_date": DateTool.getToDay(), // Modify the last operation time
                    "borrowing_date": DateTool.getToDay(), // 借入时间 borrow time
                    "return_date": "", // return time
                  });
                  await db.collection("apply").doc(body['apply_id']).update({
                    "order_state":1,
                  });

                  // Send a message to the borrower. The message application is approved.
                  await db.collection("message").add({
                    "user_id": body["apply_user_id"],
                    "type": 0, // General notifications
                    "state": 0,
                    "datetime": DateTool.getToDay(),
                    "auditing_state":2,  // Borrow application approved
                    "content": "${S.of(context).borrowing_application_approved}", // Borrow application approved
                  });
                  // Send message to lender
                  await db.collection("message").add({
                    "user_id": body["user_id"],
                    "type": 0, // General news
                    "state": 0,
                    "datetime": DateTool.getToDay(),
                    "auditing_state":3,  //The lent application was approved
                    "content": "${S.of(context).loan_application_approved}", // The lent application was approved
                  });


                  // It is enough to add one historical message

                  // Add historical information about people who came to borrow
                  final borrowedHistory = <String, dynamic>{
                    "lend_user_id": userBean?.id, // lender's id
                    "apply_user_id": body["apply_user_id"], // lender's id
                    "apply_id": body['apply_id'], //  Apply for the corresponding ID
                    "state": "unreturn",

                    "lender_name": body["lend_user_name"], // Lender's name
                    "to_lend_comment": "", // Reviews for lenders

                    "apply_name": body["apply_user_name"], // Borrower's name
                    "to_apply_comment": "", // Reviews for borrower

                    "lend_id": body['lend_id'], // item's name
                    "history_date": DateTool.getToDay(),
                    "goods_score": 0,
                    "address": body["address"], // address
                    "goods_img": body["goods_img"], // picture
                    "goods_name": body["goods_name"], // picture's name
                    "create_date": DateTool.getToDay(), // time
                  };
                  var createBorrowedHistory = await db.collection("history").add(borrowedHistory);
                  // if (createBorrowedHistory.id != "") {
                  //   SnackUtils.showSnack(context, "添加历史记录成功");
                  // }

                  // After lending, the data will be completed.
                  await db.collection("apply").doc(body['apply_id']).update({
                    "order_state":1,
                  });

                  SnackUtils.showSnack(context, "Successfully lent"); // Lending successful
                  setState(() {
                    loading = false;
                  });

                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.done,
                        size: 50,
                        color: Colors.black,
                      ),
                      Text(
                        "${S.of(context).you_approve}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  if (applyRefuse) {
                    // SnackUtils.showSnack(context, "The current application has been processed and cannot proceed with the operation");//The current application has been processed and cannot be continued.
                    SnackUtils.showSnack(context, "${S.of(context).the_current_application_has_been_processed_and_cannot_proceed_with_the_operation}");//The current application has been processed and cannot be continued.
                    return;
                  }
                  // refuse
                  await db.collection("lend").doc(body['lend_id']).update({"state": 0}); // restore item status
                  await db.collection("apply").doc(body['apply_id']).update({
                    "state": 2, // state 2 is in a rejected state
                    "last_date": DateTool.getToDay(), // Modify the last operation time
                  });
                  // Sending a message to the person who borrowed it was rejected.
                  await db.collection("message").add({
                    "user_id": body["apply_user_id"],
                    "type": 0, // Reject 0 general message
                    "state": 0,
                    "datetime": DateTool.getToDay(),
                    "auditing_state":1,  // The lent application was rejected
                    "content": "${S.of(context).the_loan_application_was_rejected}",  // The lent application was rejected
                  });
                  SnackUtils.showSnack(context, "${S.of(context).the_loan_application_was_rejected}");  // The lent application was rejected
                  // SnackUtils.showSnack(context, "The loan application was rejected");  // The lent application was rejected
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.block,
                        size: 50,
                        color: Colors.black,
                      ),
                      Text(
                        "${S.of(context).reject}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
