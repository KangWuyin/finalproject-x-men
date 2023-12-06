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
        // 查询是否已经被处理
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
              if (widget.data["type"] == 2) lending(), // 出借授权
              if (widget.data["type"] == 3) submitData(), // 归还物品通知
              // if (widget.data["type"] == 4) submitData(), // 被借出 ，这个属于普通消息
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

  // 普通通知
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

  // 归还通知
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
                // 查询是否已经被处理
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
                // 物品归位
                await db.collection("lend").doc(body['lend_id']).update({
                  "state": 0, // 恢复状态
                  "goods_state": goodsState ?"damage" : "intact"// "损坏" : "完好"
                });
                // 给打 score
                await db.collection("user_score").add({
                  "user_id": body['return_user_id'],
                  "score": selectScore, "scoring_user": userBean?.id //
                });
                // 修改评论
                await db.collection("return").doc(body['return_id']).update({
                  "lender_comment": borrowedComment, // 出借人
                });
                // "lender_comment": value.get("lender_comment"), // 出借人
                // "borrowed_comment": value.get("borrowed_comment"), // 借入人

                // 给借阅人的评论
                // 修改对应的数据
                QuerySnapshot searchHistory = await db
                    .collection("history")
                    .where("apply_id", isEqualTo: body["apply_id"]) // 根据申请id 查询
                    .where("lend_user_id", isEqualTo: userBean?.id) // 当前用户查询
                    .get();
                // 修改分数，评论
                await db.collection("history").doc(searchHistory.docs[0].id).update({
                  "goods_score": selectScore, // 评分
                  "to_apply_comment": "${borrowedComment}", // 评论  // 物品已经损坏  ${(goodsState)?"The item has been damaged":""}
                  "goods_bad":goodsState? 1:0,  // 是否已经损坏， 0 没有  1 是
                  "state": "return", // 状态
                });


                SnackUtils.showSnack(context, "Successfully submitted"); // 提交成功
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
                //去除阴影
                elevation: MaterialStateProperty.all(0),
                //将按钮背景设置为透明
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 借出授权
  Widget lending() {
    dynamic body = json.decode(widget.data["content"]);
    var data = body["goods_img"];

    // var decode = json.decode(dataTemp['content']);
    // // 将物品出借给
    String content = "${S.of(context).whether_to_store_the_item} ${body['goods_name']} ${S.of(context).lending_to} ${body['apply_user_name']}" ;

    // 需要地址
    List<dynamic> images = (json.decode(data) as List<dynamic>).map((e) => e).toList(); // 归还的图片
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
            "$content", // 谁想借
            // "Jason wants to borrow the PEN", // 谁想借
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
                  // 查询是否已经被处理
                  setState(() {
                    loading = true;
                  });

                  // 判断当前消息是否被处理过
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
                  // 同意，状态修改
                  await db.collection("apply").doc(body['apply_id']).update({
                    "state": 3, // state 3 审核通过，已经借给对方
                    "last_date": DateTool.getToDay(), // 修改下最后的操作时间
                    "borrowing_date": DateTool.getToDay(), // 借入时间
                    "return_date": "", // 归还时间
                  });
                  await db.collection("apply").doc(body['apply_id']).update({
                    "order_state":1,
                  });

                  // 发送消息给借的人消息申请通过
                  await db.collection("message").add({
                    "user_id": body["apply_user_id"],
                    "type": 0, // 普通消息
                    "state": 0,
                    "datetime": DateTool.getToDay(),
                    "auditing_state":2,  // 借入申请通过
                    "content": "${S.of(context).borrowing_application_approved}", // 借入申请通过
                  });
                  // 发送消息给出借人
                  await db.collection("message").add({
                    "user_id": body["user_id"],
                    "type": 0, // 普通消息
                    "state": 0,
                    "datetime": DateTool.getToDay(),
                    "auditing_state":3,  // 借出申请通过
                    "content": "${S.of(context).loan_application_approved}", // 借出申请通过
                  });

                  // 历史消息添加一条就足够

                  // 添加 来借的人 历史消息
                  final borrowedHistory = <String, dynamic>{
                    "lend_user_id": userBean?.id, // 出借者的id
                    "apply_user_id": body["apply_user_id"], // 出借者的id
                    "apply_id": body['apply_id'], //  申请对应的id
                    "state": "unreturn",

                    "lender_name": body["lend_user_name"], // 出借者姓名
                    "to_lend_comment": "", // 给出借者的评价

                    "apply_name": body["apply_user_name"], // 借入者姓名
                    "to_apply_comment": "", // 给借入者的评价

                    "lend_id": body['lend_id'], // 物品的id
                    "history_date": DateTool.getToDay(),
                    "goods_score": 0,
                    "address": body["address"], // 地址
                    "goods_img": body["goods_img"], // 图片
                    "goods_name": body["goods_name"], // 物品名称
                    "create_date": DateTool.getToDay(), // 时间
                  };
                  var createBorrowedHistory = await db.collection("history").add(borrowedHistory);
                  // if (createBorrowedHistory.id != "") {
                  //   SnackUtils.showSnack(context, "添加历史记录成功");
                  // }
                  SnackUtils.showSnack(context, "Successfully lent"); // 出借成功
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
                    // SnackUtils.showSnack(context, "The current application has been processed and cannot proceed with the operation");//当前申请已经处理,无法继续操作
                    SnackUtils.showSnack(context, "${S.of(context).the_current_application_has_been_processed_and_cannot_proceed_with_the_operation}");//当前申请已经处理,无法继续操作
                    return;
                  }
                  // 拒绝
                  await db.collection("lend").doc(body['lend_id']).update({"state": 0}); // 恢复商品状态
                  await db.collection("apply").doc(body['apply_id']).update({
                    "state": 2, // state 2 是被拒的状态
                    "last_date": DateTool.getToDay(), // 修改下最后的操作时间
                  });
                  // 发送消息给借的人消息被拒了
                  await db.collection("message").add({
                    "user_id": body["apply_user_id"],
                    "type": 0, // 驳回 0  普通消息
                    "state": 0,
                    "datetime": DateTool.getToDay(),
                    "auditing_state":1,  // 借出申请被拒了
                    "content": "${S.of(context).the_loan_application_was_rejected}",  // 借出申请被拒了
                  });
                  SnackUtils.showSnack(context, "${S.of(context).the_loan_application_was_rejected}");  // 借出申请拒绝了
                  // SnackUtils.showSnack(context, "The loan application was rejected");  // 借出申请拒绝了
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
